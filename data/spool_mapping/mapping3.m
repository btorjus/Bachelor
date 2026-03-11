clear; close all; clc;

%% ─── Cylinder & Valve Parameters ────────────────────────────────────────────
d   = 65e-3;               % piston diameter            [m]
dr  = 35e-3;               % rod diameter               [m]
A   = pi*d^2/4;            % full-bore piston area      [m^2]
Ar  = pi*dr^2/4;           % rod area                   [m^2]
Aa  = A - Ar;              % annular area               [m^2]

Rho    = 875;              % fluid density              [kg/m^3]
Qref   = 18/6e4;           % nominal flow               [m^3/s]
dpref  = 20e5;             % nominal pressure drop      [Pa]
phi    = Aa / A;           % area ratio                 [-]

%% ─── Processing Parameters ───────────────────────────────────────────────────
SPOOL_HOME_THRESHOLD = -0.9;   % below this = spool at home position
DP_MIN_PA            = 1e5;    % min valid pressure drop [Pa] (1 bar)
VEL_SMOOTH_SPAN      = 80;     % smoothing window for velocity [samples]

%% ─── Unit Conversion ─────────────────────────────────────────────────────────
% m³/s/Pa^0.5 → L/min/bar^0.5
factor = 6e4 / sqrt(1e-5);

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

%% ─── Mapping Parameters ──────────────────────────────────────────────────────
uminA          =  0.2325;   % deadband limit port A (Up)   [-]
uminB          =  0.2175;   % deadband limit port B (Down) [-]
targetPressure = 120;       % pressure to use for scatter plot [bar]


%% ─── Load and clean one CSV ──────────────────────────────────────────────────
function T = loadAndClean(filepath, COL_fU)
% Loads a CSV and applies signal-independent cleaning:
%   1. Remove trailing empty rows
%   2. Keep data from last timer reset onward (start of actual test)
%   3. Remove idle rows where fU == 0

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

    % Remove idle rows
    if ~ismember(COL_fU, T.Properties.VariableNames)
        error('Column "%s" not found. Available: %s', ...
            COL_fU, strjoin(T.Properties.VariableNames, ', '));
    end
    T = T(T{:, COL_fU} ~= 0, :);
end

%% ─── Find steady-state window ────────────────────────────────────────────────
function [i1, i2] = steadyStateWindow(spool, minFrac)
% Finds the longest contiguous block where the spool is within a band
% around its median. Band width is derived from the IQR of samples
% already near the median — making it robust to start/end transients.
%
%   minFrac : warn if steady window is less than this fraction of data

    if nargin < 2; minFrac = 0.10; end

    % First pass: rough band to identify steady-state samples
    centre    = median(spool);
    roughBand = 3 * iqr(spool);
    nearCentre = abs(spool - centre) < roughBand;

    % Second pass: tighten band using only the near-centre samples
    if sum(nearCentre) > 10
        tightBand = 3 * std(spool(nearCentre));
    else
        tightBand = roughBand;
    end

    inBand = abs(spool - centre) < tightBand;

    % Find longest contiguous block inside band
    starts = find(diff([0; inBand]) ==  1);
    ends   = find(diff([inBand; 0]) == -1);

    if isempty(starts)
        warning('steadyStateWindow: no settled region found, using middle 60%%');
        n  = numel(spool);
        i1 = round(0.20 * n);
        i2 = round(0.80 * n);
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

%%  LOAD ALL CSV FILES
allRuns = struct( ...
    'folder',    {}, 'filename', {}, ...
    'direction', {}, 'pressure', {}, 'signal', {}, ...
    'data',      {});

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

        direction   = tokens{1};
        nomPressure = str2double(tokens{2});
        signal      = str2double(tokens{3});

        fprintf('Loading %s ...\n', fname);
        T = loadAndClean(fullfile(folders{fi}, fname), COL_fU);

        entry.folder    = folders{fi};
        entry.filename  = fname;
        entry.direction = direction;
        entry.pressure  = nomPressure;
        entry.signal    = signal;
        entry.data      = T;
        allRuns(end+1)  = entry; %#ok<AGROW>
    end
end
fprintf('\nLoaded %d runs.\n', numel(allRuns));

%%  DIAGNOSTIC: raw spool — one Up and one Down

idxUp   = find(strcmp({allRuns.direction}, 'Up'),   1);
idxDown = find(strcmp({allRuns.direction}, 'Down'), 1);

figure('Name', 'Diagnostic — raw spool');
for k = 1:2
    idx = [idxUp, idxDown];
    subplot(2,1,k)
    plot(allRuns(idx(k)).data{:, COL_spool})
    title(sprintf('RAW  %s | %d bar | %d%%', ...
        allRuns(idx(k)).direction, allRuns(idx(k)).pressure, allRuns(idx(k)).signal))
    ylabel('Spool [-]'); xlabel('Sample index')
    grid on
end

%%  COMPUTE DERIVED QUANTITIES

for i = 1:numel(allRuns)
    T         = allRuns(i).data;
    direction = allRuns(i).direction;

    % ── 1. Sign convention: flip Up so active stroke is positive ─────────
    if strcmp(direction, 'Up')
        T{:, COL_flow}     = -T{:, COL_flow};
        T{:, COL_position} = -T{:, COL_position};
        T{:, COL_spool}    = -T{:, COL_spool};
    end

    % ── 2. Remove home position (after flip so Up is not clipped) ────────
    T = T(T{:, COL_spool} > SPOOL_HOME_THRESHOLD, :);

    % ── 3. Trim to steady-state spool window ─────────────────────────────
    [i1, i2] = steadyStateWindow(T{:, COL_spool});
        
    fprintf('  Run %2d: %-5s | %3d bar | %3d%% signal  →  window i1=%d i2=%d (%.0f%% of data)\n',i, direction, allRuns(i).pressure, allRuns(i).signal, i1, i2, 100*(i2-i1)/height(T));
    
    T        = T(i1:i2, :);

    % ── 4. Extract raw signals ────────────────────────────────────────────
    t     = T{:, COL_time};
    spool = T{:, COL_spool};
    pS_Pa = T{:, COL_pSupply} * 1e5;
    pA_Pa = T{:, COL_pA}      * 1e5;
    pB_Pa = T{:, COL_pB}      * 1e5;

    % ── 5. Pressure drop across DCV ───────────────────────────────────────
    % Up:   supply → DCV → flow sensor → CBV → bore side
    % Down: supply → DCV → annular side
    if strcmp(direction, 'Up')
        dP = pS_Pa - pA_Pa;
    else
        dP = pS_Pa - pB_Pa;
    end
    dP = max(dP, 0);

    % ── 6. Valid pressure drop mask ───────────────────────────────────────
    % Exclude samples where dP is too small — Kv is meaningless there
    validDP = dP > DP_MIN_PA;

    % ── 7. Flow sensor → m³/s ────────────────────────────────────────────
    % Sensor is always on bore side (between DCV and CBV).
    % Up:   sensor measures bore inlet flow directly
    % Down: sensor measures bore return flow → scale to annular inlet
    Q_sensor_raw = abs(T{:, COL_flow}) / 60000;
    if strcmp(direction, 'Up')
        Q_sensor = Q_sensor_raw ./ phi;
    else
        Q_sensor = Q_sensor_raw;   % Lag QA og QB
    end

    % ── 8. Piston velocity (smoothed) and kinematic flow ─────────────────
    pos = T{:, COL_position};
    vel = smoothdata(gradient(pos, t), 'sgolay', VEL_SMOOTH_SPAN);

    if strcmp(direction, 'Up')
        Q_piston = A  * vel;
    else
        Q_piston = Aa * vel;
    end
% lag q A og q B

    % ── 9. Kv (only where dP is valid) ───────────────────────────────────
    Kv_flow   = nan(size(dP));
    Kv_piston = nan(size(dP));
    Kv_flow(validDP)   = Q_sensor(validDP)          ./ sqrt(dP(validDP));
    Kv_piston(validDP) = abs(Q_piston(validDP))     ./ sqrt(dP(validDP));

    % ── Store ─────────────────────────────────────────────────────────────
    allRuns(i).t                = t;
    allRuns(i).spool            = spool;
    allRuns(i).pS_Pa            = pS_Pa;
    allRuns(i).pA_Pa            = pA_Pa;
    allRuns(i).pB_Pa            = pB_Pa;
    allRuns(i).dP               = dP;
    allRuns(i).validDP          = validDP;
    allRuns(i).Q_sensor         = Q_sensor;
    allRuns(i).Q_piston         = Q_piston;
    allRuns(i).vel              = vel;
    allRuns(i).Kv_flow          = Kv_flow;
    allRuns(i).Kv_piston        = Kv_piston;
end
fprintf('Derived quantities computed for all %d runs.\n', numel(allRuns));


%%  QUICK TEST PLOT — time series for 3 selected runs
C_red    = [249. 38. 114]./255; 
C_blue   = [129. 154. 255]./255; 
C_green  = [166. 226. 46]./255;   
C_magenta = [174. 129. 255]./255;
C_black = [51. 51. 51]./255;

runIdx       = [1, 10, 26];
picturewidth = 20;
hw_ratio     = 0.85;

hfig = figure;
for k = 1:numel(runIdx)
    i = runIdx(k);
    subplot(numel(runIdx), 1, k);
    plot(allRuns(i).t, allRuns(i).Kv_flow          * factor, ...
        '-', 'Color', C_blue,   'LineWidth', 1.5, 'DisplayName', '$K_v$ flow sensor');
    hold on
    plot(allRuns(i).t, allRuns(i).Kv_piston * factor, ...
        '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$K_v$ piston');
    hold off
    xlabel('Time $t$ (s)')
    ylabel('$K_v$ (L/min/bar$^{0.5}$)')
    title(sprintf('%s $|$ %d bar $|$ %d\\%% signal', ...
        allRuns(i).direction, allRuns(i).pressure, allRuns(i).signal))
    legend('Location', 'northwest');
end

set(findall(hfig, '-property', 'FontSize'),             'FontSize',            11)
set(findall(hfig, '-property', 'Box'),                  'Box',                 'off')
set(findall(hfig, '-property', 'Interpreter'),          'Interpreter',         'latex')
set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter','latex')
set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', ...
    'PaperSize', [picturewidth, hw_ratio*picturewidth])
print(hfig, 'kv_timeseries', '-dpdf', '-vector', '-fillpage')

%%  SCATTER: Kv vs instantaneous spool position

% Port A (Up) 120 bar
pA_pol_120 = [0.25826, 13.257, -20.0668, 12.1981, -1.9583];

% Port B (Down) 120 bar
pB_pol_120 = [-9.3594, 32.8145, -32.2028, 14.7576, -1.9876];

upSpool_all   = []; upKvFlow_all   = []; upKvPiston_all   = [];
downSpool_all = []; downKvFlow_all = []; downKvPiston_all = [];

for i = 1:numel(allRuns)
    if allRuns(i).pressure ~= targetPressure; continue; end

    if strcmp(allRuns(i).direction, 'Up')
        upSpool_all    = [upSpool_all;    allRuns(i).spool];             %#ok<AGROW>
        upKvFlow_all   = [upKvFlow_all;   allRuns(i).Kv_flow];           %#ok<AGROW>
        upKvPiston_all = [upKvPiston_all; allRuns(i).Kv_piston];  %#ok<AGROW>
    else
        downSpool_all    = [downSpool_all;    allRuns(i).spool];              %#ok<AGROW>
        downKvFlow_all   = [downKvFlow_all;   allRuns(i).Kv_flow];            %#ok<AGROW>
        downKvPiston_all = [downKvPiston_all; allRuns(i).Kv_piston];   %#ok<AGROW>
    end
end

% Fit evaluation vectors
xFitA = linspace(min(upSpool_all),   max(upSpool_all),   300);
xFitB = linspace(min(downSpool_all), max(downSpool_all), 300);
KvFitA = polyval(pA_pol_120, xFitA);
KvFitB = polyval(pB_pol_120, xFitB);

picturewidth = 20;
hw_ratio     = 0.65;

hfig = figure;

subplot(2,1,1);
scatter(upSpool_all, upKvFlow_all   * factor, 3, C_blue,   'filled', 'DisplayName', '$K_v$ flow sensor');
hold on
scatter(upSpool_all, upKvPiston_all * factor, 3, C_red, 'filled', 'DisplayName', '$K_v$ piston ');
plot(xFitA, KvFitA, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Polynomial fit');
hold off
xlabel('Spool position (--)')
ylabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port A (Up) $-$ %d bar', targetPressure))
legend('Location', 'northwest');

subplot(2,1,2);
scatter(downSpool_all, downKvFlow_all   * factor, 3, C_blue,   'filled', 'DisplayName', '$K_v$ flow sensor');
hold on
scatter(downSpool_all, downKvPiston_all * factor, 3, C_red, 'filled', 'DisplayName', '$K_v$ piston');
plot(xFitB, KvFitB, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Polynomial fit');
hold off
xlabel('Spool position (--)')
ylabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port B (Down) $-$ %d bar', targetPressure))
legend('Location', 'northwest');

set(findall(hfig, '-property', 'FontSize'),             'FontSize',             11)
set(findall(hfig, '-property', 'Box'),                  'Box',                  'off')
set(findall(hfig, '-property', 'Interpreter'),          'Interpreter',          'latex')
set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', ...
    'PaperSize', [picturewidth, hw_ratio*picturewidth])
print(hfig, 'kv_spool_scatter', '-dpdf', '-vector', '-fillpage')




% må ha polynom for u ikke kv

%%  SCATTER: Kv vs instantaneous spool position

upSpool_all   = []; upKvFlow_all   = []; upKvPiston_all   = [];
downSpool_all = []; downKvFlow_all = []; downKvPiston_all = [];

for i = 1:numel(allRuns)
    if allRuns(i).pressure ~= targetPressure; continue; end

    if strcmp(allRuns(i).direction, 'Up')
        upSpool_all    = [upSpool_all;    allRuns(i).spool];             %#ok<AGROW>
        upKvFlow_all   = [upKvFlow_all;   allRuns(i).Kv_flow];           %#ok<AGROW>
        upKvPiston_all = [upKvPiston_all; allRuns(i).Kv_piston];  %#ok<AGROW>
    else
        downSpool_all    = [downSpool_all;    allRuns(i).spool];              %#ok<AGROW>
        downKvFlow_all   = [downKvFlow_all;   allRuns(i).Kv_flow];            %#ok<AGROW>
        downKvPiston_all = [downKvPiston_all; allRuns(i).Kv_piston];   %#ok<AGROW>
    end
end


picturewidth = 20;
hw_ratio     = 0.65;

hfig = figure;

subplot(2,1,1);
scatter(upKvFlow_all   * factor, upSpool_all, 3, C_blue,   'filled', 'DisplayName', '$K_v$ flow sensor');
hold on
scatter(upKvPiston_all * factor, upSpool_all, 3, C_red, 'filled', 'DisplayName', '$K_v$ piston ');
hold off
ylabel('Spool position (--)')
xlabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port A (Up) $-$ %d bar', targetPressure))
legend('Location', 'northwest');

subplot(2,1,2);
scatter(downKvFlow_all   * factor, downSpool_all, 3, C_blue,   'filled', 'DisplayName', '$K_v$ flow sensor');
hold on
scatter(downKvPiston_all * factor, downSpool_all, 3, C_red, 'filled', 'DisplayName', '$K_v$ piston');
hold off
ylabel('Spool position (--)')
xlabel('$K_v$ (L/min/bar$^{0.5}$)')
title(sprintf('Port B (Down) $-$ %d bar', targetPressure))
legend('Location', 'northwest');

set(findall(hfig, '-property', 'FontSize'),             'FontSize',             11)
set(findall(hfig, '-property', 'Box'),                  'Box',                  'off')
set(findall(hfig, '-property', 'Interpreter'),          'Interpreter',          'latex')
set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', ...
    'PaperSize', [picturewidth, hw_ratio*picturewidth])
print(hfig, 'u_kv_spool_scatter', '-dpdf', '-vector', '-fillpage')