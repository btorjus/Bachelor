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

%% ─── Data root & folder list ─────────────────────────────────────────────────
dataRoot = fullfile('data', 'spool_mapping');

folders = { ...
    fullfile(dataRoot, 'UpDown100Bar040326'), ...
    fullfile(dataRoot, 'UpDown110Bar060326'), ...
    fullfile(dataRoot, 'UpDown120Bar060326')  ...
};

%% ─── Column names (confirmed from CSV header row 7) ─────────────────────────
COL_time     = 'fTimer';            % already in seconds
COL_fU       = 'fU';               % test-active flag  (0 = idle, != 0 = test)
COL_pSupply  = 'fPsFiltered';      % supply pressure   [bar]
COL_pA       = 'fPaFiltered';      % port-A pressure   [bar]
COL_pB       = 'fPbFiltered';      % port-B pressure   [bar]
COL_pA_lower = 'fPaLowerFiltered'; % lower A pressure  [bar]
COL_flow     = 'fFlow';            % flow sensor       [L/min]
COL_position = 'fPistonPosition';  % piston position   [m]

%% ─── Helper: load & clean one CSV ───────────────────────────────────────────
function T = loadAndClean(filepath, COL_fU)
    opts = detectImportOptions(filepath, ...
        'Delimiter',          ';',  ...
        'NumHeaderLines',     6,    ...   % rows 1-6 are metadata; row 7 = headers
        'DecimalSeparator',   ',',  ...
        'VariableNamingRule', 'preserve');
    T = readtable(filepath, opts);

    % ── Remove trailing empty/NaN rows that some exports append ──────────
    T = rmmissing(T, 'MinNumMissing', width(T));

    % ── CLEAN 1: timer-reset marker ──────────────────────────────────────
    % fTimer counts up from some arbitrary offset, then resets to ~0 when
    % the actual test begins.  Keep everything from the LAST reset onward.
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
end

%% ─── Load all CSV files from the three UpDown folders ───────────────────────
allRuns = struct( ...
    'folder',    {}, 'filename', {}, ...
    'direction', {}, 'pressure', {}, 'signal', {}, ...
    'data',      {} );

for fi = 1:numel(folders)
    csvFiles = dir(fullfile(folders{fi}, '*.csv'));

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

        direction    = tokens{1};
        nomPressure  = str2double(tokens{2});   % [bar] — label only
        signal       = str2double(tokens{3});   % [%]

        fullpath = fullfile(folders{fi}, fname);
        fprintf('Loading %s ...\n', fname);
        T = loadAndClean(fullpath, COL_fU);

        entry.folder      = folders{fi};
        entry.filename    = fname;
        entry.direction   = direction;
        entry.pressure    = nomPressure;   % nominal [bar], for labelling
        entry.signal      = signal;
        entry.data        = T;
        allRuns(end+1)    = entry;         %#ok<AGROW>
    end
end
fprintf('\nLoaded %d files.\n', numel(allRuns));

%% ─── Compute derived quantities ──────────────────────────────────────────────
for i = 1:numel(allRuns)
    T         = allRuns(i).data;
    direction = allRuns(i).direction;

    % ── Time ─────────────────────────────────────────────────────────────
    t = T{:, COL_time};                % [s]  — fTimer is already seconds

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
    Q_sensor_m3s = abs(T{:, COL_flow}) / 60000;   % [m^3/s]

    % ── Kv from flow sensor ───────────────────────────────────────────────
    % Kv = Q / sqrt(dP)   [m^3/s / Pa^0.5]
    Kv_flow = Q_sensor_m3s ./ sqrt(dP + eps);

    % ── Piston velocity from position (central finite difference) ─────────
    pos = T{:, COL_position};          % [m]
    dt  = mean(diff(t));               % actual mean sample interval [s]
    vel = gradient(pos, t);            % [m/s]  — uses actual non-uniform t

    % ── Flow from piston kinematics ───────────────────────────────────────
    % Up   stroke: fluid enters full-bore side  → Q = A  * v
    % Down stroke: fluid enters annular side    → Q = Aa * v
    if strcmp(direction, 'Up')
        Q_piston = A  * vel;
    else
        Q_piston = Aa * vel;
    end

    % ── Store ─────────────────────────────────────────────────────────────
    allRuns(i).t          = t;
    allRuns(i).pS_Pa      = pS_Pa;
    allRuns(i).pA_Pa      = pA_Pa;
    allRuns(i).pB_Pa      = pB_Pa;
    allRuns(i).dP         = dP;
    allRuns(i).Q_sensor   = Q_sensor_m3s;
    allRuns(i).Kv_flow    = Kv_flow;
    allRuns(i).vel        = vel;
    allRuns(i).Q_piston   = Q_piston;
end

fprintf('Derived quantities computed for all %d runs.\n', numel(allRuns));