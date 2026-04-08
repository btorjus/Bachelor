clc; clear; close all;
% Ctrl R for comment
% Ctrl T for uncomment

%% Loading csv
dataKVFF = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_26.03.26.csv');

%% Index og smoothing
idxPF = dataKVFF.fTimer >= 1 & dataKVFF.fTimer <= 60;

windowSize = 50;
posSmooth   = movmean(dataKVFF.fPistonPosition(idxPF), windowSize);
pxSmooth    = movmean(dataKVFF.fPx(idxPF),             windowSize);
gradSmooth  = movmean(dataKVFF.fPxGrad(idxPF),         windowSize);
upfbSmooth  = movmean(dataKVFF.fUpfb(idxPF),           windowSize);
uSmooth     = movmean(dataKVFF.fU(idxPF),              windowSize);

t = dataKVFF.fTimer(idxPF);

% Figure 1: Position (topp) og Signal u / u_pfb (bunn)
hfig1 = figure;

subplot(2,1,1)
plot(t, posSmooth, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Active PF')
%xlim([55, 59])
%ylim([0.05, 0.08])
grid off;
title('Pressure Feedback Analysis (100 bar, 0.05 Hz) - Cylinder Position')
ylabel('Position [m]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.05;
%lg.Position(2) = lg.Position(2) - 0.05;

subplot(2,1,2)
plot(t, uSmooth,    'k-', 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(t, upfbSmooth, '-',  'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
%xlim([55, 59])
%ylim([-0.5,0.5])
hold off
grid off;
xlabel('Time [s]')
ylabel('Signal [-]')
title('Pressure Feedback Analysis (100 bar, 0.05 Hz) - Valve Signals')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
%lg.Position(1) = lg.Position(1) + 0.05;
%lg.Position(2) = lg.Position(2) - 0.03;

saveFigure(hfig1, 'PF_Position_Signal')

% Figure 2: Pressure px (topp) og Gradient ∇px (bunn)
hfig2 = figure;

subplot(2,1,1)
plot(t, pxSmooth, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$p_x$')
%xlim([55, 59])
%ylim([21,95])
grid off;
title('Pressure Feedback Analysis (100 bar, 0.05 Hz) - Selected Pressure')
ylabel('Pressure [bar]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) + 0.05;
% lg.Position(2) = lg.Position(2) - 0.05;

subplot(2,1,2)
plot(t, gradSmooth, '-', 'Color', '#A020F0', 'LineWidth', 1.5, 'DisplayName', '$\nabla p_x$')
%xlim([55, 59])
%ylim([-200,1200])
grid off;
title('Pressure Feedback Analysis (100 bar, 0.05 Hz) - Pressure Gradient')
xlabel('Time [s]')
ylabel('Gradient [bar/s]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) + 0.05;
% lg.Position(2) = lg.Position(2) - 0.03;

saveFigure(hfig2, 'PF_Pressure_Gradient')

%% Help functions
function data = loadCSV(filename)
    opts = detectImportOptions(filename, 'Delimiter', ';');
    opts.VariableNamesLine = 7;
    opts.DataLines = [9 Inf];
    opts.VariableNamingRule = 'preserve';
    opts = setvartype(opts, 'double');
    opts = setvaropts(opts, opts.VariableNames, 'DecimalSeparator', ',');
    data = readtable(filename, opts);
end

function saveFigure(hfig, fname)
    picturewidth = 20;
    hw_ratio = 0.99;
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', 15)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig, 'Position');
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', 'PaperSize', [pos(3), pos(4)])
    print(hfig, fname, '-dpdf', '-painters', '-fillpage')
end