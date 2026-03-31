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
EXPORT_fontsize = 17;
C_black         = [ 51,  51,  51] ./ 255;
C_blue          = [129, 154, 255] ./ 255;

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

%% Plot 1 — Linear approximation only
hfig1 = figure('Name','Linear approximation');

xline(0, 'k:', 'LineWidth', 0.8, 'HandleVisibility', 'off'); hold on
plot(Kv_lin_up,    spool_lin_up,   '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Up (Port A)');
plot(-Kv_lin_down, spool_lin_down, '-', 'Color', C_blue,  'LineWidth', 1.5, 'DisplayName', 'Down (Port B)');
hold off;
xlabel('$K_v$ (L/min/bar$^{0.5}$)');
ylabel('Spool position (norm.)');
legend('Location', 'north');

applyFigureExportTemplate(hfig1, picturewidth, 0.65, EXPORT_fontsize);
print(hfig1, 'dcv_linear_approx', '-dpdf', '-vector', '-fillpage')

%% Plot 2 — Combined linear + polynomial
hfig2 = figure('Name','Combined spool characterization');

xline(0, 'k:', 'LineWidth', 0.8, 'HandleVisibility', 'off'); hold on

% Up
plot(Kv_lin_up,   spool_lin_up,   '-', 'Color', C_black, 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(Kv_poly_up,  spool_poly_up,  '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', 'Up (Port A)');

% Down
plot(-Kv_lin_down,  spool_lin_down,  '-', 'Color', C_blue, 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(-Kv_poly_down, spool_poly_down, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', 'Down (Port B)');

hold off;
xlabel('$K_v$ (L/min/bar$^{0.5}$)');
ylabel('Spool position (norm.)');
legend('Location', 'north');

applyFigureExportTemplate(hfig2, picturewidth, 0.65, EXPORT_fontsize);
print(hfig2, 'dcv_combined_characterization', '-dpdf', '-vector', '-fillpage')

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