clear; close all; clc;

%% ─── Cylinder & Valve Parameters ────────────────────────────────────────────
d   = 65e-3;               % piston diameter            [m]
dr  = 35e-3;               % rod diameter               [m]
A   = pi*d^2/4;            % full-bore piston area      [m^2]
Ar  = pi*dr^2/4;           % rod area                   [m^2]
Aa  = A - Ar;              % annular area               [m^2]
phi = Aa / A;              % area ratio Aa/A            [-]

Rho    = 875;              % fluid density    [kg/m^3] (unused for now)
Qref   = 18/6e4;           % nominal flow     [m^3/s] (unused for now)
dpref  = 20e5;             % nominal dp       [Pa]    (unused for now)

%% ─── Processing Parameters ───────────────────────────────────────────────────
SPOOL_HOME_THRESHOLD = -0.9;   % below this = spool at home position
DP_MIN_PA            = 1e5;    % min valid pressure drop [Pa] (1 bar)
VEL_SMOOTH_SPAN      = 80;     % smoothing window for velocity [samples]
VEL_SMOOTH_METHOD    = 'sgolay'; % 'sgolay' | 'movmean' | 'gaussian' | ...

PRINT_STEADY_WINDOW_REPORT = true;  % set false to silence per-run prints

% Scatter-only extra dP filter (helps Kv blow-up near sqrt(dP) small)
SCATTER_DP_MIN_PA = 3e5;       % [Pa] e.g. 3 bar (tune: 2e5..5e5)

%% ─── Unit Conversion ─────────────────────────────────────────────────────────
% Kv unit conversion: m³/s/Pa^0.5 → L/min/bar^0.5
KvFactor = 6e4 / sqrt(1e-5);

%% ─── Data root & folder list ─────────────────────────────────────────────────
dataRoot = '.';
folders = { ...
    fullfile(dataRoot, 'UpDown100Bar040326'), ...
    fullfile(dataRoot, 'UpDown110Bar060326'), ...
    fullfile(dataRoot, 'UpDown120Bar060326')  ...
};

%% ─── Column names ────────────────────────────────────────────────────────────
COL_time     = 'fTimer';
COL_fU       = 'fU';
COL_spool    = 'fSpoolPosition';
COL_pSupply  = 'fPs';
COL_pA       = 'fPaLower';
COL_pB       = 'fPb';
COL_flow     = 'fFlow';
COL_position = 'fPistonPosition';

%% ─── Plotting / mapping parameters ──────────────────────────────────────────
targetPressure = 120;       % pressure to use for scatter plots [bar]

% Colors (Monokai-ish, OK on white)
C_red     = [249,  38, 114] ./ 255;
C_blue    = [129, 154, 255] ./ 255;
C_black   = [ 51,  51,  51] ./ 255;

% Export template params
EXPORT_picturewidth_cm = 20;
EXPORT_hw_ratio        = 0.65;
EXPORT_fontsize        = 11;

%% ─── Polynomial fits (120 bar) ──────────────────────────────────────────────
% Kv(u): used in "Kv vs spool" scatter
pA_Kv_of_u_120 = [ 0.25826,  13.257,  -20.0668,  12.1981, -1.9583]; % Up / Port A
pB_Kv_of_u_120 = [-9.3594,   32.8145, -32.2028,  14.7576, -1.9876]; % Down / Port B

% u(Kv): used in "u vs Kv" scatter (6th order)
pUp_u_of_Kv_120   = [-0.00038291, -0.0083821,  0.11362, -0.44825, 0.64863, 0.019414, 0.25505];
pDown_u_of_Kv_120 = [ 0.001656,   -0.026792,   0.16458, -0.46999, 0.56415, 0.08632,  0.22422];

%% ─── Debug options ──────────────────────────────────────────────────────────
DEBUG_RUN = [17];   % e.g. 66; set [] to disable

%% ═══════════════════════════════════════════════════════════════════════════
%  LOAD ALL CSV FILES
%% ═══════════════════════════════════════════════════════════════════════════
allRuns = struct('folder',{},'filename',{},'direction',{},'pressure',{},'signal',{},'data',{});

for fi = 1:numel(folders)
    csvFiles = dir(fullfile(folders{fi}, '*.csv'));
    if isempty(csvFiles)
        warning('No CSV files found in: %s', folders{fi});
        continue
    end

    for ci = 1:numel(csvFiles)
        fname  = csvFiles(ci).name;
        tokens = regexp(fname, '^(Up|Down)(\d+)Bar(\d+)Signal', 'tokens', 'once');
        if isempty(tokens)
            warning('Skipping unrecognised filename: %s', fname);
            continue
        end

        entry.folder    = folders{fi};
        entry.filename  = fname;
        entry.direction = tokens{1};
        entry.pressure  = str2double(tokens{2});
        entry.signal    = str2double(tokens{3});
        entry.data      = loadAndClean(fullfile(folders{fi}, fname), COL_fU);

        fprintf('Loaded %-32s  (%s, %3d bar, %3d%%)\n', ...
            fname, entry.direction, entry.pressure, entry.signal);

        allRuns(end+1) = entry; %#ok<AGROW>
    end
end
fprintf('\nLoaded %d runs.\n', numel(allRuns));

%% ═══════════════════════════════════════════════════════════════════════════
%  QUICK DIAGNOSTIC: raw spool — one Up and one Down
%% ═══════════════════════════════════════════════════════════════════════════
idxUp   = find(strcmp({allRuns.direction}, 'Up'),   1);
idxDown = find(strcmp({allRuns.direction}, 'Down'), 1);

figure('Name', 'Diagnostic — raw spool');
for k = 1:2
    idx = [idxUp, idxDown];
    subplot(2,1,k)
    plot(allRuns(idx(k)).data{:, COL_spool})
    title(sprintf('RAW %s | %d bar | %d%%', ...
        allRuns(idx(k)).direction, allRuns(idx(k)).pressure, allRuns(idx(k)).signal))
    ylabel('Spool [-]'); xlabel('Sample index')
    grid on
end

%% ═══════════════════════════════════════════════════════════════════════════
%  COMPUTE DERIVED QUANTITIES (core pipeline)
%% ═══════════════════════════════════════════════════════════════════════════
for i = 1:numel(allRuns)
    T         = allRuns(i).data;
    direction = allRuns(i).direction;

    % 1) Sign convention: flip Up runs so "active" is positive
    % (flow sign not needed since we use abs() later)
    if strcmp(direction, 'Up')
        T{:, COL_position} = -T{:, COL_position};
        T{:, COL_spool}    = -T{:, COL_spool};
    end

    % 2) Remove home position (after flip so Up runs are not clipped)
    T = T(T{:, COL_spool} > SPOOL_HOME_THRESHOLD, :);

    % 3) Trim to steady-state spool window
    [i1, i2] = steadyStateWindow(T{:, COL_spool});
    if PRINT_STEADY_WINDOW_REPORT
        fprintf('Run %2d: %-4s | %3d bar | %3d%%  ->  window [%d..%d] (%.0f%%)\n', ...
            i, direction, allRuns(i).pressure, allRuns(i).signal, ...
            i1, i2, 100*(i2-i1)/height(T));
    end
    T = T(i1:i2, :);

    % 4) Extract signals (convert bar->Pa where needed)
    t     = T{:, COL_time};
    spool = T{:, COL_spool};
    pS_Pa = T{:, COL_pSupply} * 1e5;
    pA_Pa = T{:, COL_pA}      * 1e5;
    pB_Pa = T{:, COL_pB}      * 1e5;

    % 5) Valve pressure drop (as currently defined)
    if strcmp(direction, 'Up')
        dP = pS_Pa - pA_Pa;
    else
        dP = pS_Pa - pB_Pa;
    end

    % PATCH 3: diagnostics for negative dP BEFORE clipping
    negFrac = mean(dP < 0);
    if negFrac > 0.01
        warning('Run %d (%s %d bar %d%%): %.1f%% of dP samples < 0 before clipping', ...
            i, direction, allRuns(i).pressure, allRuns(i).signal, 100*negFrac);
    end

    % Clip for Kv computation
    dP = max(dP, 0);

    % 6) Valid dP mask (compute-time)
    validDP = dP > DP_MIN_PA;

    % 7) Flow sensor → m³/s (annular/B-side sensor)
    % Flow sensor is on the annular (B-side / ring-side) line.
    % Therefore:
    %   - Down stroke: valve feeds annular side -> sensor reads valve flow directly
    %   - Up stroke: valve feeds bore side; annular side is return -> Q_bore = Q_annular / phi
    Q_sensor_raw = abs(T{:, COL_flow}) / 60000;   % m^3/s
    if strcmp(direction, 'Up')
        Q_sensor = Q_sensor_raw ./ phi;           % convert annular return -> bore inlet
    else
        Q_sensor = Q_sensor_raw;
    end

    % 8) Piston kinematics
    pos = T{:, COL_position};
    vel = smoothdata(gradient(pos, t), VEL_SMOOTH_METHOD, VEL_SMOOTH_SPAN);

    if strcmp(direction, 'Up')
        Q_piston = A  * vel;
    else
        Q_piston = Aa * vel;
    end

    % 9) Kv (only where dP is valid)
    Kv_flow   = nan(size(dP));
    Kv_piston = nan(size(dP));
    Kv_flow(validDP)   = Q_sensor(validDP)      ./ sqrt(dP(validDP));
    Kv_piston(validDP) = abs(Q_piston(validDP)) ./ sqrt(dP(validDP));

    % Store (keep processed table too: easier debugging)
    allRuns(i).procTable = T;
    allRuns(i).t         = t;
    allRuns(i).spool     = spool;
    allRuns(i).pS_Pa     = pS_Pa;
    allRuns(i).pA_Pa     = pA_Pa;
    allRuns(i).pB_Pa     = pB_Pa;
    allRuns(i).dP        = dP;
    allRuns(i).validDP   = validDP;
    allRuns(i).Q_sensor  = Q_sensor;
    allRuns(i).Q_piston  = Q_piston;
    allRuns(i).vel       = vel;
    allRuns(i).Kv_flow   = Kv_flow;
    allRuns(i).Kv_piston = Kv_piston;
end
fprintf('Derived quantities computed for all %d runs.\n', numel(allRuns));

fprintf('\n--- Per-run median flow ratios (sensor_scaled / |piston|) ---\n');
for i = 1:numel(allRuns)
    mask = allRuns(i).validDP & (allRuns(i).dP > SCATTER_DP_MIN_PA);
    if ~any(mask), continue; end

    Qs = allRuns(i).Q_sensor(mask);
    Qp = abs(allRuns(i).Q_piston(mask));

    r = Qs ./ (Qp + eps);
    r = r(isfinite(r));

    fprintf('Run %2d: %-4s | %3d bar | %3d%%  ratio=%.3f (med)  Qs=%.1f L/min  Qp=%.1f L/min\n', ...
        i, allRuns(i).direction, allRuns(i).pressure, allRuns(i).signal, ...
        median(r,'omitnan'), median(Qs,'omitnan')*6e4, median(Qp,'omitnan')*6e4);
end

%% ═══════════════════════════════════════════════════════════════════════════
%  DEBUG PLOT: one-run sanity check (optional)
%% ═══════════════════════════════════════════════════════════════════════════
if ~isempty(DEBUG_RUN)
    i = DEBUG_RUN;

    if i < 1 || i > numel(allRuns)
        error('DEBUG_RUN=%d is out of range. Loaded %d runs.', i, numel(allRuns));
    end

    r = allRuns(i);

    % Comparable flows
    Q_sensor_scaled = r.Q_sensor;     % already scaled to valve-side flow in compute loop
    Q_piston_mag    = abs(r.Q_piston);

    % Reconstruct raw annular flow shown for reference
    if strcmp(r.direction, 'Up')
        Q_sensor_annular_raw = Q_sensor_scaled * phi;
    else
        Q_sensor_annular_raw = Q_sensor_scaled;
    end

    hdbg = figure('Name', sprintf('DEBUG Run %d: %s %d bar %d%%', ...
        i, r.direction, r.pressure, r.signal));

    tiledlayout(4,1,'TileSpacing','compact','Padding','compact');

    nexttile
    plot(r.t, r.spool, 'Color', [0.2 0.2 0.2], 'LineWidth', 1.2);
    ylabel('Spool $u$ (--)')
    title(sprintf('Run %d: %s | %d bar | %d\\%%', i, r.direction, r.pressure, r.signal))
    grid on

    nexttile
    plot(r.t, r.dP/1e5, 'Color', [0.1 0.1 0.1], 'LineWidth', 1.2); hold on
    yline(DP_MIN_PA/1e5, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.0, 'DisplayName', 'DP\_MIN');
    hold off
    ylabel('$\Delta p$ (bar)')
    grid on
    legend('Location','northwest')

    nexttile
    plot(r.t, Q_sensor_scaled*6e4, '-',  'Color', C_blue,  'LineWidth', 1.2, 'DisplayName', 'Flow sensor (scaled to valve) [L/min]');
    hold on
    plot(r.t, Q_piston_mag*6e4,    '-',  'Color', C_red,   'LineWidth', 1.2, 'DisplayName', 'Piston flow magnitude [L/min]');
    plot(r.t, Q_sensor_annular_raw*6e4,'--','Color', C_black,'LineWidth', 1.0, 'DisplayName', 'Flow sensor raw annular [L/min]');
    hold off
    ylabel('$Q$ (L/min)')
    grid on
    legend('Location','northwest')

    nexttile
    mask = r.validDP & isfinite(r.Kv_flow) & isfinite(r.Kv_piston);
    plot(r.t(mask), r.Kv_flow(mask)*KvFactor,   '-', 'Color', C_blue, 'LineWidth', 1.2, 'DisplayName', '$K_v$ flow sensor');
    hold on
    plot(r.t(mask), r.Kv_piston(mask)*KvFactor, '-', 'Color', C_red,  'LineWidth', 1.2, 'DisplayName', '$K_v$ piston');
    hold off
    ylabel('$K_v$ (L/min/bar$^{0.5}$)')
    xlabel('Time $t$ (s)')
    grid on
    legend('Location','northwest')

    set(findall(hdbg, '-property', 'FontSize'),             'FontSize', EXPORT_fontsize)
    set(findall(hdbg, '-property', 'Box'),                  'Box', 'off')
    set(findall(hdbg, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hdbg, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
end

%% ═══════════════════════════════════════════════════════════════════════════
%  PLOT 1: Kv time series (3 selected runs)
%% ═══════════════════════════════════════════════════════════════════════════
runIdx       = [1, 10, 26];
picturewidth = EXPORT_picturewidth_cm;
hw_ratio     = 0.85;

hfig = figure('Name','Kv time series');
for k = 1:numel(runIdx)
    i = runIdx(k);
    subplot(numel(runIdx), 1, k);
    plot(allRuns(i).t, allRuns(i).Kv_flow   * KvFactor, '-', 'Color', C_blue, 'LineWidth', 1.5, ...
        'DisplayName', '$K_v$ flow sensor');
    hold on
    plot(allRuns(i).t, allRuns(i).Kv_piston * KvFactor, '-', 'Color', C_red,  'LineWidth', 1.5, ...
        'DisplayName', '$K_v$ piston');
    hold off
    xlabel('Time $t$ (s)')
    ylabel('$K_v$ (L/min/bar$^{0.5}$)')
    title(sprintf('%s $|$ %d bar $|$ %d\\%% signal', ...
        allRuns(i).direction, allRuns(i).pressure, allRuns(i).signal))
    legend('Location', 'northwest');
    grid on
end
applyFigureExportTemplate(hfig, picturewidth, hw_ratio, EXPORT_fontsize);
print(hfig, 'kv_timeseries', '-dpdf', '-vector', '-fillpage')

%% ═══════════════════════════════════════════════════════════════════════════
%  Collect data at target pressure ONCE (used by both scatter figures)
%% ═══════════════════════════════════════════════════════════════════════════
[upSpool, upKvFlow, upKvPiston, downSpool, downKvFlow, downKvPiston] = ...
    collectAtPressure(allRuns, targetPressure, SCATTER_DP_MIN_PA);

%% ═══════════════════════════════════════════════════════════════════════════
%  PLOT 2: Kv vs spool (scatter + polynomial Kv(u))
%% ═══════════════════════════════════════════════════════════════════════════
xFit_u_A = linspace(min(upSpool),   max(upSpool),   300);
xFit_u_B = linspace(min(downSpool), max(downSpool), 300);
KvFitA   = polyval(pA_Kv_of_u_120, xFit_u_A);
KvFitB   = polyval(pB_Kv_of_u_120, xFit_u_B);

hfig = figure('Name','Kv vs spool');
subplot(2,1,1);
scatter(upSpool, upKvFlow   * KvFactor, 3, C_blue, 'filled', 'DisplayName', '$K_v$ flow sensor');
hold on
scatter(upSpool, upKvPiston * KvFactor, 3, C_red,  'filled', 'DisplayName', '$K_v$ piston');
plot(xFit_u_A, KvFitA, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Polynomial fit');
hold off
xlabel('Spool position $u$ (--)')
ylabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port A (Up) $-$ %d bar', targetPressure))
legend('Location', 'northwest');
grid on

subplot(2,1,2);
scatter(downSpool, downKvFlow   * KvFactor, 3, C_blue, 'filled', 'DisplayName', '$K_v$ flow sensor');
hold on
scatter(downSpool, downKvPiston * KvFactor, 3, C_red,  'filled', 'DisplayName', '$K_v$ piston');
plot(xFit_u_B, KvFitB, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Polynomial fit');
hold off
xlabel('Spool position $u$ (--)')
ylabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port B (Down) $-$ %d bar', targetPressure))
legend('Location', 'northwest');
grid on

applyFigureExportTemplate(hfig, EXPORT_picturewidth_cm, EXPORT_hw_ratio, EXPORT_fontsize);
print(hfig, 'kv_spool_scatter', '-dpdf', '-vector', '-fillpage')

%% ═══════════════════════════════════════════════════════════════════════════
%  PLOT 3: u vs Kv (scatter + polynomial u(Kv))
%% ═══════════════════════════════════════════════════════════════════════════
KvFlowUp_plot   = upKvFlow   * KvFactor;
KvPistonUp_plot = upKvPiston * KvFactor;
KvFlowDn_plot   = downKvFlow   * KvFactor;
KvPistonDn_plot = downKvPiston * KvFactor;

xFitKvUp = linspace(prctileFinite([KvFlowUp_plot; KvPistonUp_plot], 1), ...
                    prctileFinite([KvFlowUp_plot; KvPistonUp_plot], 99), 400);
xFitKvDn = linspace(prctileFinite([KvFlowDn_plot; KvPistonDn_plot], 1), ...
                    prctileFinite([KvFlowDn_plot; KvPistonDn_plot], 99), 400);

uFitUp   = polyval(pUp_u_of_Kv_120,   xFitKvUp);
uFitDown = polyval(pDown_u_of_Kv_120, xFitKvDn);

hfig = figure('Name','u vs Kv');
subplot(2,1,1);
scatter(KvFlowUp_plot,   upSpool, 3, C_blue, 'filled', 'DisplayName', '$K_v$ flow sensor');
hold on
scatter(KvPistonUp_plot, upSpool, 3, C_red,  'filled', 'DisplayName', '$K_v$ piston');
plot(xFitKvUp, uFitUp, '-', 'Color', C_black, 'LineWidth', 1.6, 'DisplayName', 'Polynomial fit');
hold off
ylabel('Spool position $u$ (--)')
xlabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port A (Up) $-$ %d bar', targetPressure))
legend('Location', 'northwest');
grid on

subplot(2,1,2);
scatter(KvFlowDn_plot,   downSpool, 3, C_blue, 'filled', 'DisplayName', '$K_v$ flow sensor');
hold on
scatter(KvPistonDn_plot, downSpool, 3, C_red,  'filled', 'DisplayName', '$K_v$ piston');
plot(xFitKvDn, uFitDown, '-', 'Color', C_black, 'LineWidth', 1.6, 'DisplayName', 'Polynomial fit');
hold off
ylabel('Spool position $u$ (--)')
xlabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port B (Down) $-$ %d bar', targetPressure))
legend('Location', 'northwest');
grid on

applyFigureExportTemplate(hfig, EXPORT_picturewidth_cm, EXPORT_hw_ratio, EXPORT_fontsize);
print(hfig, 'u_kv_spool_scatter', '-dpdf', '-vector', '-fillpage')

%% ═══════════════════════════════════════════════════════════════════════════
%  LOCAL FUNCTIONS (keep at end)
%% ═══════════════════════════════════════════════════════════════════════════

function T = loadAndClean(filepath, COL_fU)
    opts = detectImportOptions(filepath, ...
        'Delimiter',          ';',  ...
        'NumHeaderLines',     6,    ...
        'DecimalSeparator',   ',',  ...
        'VariableNamingRule', 'preserve');
    T = readtable(filepath, opts);

    % Remove trailing empty/NaN rows
    T = rmmissing(T, 'MinNumMissing', width(T));

    % Keep data from last timer reset onward
    timeVec  = T{:, 1};
    resetIdx = find(diff(timeVec) < 0);
    if ~isempty(resetIdx)
        T = T(resetIdx(end)+1 : end, :);
    end

    % Remove idle rows where fU == 0
    if ~ismember(COL_fU, T.Properties.VariableNames)
        error('Column "%s" not found. Available: %s', ...
            COL_fU, strjoin(T.Properties.VariableNames, ', '));
    end
    T = T(T{:, COL_fU} ~= 0, :);
end

function [i1, i2] = steadyStateWindow(spool, minFrac)
% Robust steady-state window finder.
% Patch: handle IQR collapse (nearly constant spool at 95–100% signal).
    if nargin < 2; minFrac = 0.10; end

    centre    = median(spool);
    spreadIqr = iqr(spool);

    if spreadIqr < 1e-4
        spreadIqr = std(spool);
    end

    roughBand  = 3 * spreadIqr;
    nearCentre = abs(spool - centre) < roughBand;

    if sum(nearCentre) > 10
        tightBand = 3 * std(spool(nearCentre));
    else
        tightBand = roughBand;
    end

    if tightBand < 1e-4
        tightBand = roughBand;
    end

    inBand = abs(spool - centre) < tightBand;

    starts = find(diff([0; inBand]) ==  1);
    ends   = find(diff([inBand; 0]) == -1);

    if isempty(starts)
        warning('steadyStateWindow: no settled region found, using middle 60%%');
        n  = numel(spool);
        i1 = max(1, round(0.20 * n));
        i2 = min(n, round(0.80 * n));
        return
    end

    [~, best] = max(ends - starts);
    i1 = starts(best);
    i2 = ends(best);

    pct = 100 * (i2 - i1) / numel(spool);
    if pct < minFrac * 100
        warning('steadyStateWindow: settled window is only %.0f%% of data', pct);
    end
end

function applyFigureExportTemplate(hfig, picturewidth, hw_ratio, fontsize)
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', fontsize)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])

    pos = get(hfig,'Position');
    set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters', ...
        'PaperSize',[pos(3), pos(4)])
end

function [upSpool, upKvFlow, upKvPiston, downSpool, downKvFlow, downKvPiston] = ...
    collectAtPressure(allRuns, targetPressure, scatterDpMinPa)

% Collects points at target pressure and (optionally) filters out low dP
% points to avoid Kv distortion from sqrt(dP) being small.

    upSpool = []; upKvFlow = []; upKvPiston = [];
    downSpool = []; downKvFlow = []; downKvPiston = [];

    for i = 1:numel(allRuns)
        if allRuns(i).pressure ~= targetPressure
            continue;
        end

        % PATCH 4: scatter-specific filter
        mask = allRuns(i).validDP & (allRuns(i).dP > scatterDpMinPa);

        if strcmp(allRuns(i).direction, 'Up')
            upSpool    = [upSpool;    allRuns(i).spool(mask)];     %#ok<AGROW>
            upKvFlow   = [upKvFlow;   allRuns(i).Kv_flow(mask)];   %#ok<AGROW>
            upKvPiston = [upKvPiston; allRuns(i).Kv_piston(mask)]; %#ok<AGROW>
        else
            downSpool    = [downSpool;    allRuns(i).spool(mask)];     %#ok<AGROW>
            downKvFlow   = [downKvFlow;   allRuns(i).Kv_flow(mask)];   %#ok<AGROW>
            downKvPiston = [downKvPiston; allRuns(i).Kv_piston(mask)]; %#ok<AGROW>
        end
    end
end

function v = prctileFinite(x, p)
% Safe percentile of finite values (avoids NaN/Inf issues).
    x = x(isfinite(x));
    if isempty(x)
        v = NaN;
        return
    end
    v = prctile(x, p);
end