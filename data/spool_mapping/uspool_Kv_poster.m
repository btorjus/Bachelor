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

%% Max Kv from scatter data (120 bar)
Kv_max_up   = 4.1056;
Kv_max_down = 4.2579;

%% Plot settings
picturewidth    = 20;
hw_ratio        = 0.35;
EXPORT_fontsize = 11;

C_red    = [0.9490, 0.0196, 0.0196];  % #F20505
C_lblue  = [0.0118, 0.6510, 0.5333];  % #03A688

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

%% Figure
hfig = figure('Name','DCV spool characterization combined');

xline(0, 'k:', 'LineWidth', 0.8, 'HandleVisibility', 'off'); hold on
plot(Kv_lin_up,     spool_lin_up,    '-', 'Color', C_red,   'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(Kv_poly_up,    spool_poly_up,   '-', 'Color', C_red,   'LineWidth', 1.5, 'DisplayName', 'Up (Port A)');
plot(-Kv_lin_down,  spool_lin_down,  '-', 'Color', C_lblue, 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(-Kv_poly_down, spool_poly_down, '-', 'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', 'Down (Port B)');
hold off;
xlabel('$K_v$ [L/min/bar$^{0.5}$]');
ylabel('$u_\mathrm{spool}$');
legend('Location', 'north');

applyFigureExportTemplate(hfig, picturewidth, hw_ratio, EXPORT_fontsize);
print(hfig, 'uspool_Kv', '-dpdf', '-vector', '-fillpage')

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