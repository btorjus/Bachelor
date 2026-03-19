clear; close all; clc;

%% Cylinder geometry
d   = 65e-3;
dr  = 35e-3;
A   = pi*d^2/4;
Ar  = pi*dr^2/4;
Aa  = A - Ar;
phi = Aa/A;

%% Settings
T1 = 1.0;   % [s] window start
T2 = 1.7;   % [s] window end

DP_MIN_PA         = 1e5;   % 1 bar
SCATTER_DP_MIN_PA = 3e5;   % 3 bar (scatter only)

VEL_SMOOTH_METHOD = 'sgolay';
VEL_SMOOTH_SPAN   = 80;

DEBUG_RUN = 28;   % [] to disable

Kv_display_factor = 6e4 / sqrt(1e-5);   % m³/s/Pa^0.5 → L/min/bar^0.5

%% Folders
dataRoot = '.';
folders = { ...
    fullfile(dataRoot, 'UpDown100Bar040326'), ...
    fullfile(dataRoot, 'UpDown110Bar060326'), ...
    fullfile(dataRoot, 'UpDown120Bar060326')  ...
};

%% Column names
COL_time     = 'fTimer';
COL_fU       = 'fU';
COL_spool    = 'fSpoolPosition';
COL_pSupply  = 'fPs';
COL_pA       = 'fPaLower';
COL_pB       = 'fPb';
COL_flow     = 'fFlow';
COL_position = 'fPistonPosition';

%% Plot settings
targetPressure  = 120;
C_red           = [249,  38, 114] ./ 255;
C_blue          = [129, 154, 255] ./ 255;
C_black         = [ 51,  51,  51] ./ 255;
picturewidth    = 20;
EXPORT_fontsize = 11;

%% Polynomial fits (120 bar)
pA_Kv_of_spool_120 = [ 0.25826,  13.257,  -20.0668,  12.1981, -1.9583];
pB_Kv_of_spool_120 = [-9.3594,   32.8145, -32.2028,  14.7576, -1.9876];

pUp_spool_of_Kv_120   = [0.0018653, -0.033672,  0.22033, -0.65618,  0.83411, -0.047269, 0.26252];
pDown_spool_of_Kv_120 = [0.00098272, -0.017507,  0.11599, -0.34851,  0.41222,  0.17643,  0.2076];

%% Load all runs
allRuns = struct('folder',{},'filename',{},'direction',{},'pressure',{},'signal',{},'data',{});
for fi = 1:numel(folders)
    csvFiles = dir(fullfile(folders{fi}, '*.csv'));
    for ci = 1:numel(csvFiles)
        clear entry
        fname = csvFiles(ci).name;
        tok   = regexp(fname, '^(Up|Down)(\d+)Bar(\d+)Signal', 'tokens', 'once');
        if isempty(tok), continue; end

        entry.folder    = folders{fi};
        entry.filename  = fname;
        entry.direction = tok{1};
        entry.pressure  = str2double(tok{2});
        entry.signal    = str2double(tok{3});
        entry.data      = loadAndClean(fullfile(folders{fi}, fname), COL_fU);

        allRuns(end+1) = entry; %#ok<AGROW>
    end
end
fprintf('Loaded %d runs.\n', numel(allRuns));
fprintf('Geometry: A=%.6g, Aa=%.6g, phi=%.4f\n', A, Aa, phi);

%% Process runs
for i = 1:numel(allRuns)
    T    = allRuns(i).data;
    dirn = allRuns(i).direction;

    % Flip Up so active motion is positive
    if strcmp(dirn,'Up')
        T{:,COL_position} = -T{:,COL_position};
        T{:,COL_spool}    = -T{:,COL_spool};
    end

    % Timer window
    tAll = T{:,COL_time};
    T    = T((tAll >= T1) & (tAll <= T2), :);

    t     = T{:,COL_time};
    spool = T{:,COL_spool};
    pS    = T{:,COL_pSupply} * 1e5;
    pA    = T{:,COL_pA}      * 1e5;
    pB    = T{:,COL_pB}      * 1e5;

    if strcmp(dirn,'Up'), dP = pS - pA; else, dP = pS - pB; end
    dP      = max(dP, 0);
    validDP = dP > DP_MIN_PA;

    % Flow sensor is on the annular line
    Q_ann_meas = abs(T{:,COL_flow}) / 60000;
    if strcmp(dirn,'Up')
        Q_valve_est = Q_ann_meas / phi;
    else
        Q_valve_est = Q_ann_meas;
    end

    % Piston kinematics
    pos     = T{:,COL_position};
    vel     = smoothdata(gradient(pos, t), VEL_SMOOTH_METHOD, VEL_SMOOTH_SPAN);
    if strcmp(dirn,'Up'), Q_piston = A*vel; else, Q_piston = Aa*vel; end

    % Kv
    Kv_flow   = nan(size(dP));
    Kv_piston = nan(size(dP));
    Kv_flow(validDP)   = Q_valve_est(validDP)   ./ sqrt(dP(validDP));
    Kv_piston(validDP) = abs(Q_piston(validDP)) ./ sqrt(dP(validDP));

    allRuns(i).data        = [];   % free raw table
    allRuns(i).t           = t;
    allRuns(i).spool       = spool;
    allRuns(i).dP          = dP;
    allRuns(i).validDP     = validDP;
    allRuns(i).Q_ann_meas  = Q_ann_meas;
    allRuns(i).Q_valve_est = Q_valve_est;
    allRuns(i).Q_piston    = Q_piston;
    allRuns(i).vel         = vel;
    allRuns(i).Kv_flow     = Kv_flow;
    allRuns(i).Kv_piston   = Kv_piston;
end

%% Debug plot
if ~isempty(DEBUG_RUN)
    r = allRuns(DEBUG_RUN);

    hfig = figure('Name', sprintf('DEBUG run %d', DEBUG_RUN));
    tiledlayout(4,1,'TileSpacing','compact','Padding','compact');

    nexttile
    plot(r.t, r.spool, 'Color', C_black, 'LineWidth', 1.2); grid on
    ylabel('Spool position (norm.)')
    title(sprintf('Run %d: %s | %d bar | %d\\%% | window %.1f--%.1f s', ...
        DEBUG_RUN, r.direction, r.pressure, r.signal, T1, T2))

    nexttile
    plot(r.t, r.dP/1e5, 'Color', C_black, 'LineWidth', 1.2); grid on
    ylabel('$\Delta p$ (bar)')

    nexttile
    plot(r.t, r.Q_valve_est*6e4, '-',  'Color', C_blue,  'LineWidth', 1.2, 'DisplayName', '$Q$ sensor $\rightarrow Q_\mathrm{valve}$'); hold on
    plot(r.t, abs(r.Q_piston)*6e4, '-','Color', C_red,   'LineWidth', 1.2, 'DisplayName', '$Q$ piston');
    plot(r.t, r.Q_ann_meas*6e4,   '--','Color', C_black, 'LineWidth', 1.0, 'DisplayName', '$Q$ sensor (annular)');
    hold off; ylabel('$Q$ (L/min)'); grid on; legend('Location','northwest');

    nexttile
    m = r.validDP & isfinite(r.Kv_flow) & isfinite(r.Kv_piston);
    plot(r.t(m), r.Kv_flow(m)*Kv_display_factor,   '-','Color', C_blue, 'LineWidth', 1.2, 'DisplayName', '$K_v$ flow');   hold on
    plot(r.t(m), r.Kv_piston(m)*Kv_display_factor, '-','Color', C_red,  'LineWidth', 1.2, 'DisplayName', '$K_v$ piston'); hold off
    ylabel('$K_v$ (L/min/bar$^{0.5}$)'); xlabel('Timer $t$ (s)'); grid on; legend('Location','northwest');

    applyFigureExportTemplate(hfig, picturewidth, 0.85, EXPORT_fontsize);
end

%% Plot 1 — Kv time series
runIdx = [1, 10, 26];
hfig = figure('Name','Kv time series');
for k = 1:numel(runIdx)
    i = runIdx(k);
    subplot(numel(runIdx), 1, k);
    plot(allRuns(i).t, allRuns(i).Kv_flow*Kv_display_factor,   '-','Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$K_v$ flow');   hold on
    plot(allRuns(i).t, allRuns(i).Kv_piston*Kv_display_factor, '-','Color', C_red,  'LineWidth', 1.5, 'DisplayName', '$K_v$ piston'); hold off
    xlabel('Timer $t$ (s)'); ylabel('$K_v$ (L/min/bar$^{0.5}$)')
    title(sprintf('%s $|$ %d bar $|$ %d\\%% signal', allRuns(i).direction, allRuns(i).pressure, allRuns(i).signal))
    legend('Location','northwest'); grid on
end
applyFigureExportTemplate(hfig, picturewidth, 0.85, EXPORT_fontsize);
print(hfig, 'kv_timeseries', '-dpdf', '-vector', '-fillpage')

%% Collect scatter data at target pressure
[upSpool, upKvF, upKvP, dnSpool, dnKvF, dnKvP] = collectAtPressure(allRuns, targetPressure, SCATTER_DP_MIN_PA);

%% Plot 2 — Kv vs spool position
hfig = figure('Name','Kv vs spool position');

subplot(2,1,1);
scatter(upSpool, upKvF*Kv_display_factor, 3, C_blue, 'filled', 'DisplayName', '$K_v$ flow'); hold on
scatter(upSpool, upKvP*Kv_display_factor, 3, C_red,  'filled', 'DisplayName', '$K_v$ piston');
xFit = linspace(min(upSpool), max(upSpool), 300);
plot(xFit, polyval(pA_Kv_of_spool_120, xFit), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Polynomial fit');
hold off; grid on
xlabel('Spool position (norm.)'); ylabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port A (Up) $-$ %d bar', targetPressure)); legend('Location','northwest');

subplot(2,1,2);
scatter(dnSpool, dnKvF*Kv_display_factor, 3, C_blue, 'filled', 'DisplayName', '$K_v$ flow'); hold on
scatter(dnSpool, dnKvP*Kv_display_factor, 3, C_red,  'filled', 'DisplayName', '$K_v$ piston');
xFit = linspace(min(dnSpool), max(dnSpool), 300);
plot(xFit, polyval(pB_Kv_of_spool_120, xFit), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Polynomial fit');
hold off; grid on
xlabel('Spool position (norm.)'); ylabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port B (Down) $-$ %d bar', targetPressure)); legend('Location','northwest');

applyFigureExportTemplate(hfig, picturewidth, 0.65, EXPORT_fontsize);
print(hfig, 'kv_spool_scatter', '-dpdf', '-vector', '-fillpage')

%% Plot 3 — Spool position vs Kv (inverse map)
hfig = figure('Name','Spool position vs Kv');

subplot(2,1,1);
scatter(upKvF*Kv_display_factor, upSpool, 3, C_blue, 'filled', 'DisplayName', '$K_v$ flow'); hold on
scatter(upKvP*Kv_display_factor, upSpool, 3, C_red,  'filled', 'DisplayName', '$K_v$ piston');
xFit = linspace(prctileFinite([upKvF;upKvP]*Kv_display_factor,1), prctileFinite([upKvF;upKvP]*Kv_display_factor,99), 400);
plot(xFit, polyval(pUp_spool_of_Kv_120, xFit), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Polynomial fit');
hold off; grid on
xlabel('$K_v$ (L/min/bar$^{0.5}$)'); ylabel('Spool position (norm.)')
title(sprintf('Port A (Up) $-$ %d bar', targetPressure)); legend('Location','northwest');

subplot(2,1,2);
scatter(dnKvF*Kv_display_factor, dnSpool, 3, C_blue, 'filled', 'DisplayName', '$K_v$ flow'); hold on
scatter(dnKvP*Kv_display_factor, dnSpool, 3, C_red,  'filled', 'DisplayName', '$K_v$ piston');
xFit = linspace(prctileFinite([dnKvF;dnKvP]*Kv_display_factor,1), prctileFinite([dnKvF;dnKvP]*Kv_display_factor,99), 400);
plot(xFit, polyval(pDown_spool_of_Kv_120, xFit), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Polynomial fit');
hold off; grid on
xlabel('$K_v$ (L/min/bar$^{0.5}$)'); ylabel('Spool position (norm.)')
title(sprintf('Port B (Down) $-$ %d bar', targetPressure)); legend('Location','northwest');

applyFigureExportTemplate(hfig, picturewidth, 0.65, EXPORT_fontsize);
print(hfig, 'spool_kv_scatter', '-dpdf', '-vector', '-fillpage')

%% Local functions
function T = loadAndClean(filepath, COL_fU)
    opts = detectImportOptions(filepath, ...
        'Delimiter', ';', 'NumHeaderLines', 6, ...
        'DecimalSeparator', ',', 'VariableNamingRule', 'preserve');
    T = readtable(filepath, opts);
    T = rmmissing(T, 'MinNumMissing', width(T));

    timeVec  = T{:,1};
    resetIdx = find(diff(timeVec) < 0);
    if ~isempty(resetIdx)
        T = T(resetIdx(end)+1:end, :);
    end

    if ~ismember(COL_fU, T.Properties.VariableNames)
        error('Column "%s" not found. Available: %s', COL_fU, strjoin(T.Properties.VariableNames, ', '));
    end
    T = T(T{:,COL_fU} ~= 0, :);
end

function applyFigureExportTemplate(hfig, picturewidth, hw_ratio, fontsize)
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', fontsize)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', ...
        'PaperSize', [picturewidth, hw_ratio*picturewidth])
end

function [upSpool, upKvF, upKvP, dnSpool, dnKvF, dnKvP] = collectAtPressure(allRuns, targetPressure, scatterDpMinPa)
    upSpool=[]; upKvF=[]; upKvP=[];
    dnSpool=[]; dnKvF=[]; dnKvP=[];
    for i = 1:numel(allRuns)
        if allRuns(i).pressure ~= targetPressure, continue; end
        mask = allRuns(i).validDP & (allRuns(i).dP > scatterDpMinPa);
        if strcmp(allRuns(i).direction,'Up')
            upSpool = [upSpool; allRuns(i).spool(mask)];     %#ok<AGROW>
            upKvF   = [upKvF;   allRuns(i).Kv_flow(mask)];   %#ok<AGROW>
            upKvP   = [upKvP;   allRuns(i).Kv_piston(mask)]; %#ok<AGROW>
        else
            dnSpool = [dnSpool; allRuns(i).spool(mask)];     %#ok<AGROW>
            dnKvF   = [dnKvF;   allRuns(i).Kv_flow(mask)];   %#ok<AGROW>
            dnKvP   = [dnKvP;   allRuns(i).Kv_piston(mask)]; %#ok<AGROW>
        end
    end
end

function v = prctileFinite(x, p)
    x = x(isfinite(x));
    if isempty(x), v = NaN; else, v = prctile(x, p); end
end