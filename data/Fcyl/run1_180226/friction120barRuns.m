%% Friction identification from UpDown characterisation runs
clear; clc; close all;

%% Paths
dataRoot = '../../spool_mapping';
folders  = { fullfile(dataRoot, 'UpDown120Bar060326') };

%% Cylinder geometry
d_piston = 0.065;
d_rod    = 0.035;
A_piston = pi*(d_piston/2)^2;
A_rod    = pi*(d_rod/2)^2;
A_a      = A_piston - A_rod;

%% Beam / gravity load parameters (from validated run 1 model)
m_beam = 415.74;
g      = 9.81;
x_c    = 3.21615;
y_c    = 0.06148;
r_top  = [0.547; -0.133];
r_bot  = [0.427; -1.057];
h      = 0.772;                         % cylinder closed length [m]

%% Settings
T1 = 1.0;   T2 = 1.7;                   % extraction window [s]
VEL_SMOOTH_METHOD = 'sgolay';
VEL_SMOOTH_SPAN   = 80;

COL_time     = 'fTimer';
COL_fU       = 'fU';
COL_pA       = 'fPaLower';
COL_pB       = 'fPb';
COL_position = 'fPistonPosition';

C_red  = [0.9490, 0.1020, 0.0000];
C_blue = [0.2314, 0.6039, 0.6980];

%% Precompute theoretical F_cyl(L) for interpolation
theta = deg2rad(linspace(-16.6, 30, 1000));
F_cyl_theo = zeros(size(theta));
L_cyl_theo = zeros(size(theta));
for i = 1:length(theta)
    R = [cos(theta(i)) -sin(theta(i)); sin(theta(i)) cos(theta(i))];
    r_top_global = R * r_top;
    phi_i = atan2(r_top_global(2) - r_bot(2), r_top_global(1) - r_bot(1));
    ma = r_top_global(1)*sin(phi_i) - r_top_global(2)*cos(phi_i);
    F_cyl_theo(i) = m_beam * g * (x_c*cos(theta(i)) - y_c*sin(theta(i))) / ma;
    L_cyl_theo(i) = sqrt((r_top_global(1)-r_bot(1))^2 + (r_top_global(2)-r_bot(2))^2);
end
[L_cyl_theo, iu] = unique(L_cyl_theo);
F_cyl_theo       = F_cyl_theo(iu);

%% Load all runs and build friction scatter
v_all   = [];
Ff_all  = [];
dir_all = [];
run_info = struct('direction',{},'pressure',{},'signal',{}, ...
                  'v_mean',{},'Ff_mean',{});

for fi = 1:numel(folders)
    csvFiles = dir(fullfile(folders{fi}, '*.csv'));
    for ci = 1:numel(csvFiles)
        fname = csvFiles(ci).name;
        tok = regexp(fname, '^(Up|Down)(\d+)Bar(\d+)Signal', 'tokens', 'once');
        if isempty(tok), continue; end
        direction = tok{1};
        pressure  = str2double(tok{2});
        signal    = str2double(tok{3});

        T = loadAndClean(fullfile(folders{fi}, fname), COL_fU);

        % Extraction window
        tAll = T{:,COL_time};
        T = T((tAll >= T1) & (tAll <= T2), :);
        if height(T) < 20, continue; end

        t   = T{:,COL_time};
        pA  = T{:,COL_pA} * 1e5;
        pB  = T{:,COL_pB} * 1e5;
        pos = T{:,COL_position};        % raw, NOT flipped

        % Cylinder length (same convention as run 1)
        L = pos + h;

        % Hydraulic force with standard sign convention
        % (positive = extension, i.e. pushing rod out)
        F_hyd = pA*A_piston - pB*A_a;

        % Velocity in cylinder-length coordinates
        Ldot = smoothdata(gradient(L, t), VEL_SMOOTH_METHOD, VEL_SMOOTH_SPAN);

        % Load force from validated gravity model
        F_load = interp1(L_cyl_theo, F_cyl_theo, L, 'linear', NaN);

        % Friction per sample
        F_fric = F_hyd - F_load;

        % Drop any out-of-range (L outside theoretical sweep)
        good = isfinite(F_fric) & isfinite(Ldot);
        v_all   = [v_all;   Ldot(good)];       %#ok<AGROW>
        Ff_all  = [Ff_all;  F_fric(good)];     %#ok<AGROW>
        dir_all = [dir_all; repmat(string(direction), sum(good), 1)]; %#ok<AGROW>

        % Per-run plateau summary (mean over window)
        run_info(end+1) = struct( ...
            'direction', direction, 'pressure', pressure, 'signal', signal, ...
            'v_mean',    mean(Ldot(good),'omitnan'), ...
            'Ff_mean',   mean(F_fric(good),'omitnan')); %#ok<AGROW>
    end
end
fprintf('Loaded %d runs, %d friction samples total.\n', ...
    numel(run_info), numel(v_all));

%% Coulomb + viscous fit on all samples
v_min_fit = 5e-3;   % drop near-zero velocity from fit (deadband / transients)
m = abs(v_all) > v_min_fit;
X = [sign(v_all(m)), v_all(m)];
coef = X \ Ff_all(m);
Fc = coef(1);
b  = coef(2);
fprintf('\nFriction fit (all runs, |v|>%g mm/s):\n', v_min_fit*1e3);
fprintf('  F_C = %.1f N\n', Fc);
fprintf('  b   = %.1f N/(m/s)\n', b);

% Direction-split
mE = m & v_all >  0;
mR = m & v_all <  0;
cE = [ones(sum(mE),1), v_all(mE)] \ Ff_all(mE);
cR = [ones(sum(mR),1), v_all(mR)] \ Ff_all(mR);
fprintf('  Extension:  F_C0 = %+7.1f N, b = %7.1f N/(m/s)\n', cE(1), cE(2));
fprintf('  Retraction: F_C0 = %+7.1f N, b = %7.1f N/(m/s)\n', cR(1), cR(2));

%% Plot 1 — raw sample scatter + fit
hfig1 = figure;
plot(v_all*1e3, Ff_all/1000, '.', 'Color', [0.6 0.6 0.6], ...
     'MarkerSize', 3, 'DisplayName', 'samples'); hold on;
v_fit = linspace(min(v_all(m)), max(v_all(m)), 400)';
Ff_fit = Fc*sign(v_fit) + b*v_fit;
plot(v_fit*1e3, Ff_fit/1000, '-', 'Color', C_red, 'LineWidth', 1.5, ...
     'DisplayName', '$F_C\,$sign$(\dot L) + b\,\dot L$');
xlabel('$\dot L$ [mm/s]');
ylabel('$F_\mathrm{fric}$ [kN]');
legend('Location','northwest','Interpreter','latex');
grid off;
applyFigureExportTemplate(hfig1, 20, 0.65, 17);
% print(hfig1, 'friction_updown_scatter', '-dpdf', '-vector', '-fillpage')

%% Plot 2 — per-run plateau means (cleaner view)
v_run  = [run_info.v_mean];
Ff_run = [run_info.Ff_mean];
isUp   = strcmp({run_info.direction}, 'Up');

hfig2 = figure;
plot(v_run(isUp)*1e3,  Ff_run(isUp)/1000,  'o', ...
    'MarkerFaceColor', C_blue, 'MarkerEdgeColor', C_blue, ...
    'DisplayName', 'Up (extension)'); hold on;
plot(v_run(~isUp)*1e3, Ff_run(~isUp)/1000, 's', ...
    'MarkerFaceColor', C_red, 'MarkerEdgeColor', C_red, ...
    'DisplayName', 'Down (retraction)');
plot(v_fit*1e3, Ff_fit/1000, '-k', 'LineWidth', 1.5, ...
    'DisplayName', 'Coulomb + viscous fit');
xlabel('$\dot L$ [mm/s]');
ylabel('$F_\mathrm{fric}$ [kN]');
legend('Location','northwest','Interpreter','latex');
grid off;
applyFigureExportTemplate(hfig2, 20, 0.65, 17);
% print(hfig2, 'friction_updown_plateau', '-dpdf', '-vector', '-fillpage')

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