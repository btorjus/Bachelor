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

phi = Aa/A;

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
COL_pSupply  = 'fPs'; %prøver pa lower isteden og uten filter på alle
COL_pA       = 'fPaLower';
COL_pB       = 'fPb';
COL_flow     = 'fFlow';
COL_position = 'fPistonPosition';

%% ─── Helper: find steady-state spool window ─────────────────────────────────
function [i1, i2] = steadyStateWindow(spool, minFrac)
    if nargin < 2; minFrac = 0.10; end

    centre    = median(spool);
    band      = 3 * iqr(spool);        % adaptive width based on data spread
    inBand    = abs(spool - centre) < band;

    starts = find(diff([0; inBand]) ==  1);
    ends   = find(diff([inBand; 0]) == -1);

    if isempty(starts)
        warning('No steady-state window found, falling back to middle 60%%');
        n  = numel(spool);
        i1 = round(0.20 * n);
        i2 = round(0.80 * n);
        return
    end

    [~, best] = max(ends - starts);
    i1 = starts(best);
    i2 = ends(best);

    if (i2 - i1) / numel(spool) < minFrac
        warning('Steady-state window is very short (%.0f%% of data)', ...
            100 * (i2 - i1) / numel(spool));
    end
end

%% ─── Helper: load & clean one CSV ───────────────────────────────────────────
function T = loadAndClean(filepath, COL_fU, COL_spool)
    opts = detectImportOptions(filepath, ...
        'Delimiter',          ';',  ...
        'NumHeaderLines',     6,    ...
        'DecimalSeparator',   ',',  ...
        'VariableNamingRule', 'preserve');
    T = readtable(filepath, opts);

    % Remove trailing empty rows
    T = rmmissing(T, 'MinNumMissing', width(T));

    % CLEAN 1: keep data from last timer reset onward
    timeVec  = T{:, 1};
    resetIdx = find(diff(timeVec) < 0);
    if ~isempty(resetIdx)
        T = T(resetIdx(end)+1 : end, :);
    end

    % CLEAN 2: remove idle rows (fU == 0)
    if ismember(COL_fU, T.Properties.VariableNames)
        T = T(T{:, COL_fU} ~= 0, :);
    else
        error('Column "%s" not found. Available: %s', ...
            COL_fU, strjoin(T.Properties.VariableNames, ', '));
    end


end

%% ─── Load all CSV files ──────────────────────────────────────────────────────
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
        T = loadAndClean(fullfile(folders{fi}, fname), COL_fU, COL_spool);

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

%% ─── DIAGNOSTIC: plot raw spool for first few runs ──────────────────────────
figure;
for k = 1:min(4, numel(allRuns))
    subplot(2,2,k)
    plot(allRuns(k).data{:, COL_spool})
    title(sprintf('%s | %d bar | %d%%', ...
        allRuns(k).direction, allRuns(k).pressure, allRuns(k).signal))
    ylabel('Spool [-]'); xlabel('Sample index')
    grid on
end

%% ─── Compute derived quantities ──────────────────────────────────────────────
for i = 1:numel(allRuns)
    T         = allRuns(i).data;
    direction = allRuns(i).direction;

    % ── Sign convention: flip Up runs so active stroke is positive ────────
    if strcmp(direction, 'Up')
        T{:, COL_flow}     = -T{:, COL_flow};
        T{:, COL_position} = -T{:, COL_position};
        T{:, COL_spool}    = -T{:, COL_spool};
    end
    
    % ── Remove home position AFTER flip so Up runs are not clipped ────────
    T = T(T{:, COL_spool} > -0.9, :);

    % ── Trim to steady-state spool window ─────────────────────────────────
    [i1, i2] = steadyStateWindow(T{:, COL_spool});
    T        = T(i1:i2, :);

    % ── Extract signals ───────────────────────────────────────────────────
    t     = T{:, COL_time};
    spool = T{:, COL_spool};
    pS_Pa = T{:, COL_pSupply} * 1e5;
    pA_Pa = T{:, COL_pA}      * 1e5;
    pB_Pa = T{:, COL_pB}      * 1e5;

    % ── Pressure drop across valve ────────────────────────────────────────
    if strcmp(direction, 'Up')
        dP = pS_Pa - pA_Pa;
    else
        dP = pS_Pa - pB_Pa;
    end
    dP = max(dP, 0);

    % ── Flow sensor: L/min → m³/s ─────────────────────────────────────────
    Q_sensor = abs(T{:, COL_flow}) / 60000;

    % ── Piston velocity and flow from kinematics ──────────────────────────
    pos = T{:, COL_position};
    vel = gradient(pos, t);

    if strcmp(direction, 'Up')
        Q_piston = A  * vel;
    else
        Q_piston = Aa * vel;
    end

    % ── Kv ───────────────────────────────────────────────────────────────
    Kv_flow   = Q_sensor       ./ sqrt(dP + eps);
    Kv_piston = abs(Q_piston)  ./ sqrt(dP + eps);

    % ── Smooth Kv_piston (Savitzky-Golay) ────────────────────────────────
    Kv_piston_smooth = smoothdata(Kv_piston, 'sgolay', 51);

    % ── Store ─────────────────────────────────────────────────────────────
    allRuns(i).t                 = t;
    allRuns(i).spool             = spool;
    allRuns(i).pS_Pa             = pS_Pa;
    allRuns(i).pA_Pa             = pA_Pa;
    allRuns(i).pB_Pa             = pB_Pa;
    allRuns(i).dP                = dP;
    allRuns(i).Q_sensor          = Q_sensor;
    allRuns(i).Q_piston          = Q_piston;
    allRuns(i).vel               = vel;
    allRuns(i).Kv_flow           = Kv_flow;
    allRuns(i).Kv_piston         = Kv_piston;
    allRuns(i).Kv_piston_smooth  = Kv_piston_smooth;
end
fprintf('Derived quantities computed for all %d runs.\n', numel(allRuns));

%% ─── Conversion factor: m³/s/Pa^0.5 → L/min/bar^0.5 ────────────────────────
factor = 6e4 / sqrt(1e-5);

%% ─── Mapping parameters ──────────────────────────────────────────────────────
uminA          =  0.2325;   % deadband limit port A (Up)
uminB          =  0.2175;   % deadband limit port B (Down)
targetPressure = 120;

%% ─── Quick test plot ─────────────────────────────────────────────────────────
runIdx = [1, 10, 26];

figure;
for k = 1:numel(runIdx)
    i         = runIdx(k);
    t         = allRuns(i).t;
    Kv_flow   = allRuns(i).Kv_flow;
    Kv_piston = allRuns(i).Kv_piston_smooth;

    subplot(numel(runIdx), 1, k);
    plot(t, Kv_flow   * factor, 'b-', 'DisplayName', 'Kv flow sensor');
    hold on
    plot(t, Kv_piston * factor, 'k-', 'DisplayName', 'Kv piston smooth');
    hold off
    xlabel('Time [s]')
    ylabel('Kv [L/min/bar^{0.5}]')
    title(sprintf('%s | %d bar | %d%% signal', ...
        allRuns(i).direction, allRuns(i).pressure, allRuns(i).signal))
    legend; grid on
end

%% ─── Kv vs instantaneous spool position ─────────────────────────────────────
upSpool_all   = []; upKvFlow_all   = []; upKvPiston_all   = [];
downSpool_all = []; downKvFlow_all = []; downKvPiston_all = [];

for i = 1:numel(allRuns)
    if allRuns(i).pressure ~= targetPressure; continue; end

    if strcmp(allRuns(i).direction, 'Up')
        upSpool_all    = [upSpool_all;    allRuns(i).spool];
        upKvFlow_all   = [upKvFlow_all;   allRuns(i).Kv_flow];
        upKvPiston_all = [upKvPiston_all; allRuns(i).Kv_piston_smooth];
    else
        downSpool_all    = [downSpool_all;    allRuns(i).spool];
        downKvFlow_all   = [downKvFlow_all;   allRuns(i).Kv_flow];
        downKvPiston_all = [downKvPiston_all; allRuns(i).Kv_piston_smooth];
    end
end

figure;

subplot(2,1,1);
scatter(upSpool_all, upKvFlow_all   * factor, 2, 'b', 'filled', 'DisplayName', 'Kv flow sensor');
hold on
scatter(upSpool_all, upKvPiston_all * factor, 2, 'k', 'filled', 'DisplayName', 'Kv piston smooth');
xline(uminA, 'k--', sprintf('Deadband = %.4f', uminA));
hold off
xlabel('Spool position [-]')
ylabel('Kv [L/min/bar^{0.5}]')
title(sprintf('Port A (Up) — %d bar | instantaneous', targetPressure))
legend; grid on

subplot(2,1,2);
scatter(downSpool_all, downKvFlow_all   * factor, 2, 'b', 'filled', 'DisplayName', 'Kv flow sensor');
hold on
scatter(downSpool_all, downKvPiston_all * factor, 2, 'k', 'filled', 'DisplayName', 'Kv piston smooth');
xline(uminB, 'k--', sprintf('Deadband = %.4f', uminB));
hold off
xlabel('Spool position [-]')
ylabel('Kv [L/min/bar^{0.5}]')
title(sprintf('Port B (Down) — %d bar | instantaneous', targetPressure))
legend; grid on