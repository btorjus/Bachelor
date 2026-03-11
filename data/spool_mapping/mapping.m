clear; close all; clc;

%% ─── Cylinder & Valve Parameters ────────────────────────────────────────────
d   = 65e-3;               % piston diameter            [m]
dr  = 35e-3;               % rod diameter               [m]
A   = pi*d^2/4;            % full-bore piston area      [m^2]
Ar  = pi*dr^2/4;           % rod area                   [m^2]
Aa  = A - Ar;              % annular area               [m^2]

Cd     = 0.55;             % discharge coefficient
Rho    = 875;              % fluid density              [kg/m^3]
Qref   = 18/6e4;           % nominal flow               [m^3/s]
dpref  = 20e5;             % nominal pressure drop      [Pa]

Kv_rated = Qref / dpref;

uminA          =  0.2325;   % deadband limit port A (Up)
uminB          =  0.2175;   % deadband limit port B (Down)
targetPressure = 110; 

%% ─── Data root & folder list ─────────────────────────────────────────────────
dataRoot = '.';            % script lives in data/spool_mapping/

folders = { ...
    fullfile(dataRoot, 'UpDown100Bar040326'), ...
    fullfile(dataRoot, 'UpDown110Bar060326'), ...
    fullfile(dataRoot, 'UpDown120Bar060326')  ...
};

%% ─── Column names (confirmed from CSV header row 7) ─────────────────────────
COL_time     = 'fTimer';            % already in seconds
COL_fU       = 'fU';               % control signal  (0 = idle, !=0 = active)
COL_spool    = 'fSpoolPosition';   % spool position  (-1 = home, then working range)
COL_pSupply  = 'fPsFiltered';      % supply pressure [bar]
COL_pA       = 'fPaFiltered';      % port-A pressure [bar]
COL_pB       = 'fPbFiltered';      % port-B pressure [bar]
COL_pA_lower = 'fPaLowerFiltered'; % lower A pressure [bar]
COL_flow     = 'fFlow';            % flow sensor     [L/min]
COL_position = 'fPistonPosition';  % piston position [m]

%% ─── Helper: load & clean one CSV ───────────────────────────────────────────
function T = loadAndClean(filepath, COL_fU, COL_spool)
    opts = detectImportOptions(filepath, ...
        'Delimiter',          ';',  ...
        'NumHeaderLines',     6,    ...   % rows 1-6 are metadata; row 7 = headers
        'DecimalSeparator',   ',',  ...
        'VariableNamingRule', 'preserve');
    T = readtable(filepath, opts);

    % ── Remove trailing empty/NaN rows ───────────────────────────────────
    T = rmmissing(T, 'MinNumMissing', width(T));

    % ── CLEAN 1: timer-reset marker ──────────────────────────────────────
    % fTimer counts up, then resets to ~0 when the actual test begins.
    % Keep everything from the LAST reset onward.
    timeVec  = T{:, 1};
    resetIdx = find(diff(timeVec) < 0);
    if ~isempty(resetIdx)
        T = T(resetIdx(end)+1 : end, :);
    end

    % ── CLEAN 2: fU != 0 ─────────────────────────────────────────────────
    % Rows where fU == 0 are idle (before/after the spool moves).
    if ismember(COL_fU, T.Properties.VariableNames)
        T = T(T{:, COL_fU} ~= 0, :);
    else
        colNames = strjoin(T.Properties.VariableNames, ', ');
        error('Column "%s" not found.\nAvailable columns: %s', COL_fU, colNames);
    end

    % ── CLEAN 3: remove spool home position (-1) ─────────────────────────
    % Spool starts at -1 (mechanical home) before the stroke begins.
    % Keep only rows where spool has left home. Threshold -0.9 gives
    % margin for sensor noise around -1.
    if ismember(COL_spool, T.Properties.VariableNames)
        T = T(T{:, COL_spool} > -0.9, :);
    else
        colNames = strjoin(T.Properties.VariableNames, ', ');
        error('Column "%s" not found.\nAvailable columns: %s', COL_spool, colNames);
    end
end

%% ─── Load all CSV files from the three UpDown folders ───────────────────────
allRuns = struct( ...
    'folder',    {}, 'filename', {}, ...
    'direction', {}, 'pressure', {}, 'signal', {}, ...
    'data',      {} );

for fi = 1:numel(folders)
    csvFiles = dir(fullfile(folders{fi}, '*.csv'));

    if isempty(csvFiles)
        warning('No CSV files found in: %s', folders{fi});
        continue
    end

    for ci = 1:numel(csvFiles)
        fname = csvFiles(ci).name;

        % Parse direction, nominal pressure, and signal level from filename
        % Pattern: (Up|Down)<P>Bar<S>Signal<date>.csv
        tokens = regexp(fname, '^(Up|Down)(\d+)Bar(\d+)Signal', ...
                        'tokens', 'once');
        if isempty(tokens)
            warning('Skipping unrecognised filename: %s', fname);
            continue
        end

        direction   = tokens{1};
        nomPressure = str2double(tokens{2});   % [bar] — label only
        signal      = str2double(tokens{3});   % [%]

        fullpath = fullfile(folders{fi}, fname);
        fprintf('Loading %s ...\n', fname);
        T = loadAndClean(fullpath, COL_fU, COL_spool);

        entry.folder      = folders{fi};
        entry.filename    = fname;
        entry.direction   = direction;
        entry.pressure    = nomPressure;
        entry.signal      = signal;
        entry.data        = T;
        allRuns(end+1)    = entry;             %#ok<AGROW>
    end
end
fprintf('\nLoaded %d files.\n', numel(allRuns));

%% ─── Compute derived quantities ──────────────────────────────────────────────
for i = 1:numel(allRuns)
    T         = allRuns(i).data;
    direction = allRuns(i).direction;

    % ── Sign convention normalisation ────────────────────────────────────
    % Down: spool > 0, flow > 0  → keep as-is
    % Up:   spool < 0, flow < 0  → flip both so active stroke is positive
    if strcmp(direction, 'Up')
        T{:, COL_flow}     = -T{:, COL_flow};
        T{:, COL_position} = -T{:, COL_position};
        T{:, COL_spool}    = -T{:, COL_spool};
    end

    % ── Time ────────────────────────────────────────────────────────────
    t = T{:, COL_time};                % [s]

    % ---Spool pos -------------------------------------------------
    spool = T{:, COL_spool};                % [-1 to 1]

    % ── Pressures: bar → Pa ──────────────────────────────────────────────
    pS_Pa = T{:, COL_pSupply} * 1e5;  % supply pressure   [Pa]
    pA_Pa = T{:, COL_pA}      * 1e5;  % port-A pressure   [Pa]
    pB_Pa = T{:, COL_pB}      * 1e5;  % port-B pressure   [Pa]

    % ── Pressure drop across the valve ───────────────────────────────────
    % Up   stroke: valve feeds port A (full bore side)
    % Down stroke: valve feeds port B (annular / rod side)
    if strcmp(direction, 'Up')
        dP = pS_Pa - pA_Pa;
    else
        dP = pS_Pa - pB_Pa;
    end
    dP = max(dP, 0);                   % clamp negatives (sensor noise)

    % ── Flow sensor: L/min → m³/s ────────────────────────────────────────
    % abs() kept as safety net for residual noise-driven sign flips near zero
    Q_sensor = abs(T{:, COL_flow}) / 60000;   % [m^3/s]

    % ── Piston velocity from position (central finite difference) ─────────
    pos = T{:, COL_position};          % [m]  — already sign-corrected above
    vel = gradient(pos, t);            % [m/s]

    % ── Flow from piston kinematics ───────────────────────────────────────
    % Up   stroke: fluid enters full-bore side  → Q = A  * v
    % Down stroke: fluid enters annular side    → Q = Aa * v
    if strcmp(direction, 'Up')
        Q_piston = A  * vel;
    else
        Q_piston = Aa * vel;
    end

    % ── Kv from flow sensor ───────────────────────────────────────────────
    Kv_flow   = Q_sensor  ./ sqrt(dP + eps);  % [m^3/s / Pa^0.5]

    % ── Kv from piston kinematics ─────────────────────────────────────────
    Kv_piston = abs(Q_piston)  ./ sqrt(dP + eps);  % [m^3/s / Pa^0.5]

    % ── Smooth Kv_piston ─────────────────────────────────────────────────
    % Savitzky-Golay: preserves peaks better than Gaussian
    % window must be odd, order must be < window
    window = 51;   % number of samples — increase for more smoothing
    order  = 3;    % polynomial order  — 3 or 4 works well
    Kv_piston_smooth = sgolayfilt(Kv_piston, order, window);



    % ── Store ─────────────────────────────────────────────────────────────
    allRuns(i).t          = t;
    allRuns(i).spool      = spool;
    allRuns(i).pS_Pa      = pS_Pa;
    allRuns(i).pA_Pa      = pA_Pa;
    allRuns(i).pB_Pa      = pB_Pa;
    allRuns(i).dP         = dP;
    allRuns(i).Q_sensor   = Q_sensor;
    allRuns(i).Q_piston   = Q_piston;
    allRuns(i).vel        = vel;
    allRuns(i).Kv_flow    = Kv_flow;
    allRuns(i).Kv_piston  = Kv_piston;
    allRuns(i).Kv_piston_smooth = Kv_piston_smooth;
end

fprintf('Derived quantities computed for all %d runs.\n', numel(allRuns));

%% ─── Quick test plot ─────────────────────────────────────────────────────────
% Change these indices to inspect different runs
runIdx = [1, 26, 3];

figure;
for k = 1:numel(runIdx)
    i = runIdx(k);
    t         = allRuns(i).t;
    Kv_flow   = allRuns(i).Kv_flow;
    Kv_piston = allRuns(i).Kv_piston_smooth;

    titleStr = sprintf('%s | %d bar | %d%% signal', ...
        allRuns(i).direction, allRuns(i).pressure, allRuns(i).signal);

    subplot(numel(runIdx), 1, k);
    plot(t, Kv_flow,   'b-', 'DisplayName', 'Kv flow sensor');
    hold on
    plot(t, Kv_piston, 'r-', 'DisplayName', 'Kv piston');
    hold off
    xlabel('Time [s]')
    ylabel('Kv [m^3/s / Pa^{0.5}]')
    title(titleStr)
    legend
    grid on
end


%% ─── Kv vs instantaneous spool position at 110 bar ──────────────────────────

targetPressure = 110;

% ── Collect all samples per direction ────────────────────────────────────────
upSpool_all   = []; upKvFlow_all   = []; upKvPiston_all   = [];
downSpool_all = []; downKvFlow_all = []; downKvPiston_all = [];

for i = 1:numel(allRuns)
    if allRuns(i).pressure ~= targetPressure
        continue
    end

    if strcmp(allRuns(i).direction, 'Up')
        upSpool_all      = [upSpool_all;      allRuns(i).spool];
        upKvFlow_all     = [upKvFlow_all;     allRuns(i).Kv_flow];
        upKvPiston_all   = [upKvPiston_all;   allRuns(i).Kv_piston_smooth];
    else
        downSpool_all    = [downSpool_all;    allRuns(i).spool];
        downKvFlow_all   = [downKvFlow_all;   allRuns(i).Kv_flow];
        downKvPiston_all = [downKvPiston_all; allRuns(i).Kv_piston_smooth];
    end
end

% ── Plot ──────────────────────────────────────────────────────────────────────
factor = 6e4 / sqrt(1e-5); % liter per min / bar^0.5

figure;

% Port A — Up
subplot(2,1,1);
scatter(upSpool_all, upKvFlow_all * factor,   2, 'b', 'filled', 'DisplayName', 'Kv flow sensor');
hold on
scatter(upSpool_all, upKvPiston_all * factor, 2, 'r', 'filled', 'DisplayName', 'Kv piston');
xline(uminA, 'k--', sprintf('Deadband = %.4f', uminA), 'DisplayName', 'Deadband');
hold off
xlabel('Spool position [-]')
ylabel('Kv [l/min / Bar^{0.5}]')
title(sprintf('Port A (Up) — %d bar | instantaneous', targetPressure))
legend
grid on

% Port B — Down
subplot(2,1,2);
scatter(downSpool_all, downKvFlow_all * factor,   2, 'b', 'filled', 'DisplayName', 'Kv flow sensor');
hold on
scatter(downSpool_all, downKvPiston_all * factor, 2, 'r', 'filled', 'DisplayName', 'Kv piston');
xline(uminB, 'k--', sprintf('Deadband = %.4f', uminB), 'DisplayName', 'Deadband');
hold off
xlabel('Spool position [-]')
ylabel('Kv [l/min / Bar^{0.5}]')
title(sprintf('Port B (Down) — %d bar | instantaneous', targetPressure))
legend
grid on

% må fjerne der vi ramper opp!! og husk at den skal stoppe når vi begynner
% å lukke 