clc; clear; close all;
% Ctrl R for comment
% Ctrl T for uncomment

%% Loading csv
%data1 = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_26.03.26.csv');
data1    = loadCSV('SineWave_PaLower_PF_KVFF_100bar_0.05freq_20.04.26.csv');
data2    = loadCSV('SineWave_NoPF_KVFF_100bar_0.05freq_26.03.26.csv');

% Smoothing function
idxPF = data1.fTimer >= 14 & data1.fTimer <= 80;
windowSize = 50;
posSmooth  = movmean(data1.fPistonPosition(idxPF), windowSize);
pxSmooth   = movmean(data1.fPx(idxPF),             windowSize);
gradSmooth = movmean(data1.fPxGrad(idxPF),         windowSize);
upfbSmooth = movmean(data1.fUpfb(idxPF),           windowSize);
uSmooth    = movmean(data1.fU(idxPF),              windowSize);
posref     = movmean(data1.fXRef(idxPF),           windowSize);
t = data1.fTimer(idxPF);


%% Fig1
% Lower reversal point
hfig1 = figure;
plot(data1.fTimer, data1.fPistonPosition, '-', 'Color', '#F92672', 'LineWidth', 3, 'DisplayName', 'Active PF')
hold on
plot(data2.fTimer, data2.fPistonPosition, '-', 'Color', '#1E90FF', 'LineWidth', 3, 'DisplayName', 'No PF')
plot(data1.fTimer, data1.fXRef, '-', 'Color', '#000000', 'LineWidth', 3, 'DisplayName', '$x_{ref}$')
hold off
grid off
xlim([55, 59])
ylim([0.049, 0.08])
title('Cylinder Position (100 bar, 0.05 Hz)', 'FontWeight', 'normal')
xlabel('Time [s]')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
saveFigure(hfig1, 'SineReversalPoint')

%% Fig2
% Active and no PF, sine wave reference trajectory
idx1 = data1.fTimer >= 6 & data1.fTimer <= 82;
idx2 = data2.fTimer >= 6 & data2.fTimer <= 82;

hfig2 = figure;
subplot(2,1,1)
plot(data2.fTimer(idx2), data2.fXRef(idx2), '-', 'Color', '#000000', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(data2.fTimer(idx2), data2.fPistonPosition(idx2), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', 'No PF')
hold off
grid off;
title('Cylinder Position (100 bar, 0.05 Hz) - No Pressure Feedback', 'FontWeight', 'normal')
ylabel('Position [m]')
xlim([15, 92]);
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.02;

subplot(2,1,2)
plot(data1.fTimer(idx1), data1.fXRef(idx1), '-', 'Color', '#000000', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(data1.fTimer(idx1), data1.fPistonPosition(idx1), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', 'Active PF')
hold off
grid off;
title('Cylinder Position (100 bar, 0.05 Hz) - Active Pressure Feedback', 'FontWeight', 'normal')
xlabel('Time [s]')
ylabel('Position [m]')
xlim([15, 92]);
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
%lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig2, 'PF_noPF_SineWave_Subplot')

%% Fig3
% Sine Wave and PFB signals
hfig3 = figure;
subplot(2,1,1)
plot(t, posref, '-', 'Color', '#000000','LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(t, posSmooth, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', 'Active PF')
xlim([14, 89])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Cylinder Position')
ylabel('Position [m]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
lg.Position(2) = lg.Position(2) - 0.03;

subplot(2,1,2)
plot(t, uSmooth,    '-', 'Color', '#000000', 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(t, upfbSmooth, '-',  'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
xlim([14, 89])
ylim([-0.9, 0.6])
hold off
grid off;
xlabel('Time [s]')
ylabel('Signal [-]')
title('Pressure Feedback (100 bar, 0.05 Hz) - Valve Signals')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.01;
lg.Position(2) = lg.Position(2) - 0.03;
saveFigure(hfig3, 'PF_CompletePosition')

%% Fig 4
% Sine Wave and PFB signals at lower reversal point
hfig4 = figure;
subplot(2,1,1)
plot(t, posref, '-', 'Color', '#000000','LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(t, posSmooth, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', 'Active PF')
xlim([54, 62])
ylim([0.048, 0.1])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Cylinder Position')
ylabel('Position [m]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
%lg.Position(2) = lg.Position(2) - 0.03;

subplot(2,1,2)
plot(t, uSmooth,    '-', 'Color', '#000000', 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(t, upfbSmooth, '-',  'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
xlim([54, 62])
ylim([-0.9, 0.6])
hold off
grid off;
xlabel('Time [s]')
ylabel('Signal [-]')
title('Pressure Feedback (100 bar, 0.05 Hz) - Valve Signals')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.01;
%lg.Position(2) = lg.Position(2) - 0.03;
saveFigure(hfig4, 'PF_Position_Signal')

%% Fig 5
% Selected pressure and pressure gradient
hfig5 = figure;
subplot(2,1,1)
plot(t, pxSmooth, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$p_x$')
xlim([8, 85])
ylim([-5, 95])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Selected Pressure')
ylabel('Pressure [bar]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');

subplot(2,1,2)
plot(t, gradSmooth, '-', 'Color', '#A020F0', 'LineWidth', 1.5, 'DisplayName', '$\nabla p_x$')
xlim([8, 85])
ylim([-1400, 1400])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Pressure Gradient')
xlabel('Time [s]')
ylabel('Gradient [bar/s]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
saveFigure(hfig5, 'PF_CompletePressure')

%% Fig 6
% Selected pressure and pressure gradient
hfig6 = figure;
subplot(2,1,1)
plot(t, pxSmooth, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$p_x$')
xlim([55, 59])
ylim([-5, 95])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Selected Pressure')
ylabel('Pressure [bar]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');

subplot(2,1,2)
plot(t, gradSmooth, '-', 'Color', '#A020F0', 'LineWidth', 1.5, 'DisplayName', '$\nabla p_x$')
xlim([55, 59])
ylim([-1400, 1400])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Pressure Gradient')
xlabel('Time [s]')
ylabel('Gradient [bar/s]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
saveFigure(hfig6, 'PF_Pressure_Gradient')

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
    hw_ratio = 0.9;
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', 15)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig, 'Position');
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', 'PaperSize', [pos(3), pos(4)])
    print(hfig, fname, '-dpdf', '-painters', '-fillpage')
end