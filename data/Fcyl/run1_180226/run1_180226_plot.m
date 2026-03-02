
%% Hand calc comparison with run 1
clear; clc; close all;

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
x_c     = 3.01315;                      % COM in x direction local [m] (CAD 3.01315m)
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
plot(L_cyl_theo, F_cyl_theo/1000, 'r--', 'LineWidth', 1.5, 'DisplayName', '$F_{cyl}$ (theoretical)');
xlabel('Cylinder length [m]');
ylabel('Force [kN]');
legend('Location','northeast');
grid on;

fname = 'run1_180226_plot';
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