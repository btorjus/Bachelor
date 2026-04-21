%% Hand calc comparison with run 1
clear; clc; close all;

C_red    = [0.9490, 0.1020, 0.0000];
C_blue   = [0.2314, 0.6039, 0.6980];
C_lblue  = [0.4706, 0.7176, 0.7725];
C_yellow = [0.9216, 0.8000, 0.1647];
C_orange = [0.8824, 0.6863, 0.0000];
C_black  = [0.1608, 0.1294, 0.1216];

% Astroid city
C_teal   = [13, 166, 151]./255;    % #0DA697
C_olive  = [119, 140, 74]./255;    % #778C4A
C_sand   = [217, 185, 126]./255;   % #D9B97E
C_brown  = [191, 129, 75]./255;    % #BF814B
C_rust   = [217, 68, 35]./255;     % #D94423

% Load sensor data
load FF_ramp_96bar_run1_bachelorship.mat

%% Cylinder dimensions
d_piston = 0.065;                      % Piston diameter [m]
d_rod    = 0.035;                      % Rod diameter [m]
A_piston = pi*(d_piston/2)^2;          % Piston area [m^2]
A_rod    = pi*(d_rod/2)^2;             % Rod area [m^2]
A_a      = A_piston - A_rod;           % Ring side area [m^2]

%% Sensor data
piston_pos = data{14}.extractTimetable;
pA_filter  = data{8}.extractTimetable;
pB_filter  = data{12}.extractTimetable;

p_A = pA_filter.Variables * 1e5;        % Pressure side A [Pa]
p_B = pB_filter.Variables * 1e5;        % Pressure side B [Pa]
F_hyd = p_A * A_piston - p_B * A_a;     % Measured hydraulic force [N]

% Total cylinder length = h + piston travel
h = 0.772;                              % Cylinder closed length (h) [m]
L_cyl_meas = piston_pos.Variables + h;  % Measured cylinder length [m]

% Cut at index 6102 (cylinder bottoms out)
n_cut = 6102;
L_cyl_meas = L_cyl_meas(1:n_cut);
F_hyd      = F_hyd(1:n_cut);

%% Beam and geometry parameters
m_beam  = 415.74;                       % Beam mass [kg] (CAD 415.74kg)
g       = 9.81;                         % Gravitational acceleration [m/s^2]
x_c     = 3.21615;                      % COM in x direction local [m] (CAD 3.01315m)
y_c     = 0.06148;                      % COM in y direction local [m]
r_top   = [0.547; -0.133];             % Cylinder top mount in beam coords [m]
r_bot   = [0.427; -1.057];             % Cylinder bottom mount in global coords [m]
L_min   = 0.772;                        % Min cylinder length [m]
L_max   = 1.272;                        % Max cylinder length [m]

%% Theoretical cylinder force
theta = deg2rad(linspace(-16.6, 30, 400));

F_cyl_theo = zeros(size(theta));
L_cyl_theo = zeros(size(theta));
for i = 1:length(theta)
    R = [cos(theta(i)) -sin(theta(i)); sin(theta(i)) cos(theta(i))];
    r_top_global = R * r_top;
    phi = atan2(r_top_global(2) - r_bot(2), r_top_global(1) - r_bot(1));
    moment_arm = r_top_global(1)*sin(phi) - r_top_global(2)*cos(phi);
    F_cyl_theo(i) = m_beam * g * ( x_c * cos(theta(i)) - y_c * sin(theta(i)) ) / moment_arm;
    L_cyl_theo(i) = sqrt((r_top_global(1)-r_bot(1))^2 + (r_top_global(2)-r_bot(2))^2);
end

%% Plot 1 — Raw force comparison
hfig1 = figure;

plot(L_cyl_meas, F_hyd/1000, 'k-', 'LineWidth', 1.5, 'DisplayName', '$F_{hyd}$ (measured)'); hold on;
plot(L_cyl_theo, F_cyl_theo/1000, '--', 'color', C_red, 'LineWidth', 1.5, 'DisplayName', '$F_{cyl}$ (theoretical)');
xlabel('Cylinder length [m]');
ylabel('Force [kN]');
legend('Location','northeast');
grid off;

fname = 'run1_180226_plot';
picturewidth = 20; hw_ratio = 0.65;
set(findall(hfig1,'-property','FontSize'),'FontSize',17)
set(findall(hfig1,'-property','Box'),'Box','off')
set(findall(hfig1,'-property','Interpreter'),'Interpreter','latex')
set(findall(hfig1,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig1,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig1,'Position');
set(hfig1,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
%print(hfig1,fname,'-dpdf','-vector','-fillpage')

%% Plot 2 — Smoothed force comparison
F_smooth_movmean = smoothdata(F_hyd, 'movmean', 80);
F_smooth_gauss   = smoothdata(F_hyd, 'gaussian', 120);
F_smooth_sgolay  = smoothdata(F_hyd, 'sgolay', 80);

hfig2 = figure;

plot(L_cyl_meas, F_hyd/1000, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5, 'DisplayName', '$F_{hyd}$ (raw)');
hold on;

% plot(L_cyl_meas, F_smooth_movmean/1000, ...
%     'b-', 'LineWidth', 1.5, ...
%     'DisplayName', '$F_{hyd}$ (movmean)');

plot(L_cyl_meas, F_smooth_gauss/1000, 'k-', 'LineWidth', 1.5, 'DisplayName', '$F_{hyd}$ (gaussian)');

% plot(L_cyl_meas, F_smooth_sgolay/1000, ...
%     'g-', 'LineWidth', 1.5, ...
%     'DisplayName', '$F_{hyd}$ (sgolay)');

plot(L_cyl_theo, F_cyl_theo/1000, '--', 'color', C_red, 'LineWidth', 1.5, 'DisplayName', '$F_{cyl}$ (theoretical)');

xlabel('Cylinder length [m]');
ylabel('Force [kN]');
legend('Location','northeast');
grid off;

fname = 'run1_smoothed_comparison';
picturewidth = 20; hw_ratio = 0.65;
set(findall(hfig2,'-property','FontSize'),'FontSize',17)
set(findall(hfig2,'-property','Box'),'Box','off')
set(findall(hfig2,'-property','Interpreter'),'Interpreter','latex')
set(findall(hfig2,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig2,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig2,'Position');
set(hfig2,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig2,fname,'-dpdf','-vector','-fillpage')

%% Extension/retraction split and midline check
% L_cyl_meas and F_hyd already cover the full up+down stroke (1:n_cut)

t = seconds(piston_pos.Time(1:n_cut) - piston_pos.Time(1));

L_s  = smoothdata(L_cyl_meas, 'gaussian', 150);
F_s  = smoothdata(F_hyd,      'gaussian', 150);
Ldot = gradient(L_s, t);

v_thr = 1e-3;                       % [m/s] — tune from a plot of Ldot
ext = Ldot >  v_thr;
ret = Ldot < -v_thr;

%% Velocity check (debug)
hfig_dbg = figure;
plot(t, Ldot, 'k', 'LineWidth', 1.2); hold on;
yline(v_thr, 'b--', 'v_{thr} (Extension)');
yline(-v_thr, 'r--', '-v_{thr} (Retraction)');
yline(140e-3, 'g:', 'v_{plateau} (Ext)');
yline(-160e-3, 'g:', '-v_{plateau} (Ret)');
xlabel('Time [s]');
ylabel('Velocity [m/s]');
grid on;

%% Midline computation
% Common L grid where both branches exist
L_grid = linspace(max(min(L_s(ext)), min(L_s(ret))), ...
                  min(max(L_s(ext)), max(L_s(ret))), 400)';

F_ext = interp1(L_s(ext), F_s(ext), L_grid, 'linear');
F_ret = interp1(L_s(ret), F_s(ret), L_grid, 'linear');
F_mid      = 0.5*(F_ext + F_ret);
F_fric_est = 0.5*(F_ext - F_ret);

%% Plot 3 — Extension/retraction with midline
hfig3 = figure;

plot(L_s(ext), F_s(ext)/1000, '--k', 'LineWidth', 1.5, 'DisplayName', '$F_{hyd}$ extension');
hold on;
plot(L_s(ret), F_s(ret)/1000, '-k', 'LineWidth', 1.5, 'DisplayName', '$F_{hyd}$ retraction');
plot(L_grid, F_mid/1000, ':k', 'LineWidth', 1.5, 'DisplayName', '$F_\mathrm{mid}(L)$');
plot(L_cyl_theo, F_cyl_theo/1000, '--', 'Color', C_rust, 'LineWidth', 1.5, 'DisplayName', '$F_\mathrm{cyl}(L)$');
xlabel('Cylinder length [m]');
ylabel('Force [kN]');
legend('Location','northeast');
grid off;

fname = 'extension_retraction_midline';
picturewidth = 20; hw_ratio = 0.65;
set(findall(hfig3,'-property','FontSize'),'FontSize',17)
set(findall(hfig3,'-property','Box'),'Box','off')
set(findall(hfig3,'-property','Interpreter'),'Interpreter','latex')
set(findall(hfig3,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig3,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig3,'Position');
set(hfig3,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig3,fname,'-dpdf','-vector','-fillpage')

F_theo_on_grid = interp1(L_cyl_theo, F_cyl_theo, L_grid, 'linear', 'extrap');
fprintf('Mean (midline - theory) = %.1f N\n', mean(F_mid - F_theo_on_grid, 'omitnan'));
fprintf('Mean friction estimate  = %.1f N\n', mean(F_fric_est, 'omitnan'));

%% Friction identification (plateau averaging)

% F_load_samp = interp1(L_grid, F_mid, L_s, 'linear', NaN);       % midline reference
F_load_samp = interp1(L_cyl_theo, F_cyl_theo, L_s, 'linear', NaN); % hand-calc reference
F_fric_samp = F_s - F_load_samp;

% Keep only samples inside the L overlap region
in_overlap = L_s >= min(L_grid) & L_s <= max(L_grid);

% Position window to crop out acceleration/cushioning zones
L_min_flat = 0.95;  % [m] Start of the steady sliding zone
L_max_flat = 1.15;  % [m] End of the steady sliding zone
in_flat_region = (L_s >= L_min_flat) & (L_s <= L_max_flat);

% Separate velocity thresholds for ext/ret plateaus
v_plateau_ext = 140e-3;  % [m/s] just below max extension speed
v_plateau_ret = 160e-3;  % [m/s] just below max retraction speed (positive number)

% Masks for steady-state motion AND steady-state position
mask_ext = in_overlap & in_flat_region & (Ldot > v_plateau_ext);
mask_ret = in_overlap & in_flat_region & (Ldot < -v_plateau_ret);
mask = mask_ext | mask_ret;

% Extract valid steady-state data
v_steady  = Ldot(mask);
Ff_steady = F_fric_samp(mask);
L_steady  = L_s(mask);

% Average Coulomb friction for both directions
idx_ext = v_steady > 0;
idx_ret = v_steady < 0;

F_fric_ext_mean = mean(Ff_steady(idx_ext), 'omitnan');
% Note: Retraction friction is naturally negative (opposes negative velocity).
% We take the absolute value so we can compare the magnitudes side-by-side.
F_fric_ret_mean = mean(abs(Ff_steady(idx_ret)), 'omitnan');

fprintf('\nFriction results (steady-state plateau averaging):\n');
fprintf('  Extension Coulomb  = %.1f N\n', F_fric_ext_mean);
fprintf('  Retraction Coulomb = %.1f N\n', F_fric_ret_mean);
fprintf('  Symmetric average  = %.1f N\n', 0.5*(F_fric_ext_mean + F_fric_ret_mean));

%% Plot 4 — Friction vs position
hfig4 = figure;

plot(L_steady(idx_ext), Ff_steady(idx_ext)/1000, '-', 'Color', C_teal, 'LineWidth', 1.5, 'DisplayName', 'Extension friction');
hold on;
plot(L_steady(idx_ret), abs(Ff_steady(idx_ret))/1000, '-', 'Color', C_olive, 'LineWidth', 1.5, 'DisplayName', 'Retraction friction (abs)');
yline(F_fric_ext_mean/1000, '--', 'Color', C_rust, 'LineWidth', 1.5, 'DisplayName', 'Avg extension');
yline(F_fric_ret_mean/1000, '--', 'Color', C_brown, 'LineWidth', 1.5, 'DisplayName', 'Avg retraction');
xlabel('Cylinder length [m]');
ylabel('$F_\mathrm{fric}$ [kN]');
legend('Location','best');
grid off;

fname = 'run1_friction_vs_position';
picturewidth = 20; hw_ratio = 0.65;
set(findall(hfig4,'-property','FontSize'),'FontSize',17)
set(findall(hfig4,'-property','Box'),'Box','off')
set(findall(hfig4,'-property','Interpreter'),'Interpreter','latex')
set(findall(hfig4,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig4,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig4,'Position');
set(hfig4,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig4,fname,'-dpdf','-vector','-fillpage')