
%% Hand calc comparison with run 1
clear; clc; close all;

C_red    = '#f21a00'; 
C_blue   = '#3b9ab2'; 
C_lblue  = '#78b7c5';   
C_yellow = '#ebcc2a';
C_orange = '#e1af00';
C_red    = '#f21a00';

% Load sensor data
load FF_ramp_96bar_run1_bachelorship.mat

% Cylinder dimensions
d_piston = 0.065;                      % Piston diameter [m]
d_rod    = 0.035;                      % Rod diameter [m]
A_piston = pi*(d_piston/2)^2;          % Piston area [m^2]
A_rod    = pi*(d_rod/2)^2;             % Rod area [m^2]
A_a      = A_piston - A_rod;           % Ring side area [m^2]

% Sensor data
piston_pos = data{14}.extractTimetable;
pA_filter  = data{8}.extractTimetable;
pB_filter  = data{12}.extractTimetable;

p_A = pA_filter.Variables * 1e5;        % Pressure side A [Pa]
p_B = pB_filter.Variables * 1e5;        % Pressure side B [Pa]
F_hyd = p_A * A_piston - p_B * A_a;     % Measured hydraulic force [N]

% Total cylinder length = h + piston travel
h = 0.772;                              % Cylinder closed length (h) [m]
L_cyl_meas = piston_pos.Variables + h;  % Measured cylinder length [m]

% Cut at index 6165 (cylinder bottoms out)
n_cut = 6165;
L_cyl_meas = L_cyl_meas(1:n_cut);
F_hyd      = F_hyd(1:n_cut);

% Beam and geometry parameters
m_beam  = 415.74;                       % Beam mass [kg] Øke for å få fikse (CAD 415.74kg)
g       = 9.81;                         % Gravitational acceleration [m/s^2]
x_c     = 3.21615;                      % COM in x direction local [m] (CAD 3.01315m)
y_c     = 0.06148;                      % COM in y direction local [m]
r_top   = [0.547; -0.133];             % Cylinder top mount in beam coords [m]
r_bot   = [0.427; -1.057];             % Cylinder bottom mount in global coords [m]
L_min   = 0.772;                        % Min cylinder length [m]
L_max   = 1.272;                        % Max cylinder length [m]

% Sweep beam angle
theta = deg2rad(linspace(-16.6, 30, 400));

% Compute theoretical cylinder force and length
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

% Plot
hfig = figure;

plot(L_cyl_meas, F_hyd/1000, 'k-', 'LineWidth', 1.5, 'DisplayName', '$F_{hyd}$ (measured)'); hold on;
plot(L_cyl_theo, F_cyl_theo/1000, '--', 'color', C_red, 'LineWidth', 1.5, 'DisplayName', '$F_{cyl}$ (theoretical)');
xlabel('Cylinder length [m]');
ylabel('Force [kN]');
legend('Location','northeast');
grid off;

fname = 'run1_180226_plot_10kg4cm';
picturewidth = 20;
hw_ratio = 0.65;
set(findall(hfig,'-property','FontSize'),'FontSize',17)
set(findall(hfig,'-property','Box'),'Box','off')
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex')
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig,fname,'-dpdf','-vector','-fillpage')




%  Legg til moving avrage slik at oscilasjoner
% og vi kan vise hva som skjer når vi flytter COm og MAsse og skriv litt om
% det

%% Smoothed force comparison

% --- Three smoothing methods ---
F_smooth_movmean = smoothdata(F_hyd, 'movmean', 80);
F_smooth_gauss   = smoothdata(F_hyd, 'gaussian', 120);
F_smooth_sgolay  = smoothdata(F_hyd, 'sgolay', 80);

% --- Plot ---
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

plot(L_cyl_theo, F_cyl_theo/1000, '--','color', C_red, 'LineWidth', 1.5, 'DisplayName', '$F_{cyl}$ (theoretical)');

xlabel('Cylinder length [m]');
ylabel('Force [kN]');
legend('Location','northeast');
grid off;

fname = 'run1_smoothed_comparison';
picturewidth = 20;
hw_ratio = 0.65;
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

v_thr = 2e-4;                       % [m/s] — tune from a plot of Ldot
ext = Ldot >  v_thr;
ret = Ldot < -v_thr;

% Common L grid where both branches exist
L_grid = linspace(max(min(L_s(ext)), min(L_s(ret))), ...
                  min(max(L_s(ext)), max(L_s(ret))), 400)';

F_ext = interp1(L_s(ext), F_s(ext), L_grid, 'linear');
F_ret = interp1(L_s(ret), F_s(ret), L_grid, 'linear');
F_mid      = 0.5*(F_ext + F_ret);
F_fric_est = 0.5*(F_ext - F_ret);

hfig3 = figure;
plot(L_s(ext), F_s(ext)/1000, '-', 'Color', C_blue,   'LineWidth', 1.3, 'DisplayName', '$F_{hyd}$ extension'); 
hold on;
plot(L_s(ret), F_s(ret)/1000, '-', 'Color', C_orange, 'LineWidth', 1.3, 'DisplayName', '$F_{hyd}$ retraction');
plot(L_grid, F_mid/1000, ':k', 'LineWidth', 1.5, 'DisplayName', 'midline');
plot(L_cyl_theo, F_cyl_theo/1000, '--', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$F_{cyl}$ (theoretical)');
xlabel('Cylinder length [m]'); 
ylabel('Force [kN]');
legend('Location','northeast');

F_theo_on_grid = interp1(L_cyl_theo, F_cyl_theo, L_grid, 'linear', 'extrap');
fprintf('Mean (midline - theory) = %.1f N\n', mean(F_mid - F_theo_on_grid, 'omitnan'));
fprintf('Mean friction estimate  = %.1f N\n', mean(F_fric_est, 'omitnan'));

%% Friction identification 

% We need F_fric as a function of Ldot, not L. Easiest path: go back to the
% samples and compute F_fric pointwise as F_hyd - F_load(L), where F_load
% is the midline (not the hand-calc theory — midline is what the data says
% the load actually is, so any residual model error doesn't leak in).

% F_load_samp = interp1(L_grid, F_mid, L_s, 'linear', NaN);
% F_fric_samp = F_s - F_load_samp;

F_load_samp = interp1(L_cyl_theo, F_cyl_theo, L_s, 'linear', NaN);
F_fric_samp = F_s - F_load_samp;

% Keep only samples inside the L overlap region AND clearly in motion
in_overlap = L_s >= min(L_grid) & L_s <= max(L_grid);
v_plateau = 140e-3;                % m/s — just inside both plateaus
mask = in_overlap & abs(Ldot) > v_plateau;

v  = Ldot(mask);
Ff = F_fric_samp(mask);

% --- Coulomb + viscous fit: Ff = Fc*sign(v) + b*v ---
X = [sign(v), v];
coef = X \ Ff;
Fc = coef(1);
b  = coef(2);

fprintf('\nFriction fit (Coulomb + viscous):\n');
fprintf('  F_C = %.1f N\n', Fc);
fprintf('  b   = %.1f N/(m/s)\n', b);

% --- Direction-split fit (checks asymmetry) ---
mE = v >  0;  mR = v <  0;
cE = [ones(sum(mE),1), v(mE)] \ Ff(mE);   % Ff = Fc_ext + b_ext*v
cR = [ones(sum(mR),1), v(mR)] \ Ff(mR);   % Ff = -Fc_ret + b_ret*v (Fc_ret > 0)
fprintf('  Extension:   F_C = %+6.1f N, b = %6.1f N/(m/s)\n', cE(1), cE(2));
fprintf('  Retraction:  F_C = %+6.1f N, b = %6.1f N/(m/s)\n', cR(1), cR(2));

% --- Plot Ff vs v with fit overlay ---
v_fit = linspace(min(v), max(v), 200)';
Ff_fit = Fc*sign(v_fit) + b*v_fit;

hfig4 = figure;
plot(v*1e3, Ff/1000, '.', 'Color', [0.7 0.7 0.7], 'MarkerSize', 4, 'DisplayName', 'samples'); 
hold on;
plot(v_fit*1e3, Ff_fit/1000, '-', 'Color', C_red, 'LineWidth', 1.5,'DisplayName', '$F_C\,\mathrm{sgn}(\dot L) + b\,\dot L$');
xlabel('$\dot L$ [mm/s]');
ylabel('$F_\mathrm{fric}$ [kN]');
legend('Location','northwest');

fname = 'run1_friction_fit';
picturewidth = 20; 
hw_ratio = 0.65;
set(findall(hfig4,'-property','FontSize'),'FontSize',17)
set(findall(hfig4,'-property','Box'),'Box','off')
set(findall(hfig4,'-property','Interpreter'),'Interpreter','latex')
set(findall(hfig4,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig4,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig4,'Position');
set(hfig4,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig4,fname,'-dpdf','-vector','-fillpage')