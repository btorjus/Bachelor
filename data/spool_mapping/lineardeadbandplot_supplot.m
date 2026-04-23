clear; clc; close all;

%% Polynomial fits (120 bar): spool = f(Kv)
pUp_spool_of_Kv_120   = [0.0018653, -0.033672,  0.22033, -0.65618,  0.83411, -0.047269, 0.26252];
pDown_spool_of_Kv_120 = [0.00098272, -0.017507,  0.11599, -0.34851,  0.41222,  0.17643,  0.2076];

%% Linear fit parameters
u_dead_up   = 0.236;
u_dead_down = 0.206;

lUp_intercept   = 1.1182*u_dead_up   - 0.0325;
lDown_intercept = 1.1075*u_dead_down - 0.0416;

Kv_handoff = 0.1;
spool_handoff_up   = polyval(pUp_spool_of_Kv_120,   Kv_handoff);
spool_handoff_down = polyval(pDown_spool_of_Kv_120, Kv_handoff);

lUp_slope   = (spool_handoff_up   - lUp_intercept)   / Kv_handoff;
lDown_slope = (spool_handoff_down - lDown_intercept) / Kv_handoff;

fprintf('Linear Up:   spool = %.4f + %.4f * Kv\n', lUp_intercept,   lUp_slope)
fprintf('Linear Down: spool = %.4f + %.4f * Kv\n', lDown_intercept, lDown_slope)

%% Max Kv from scatter data (120 bar)
Kv_max_up   = 4.1056;
Kv_max_down = 4.2579;

%% Plot settings
picturewidth    = 20;
EXPORT_fontsize = 11;
% C_red    = '#f21a00'; 
% C_blue   = '#3b9ab2'; 
% C_lblue  = '#78b7c5';   
% C_yellow = '#ebcc2a';
% C_orange = '#e1af00';
% C_red = '#f21a00';
C_red    = [0.9490, 0.0196, 0.0196];  % #F20505
C_blue   = [0.3725, 0.7608, 0.8510];  % #5FC2D9
C_lblue  = [0.0118, 0.6510, 0.5333];  % #03A688
C_yellow = [0.9490, 0.6235, 0.0196];  % #F29F05
C_orange = [0.9490, 0.4549, 0.0196];  % #F27405
C_black  = [0.1608, 0.1294, 0.1216];

M_green = '#798e87';
M_brown = '#c27d38';
M_besh = '#ccc591';
M_black = '#29211f';

%% Build curve segments

% Up (positive Kv, right side)
Kv_lin_up    = linspace(0, Kv_handoff, 50);
spool_lin_up = lUp_intercept + lUp_slope * Kv_lin_up;

Kv_poly_up    = linspace(Kv_handoff, Kv_max_up, 300);
spool_poly_up = polyval(pUp_spool_of_Kv_120, Kv_poly_up);

% Down (negative Kv, left side)
Kv_lin_down    = linspace(0, Kv_handoff, 50);
spool_lin_down = lDown_intercept + lDown_slope * Kv_lin_down;

Kv_poly_down    = linspace(Kv_handoff, Kv_max_down, 300);
spool_poly_down = polyval(pDown_spool_of_Kv_120, Kv_poly_down);

%% Figure — two subplots
hfig = figure('Name','DCV spool characterization');

% Subplot 1 — Linear approximation only
subplot(2,1,1);
xline(0, 'k:', 'LineWidth', 0.8, 'HandleVisibility', 'off'); hold on
plot(Kv_lin_up,    spool_lin_up,   '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', 'Up (Port A)');
plot(-Kv_lin_down, spool_lin_down, '-', 'Color', C_lblue,  'LineWidth', 1.5, 'DisplayName', 'Down (Port B)');
hold off;
xlabel('$K_v$ [L/min/bar$^{0.5}$]');
ylabel('Spool position (norm.)');
legend('Location', 'north');
title('Linear approximation')

% Subplot 2 — Combined linear + polynomial
subplot(2,1,2);
xline(0, 'k:', 'LineWidth', 0.8, 'HandleVisibility', 'off'); hold on
plot(Kv_lin_up,     spool_lin_up,    '-', 'Color', C_red, 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(Kv_poly_up,    spool_poly_up,   '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', 'Up (Port A)');
plot(-Kv_lin_down,  spool_lin_down,  '-', 'Color', C_lblue,  'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(-Kv_poly_down, spool_poly_down, '-', 'Color', C_lblue,  'LineWidth', 1.5, 'DisplayName', 'Down (Port B)');
hold off;
xlabel('$K_v$ [L/min/bar$^{0.5}$]');
ylabel('Spool position (norm.)');
legend('Location', 'north');
title('Combined characterization')

applyFigureExportTemplate(hfig, picturewidth, 0.65, EXPORT_fontsize);
print(hfig, 'dcv_characterization', '-dpdf', '-vector', '-fillpage')

%% Local functions
function applyFigureExportTemplate(hfig, picturewidth, hw_ratio, fontsize)
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', fontsize)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', ...
        'PaperSize', [picturewidth, hw_ratio*picturewidth])
end