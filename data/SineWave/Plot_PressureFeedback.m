clc; clear; close all;
% Ctrl R for comment
% Ctrl T for uncomment

% 100bar
%dataKVFF           = loadCSV('SineWave_100bar_0.025_14.05.26.csv');
%dataKVFF           = loadCSV('SineWave_100bar_0.05_14.05.26.csv');
dataKVFF           = loadCSV('SineWave_100bar_0.075_14.05.26.csv');
%dataKVFF            = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.075freq_24.04.26.csv');

% 120bar
%dataKVFF    = loadCSV('SineWave_120bar_0.025_14.05.26.csv');
%dataKVFF    = loadCSV('SineWave_120bar_0.05_14.05.26.csv');
%dataKVFF    = loadCSV('SineWave_120bar_0.075_14.05.26.csv');

% Other
data_manual = loadCSV('ManualDriving_04.05.26_Backup.csv');
data2    = loadCSV('SineWave_NoPF_KVFF_100bar_0.05freq_26.03.26.csv');
data3    = loadCSV('SineWave_PaLower_PF_KVFF_100bar_0.05freq_20.04.26.csv');


% Smoothing function
idxPF = dataKVFF.fTimer >= 14 & dataKVFF.fTimer <= 80;
windowSize = 50;
posSmooth  = movmean(dataKVFF.fPistonPosition(idxPF), windowSize);
pxSmooth   = movmean(dataKVFF.fPx(idxPF),             windowSize);
gradSmooth = movmean(dataKVFF.fPxGrad(idxPF),         windowSize);
upfbSmooth = movmean(dataKVFF.fUpfb(idxPF),           windowSize);
uSmooth    = movmean(dataKVFF.fU(idxPF),              windowSize);
posref     = movmean(dataKVFF.fXRef(idxPF),           windowSize);
paSmooth = movmean(dataKVFF.fPaFiltered(idxPF), windowSize);
pbSmooth = movmean(dataKVFF.fPbFiltered(idxPF), windowSize);
t = dataKVFF.fTimer(idxPF);

% Colors
C_red    = [0.9490, 0.1020, 0.0000];
C_lblue   = '#5FC2D9';
C_blue  = '#1E90FF';
C_yellow = '#F29F05';
C_orange = '#F27405';
C_green =  '#2ECC71';
C_purple = '#A020F0';
C_black  = [0.1608, 0.1294, 0.1216];

%C_red    = [0.9490, 0.0196, 0.0196];
%C_blue   = '#5FC2D9';
%C_green  = '#03A688';
%C_yellow = '#F29F05';
%C_orange = '#F27405';
%C_purple = '#A020F0';
%C_black  = [0.1608, 0.1294, 0.1216];


%% Fig1
% Lower reversal point with and without PF
hfig1 = figure;
plot(dataKVFF.fTimer, dataKVFF.fPistonPosition, '-', 'Color', C_red, 'LineWidth', 3, 'DisplayName', '$x$ - Active PF')
hold on
plot(data2.fTimer, data2.fPistonPosition, '-', 'Color', C_blue, 'LineWidth', 3, 'DisplayName', '$x$ - No PF')
plot(dataKVFF.fTimer, dataKVFF.fXRef, '-', 'Color', C_black, 'LineWidth', 3, 'DisplayName', '$x_{ref}$')
hold off
grid off
xlim([55, 59])
ylim([0.049, 0.08])
title('Cylinder Position (100 bar, 0.05 Hz)', 'FontWeight', 'normal')
xlabel('Time [s]')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.07;
lg.Position(2) = lg.Position(1) + 0.06;
saveFigure(hfig1, 'SineReversalPoint')


%% Fig2
% Sine wave with and without PF
idx1 = dataKVFF.fTimer >= 6 & dataKVFF.fTimer <= 82;
idx2 = data2.fTimer >= 6 & data2.fTimer <= 82;

hfig2 = figure;
subplot(2,1,1)
plot(data2.fTimer(idx2), data2.fXRef(idx2), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(data2.fTimer(idx2), data2.fPistonPosition(idx2), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
title('Cylinder Position (100 bar, 0.05 Hz) - No Pressure Feedback', 'FontWeight', 'normal')
ylabel('Position [m]')
xlim([15, 92]);
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;

subplot(2,1,2)
plot(dataKVFF.fTimer(idx1), dataKVFF.fXRef(idx1), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(idx1), dataKVFF.fPistonPosition(idx1), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
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
% Sine Wave and PFB control signals
hfig3 = figure;
subplot(2,1,1)
plot(t, posref, '-', 'Color', C_black,'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(t, posSmooth, '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
xlim([14, 89])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Cylinder Position')
ylabel('Position [m]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.04;
lg.Position(2) = lg.Position(2) - 0.03;

subplot(2,1,2)
plot(t, uSmooth,    '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(t, upfbSmooth, '-',  'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
xlim([14, 89])
ylim([-0.9, 0.6])
hold off
grid off;
xlabel('Time [s]')
ylabel('Signal [-]')
title('Pressure Feedback (100 bar, 0.05 Hz) - Valve Signals')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
lg.Position(2) = lg.Position(2) - 0.03;
saveFigure(hfig3, 'PF_CompletePosition')


%% Fig 4
% Sine Wave and PFB signals at high reversal point
hfig4 = figure;
subplot(2,1,1)
plot(t, posref, '-', 'Color', C_black,'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(t, posSmooth, '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
xlim([64, 72])
ylim([0.3, 0.355])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Cylinder Position')
ylabel('Position [m]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.04;
%lg.Position(2) = lg.Position(2) - 0.03;

subplot(2,1,2)
idx = t <= 71;
plot(t(idx), uSmooth(idx),    '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(t(idx), upfbSmooth(idx), '-', 'Color', C_red,   'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
xlim([64, 72])
ylim([-0.9, 0.6])
hold off
grid off;
xlabel('Time [s]')
ylabel('Signal [-]')
title('Pressure Feedback (100 bar, 0.05 Hz) - Valve Signals')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
%lg.Position(2) = lg.Position(2) - 0.03;
saveFigure(hfig4, 'PF_Position_Signal')

%% Fig 5 
% Selected pressure and pressure gradient
hfig5 = figure;
subplot(2,1,1)
plot(t, pxSmooth, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$p_x$')
xlim([14, 70])
ylim([-10, 100])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Selected Pressure')
ylabel('Pressure [bar]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
%lg.Position(2) = lg.Position(2) - 0.03;

subplot(2,1,2)
plot(t, gradSmooth, '-', 'Color', C_purple, 'LineWidth', 1.5, 'DisplayName', '$\nabla p$')
xlim([14, 70])
ylim([-1500, 1400])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Pressure Gradient')
xlabel('Time [s]')
ylabel('Gradient [bar/s]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.07;
%lg.Position(2) = lg.Position(2) - 0.03;
saveFigure(hfig5, 'PF_CompletePressure')


%% Fig6
% All Control Signals
fU_Smooth = movmean(dataKVFF.fU, 1);
hfig6 = figure;
plot(dataKVFF.fTimer, fU_Smooth, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer, dataKVFF.fU_FF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{FF}$')
plot(dataKVFF.fTimer, dataKVFF.fUpfb, '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataKVFF.fTimer, dataKVFF.fPID, '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off
xlim([12, 82])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve \& Control Signals (120 bar, 0.05 Hz)', 'FontWeight', 'normal')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.090;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig6, 'AllSignals')


%% Fig 7
% Selected pressure and pressure gradient
hfig7 = figure;
subplot(2,1,1)
plot(t, pxSmooth, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$p_x$')
xlim([65, 69])
ylim([-10, 80])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Selected Pressure')
ylabel('Pressure [bar]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.07;
lg.Position(2) = lg.Position(2) + 0.015;

subplot(2,1,2)
plot(t, gradSmooth, '-', 'Color', C_purple, 'LineWidth', 1.5, 'DisplayName', '$\nabla p$')
xlim([65, 69])
ylim([-1500, 400])
grid off;
title('Pressure Feedback (100 bar, 0.05 Hz) - Pressure Gradient')
xlabel('Time [s]')
ylabel('Gradient [bar/s]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.085;
lg.Position(2) = lg.Position(2) + 0.015;
saveFigure(hfig7, 'PF_Pressure_Gradient')


%% Fig8
% Comparison PF turns off
idx3 = data3.fTimer >= 6 & data3.fTimer <= 82;
idx1 = dataKVFF.fTimer >= 6 & dataKVFF.fTimer <= 82;

hfig8 = figure;
subplot(2,1,1)
plot(data3.fTimer(idx3), data3.fXRef(idx3), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(data3.fTimer(idx3), data3.fPistonPosition(idx3), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
title('Cylinder Position (100 bar, 0.05 Hz) - PF Always Active', 'FontWeight', 'normal')
ylabel('Position [m]')
xlim([65, 69]);
ylim([0.33, 0.355]);
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.055;
lg.Position(2) = lg.Position(2) + 0.015;

subplot(2,1,2)
plot(dataKVFF.fTimer(idx1), dataKVFF.fXRef(idx1), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(idx1), dataKVFF.fPistonPosition(idx1), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')

% Shaded region
yLims = [0.33, 0.355];
fill([66.252, 67.488, 67.488, 66.252], [yLims(1), yLims(1), yLims(2), yLims(2)], ...
    C_black, 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off')
xline(66.252, '-', 'Color', C_black,   'LineWidth', 0.8, 'Alpha', 0.4, 'HandleVisibility', 'off')
xline(67.488, '-', 'Color', C_black, 'LineWidth', 0.8, 'Alpha', 0.4, 'HandleVisibility', 'off')

% Label 
text(mean([66.252, 67.488]), yLims(1) + 0.002, 'PF not active', ...
    'Color', C_black, 'FontSize', 10, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'Interpreter', 'none')

hold off
grid off;
title('Cylinder Position (100 bar, 0.05 Hz) - PF Turns Off', 'FontWeight', 'normal')
xlabel('Time [s]')
ylabel('Position [m]')
xlim([65, 69]);
ylim([0.33, 0.355]);
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.055;
lg.Position(2) = lg.Position(2) + 0.015;
saveFigure(hfig8, 'PF_PFB_TurnOff')


%% Fig9
% Manual Driving and Return to home
hfig9 = figure;
plot(data_manual.fTimer, data_manual.fPistonPosition, '-', 'Color', C_red, 'LineWidth', 3, 'DisplayName', '$x$')
hold on
fill(nan, nan, C_black, 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'DisplayName', 'Return-to-Home')

% Shaded region
yLims = ylim;
fill([54.0, 63.3, 63.3, 54.0], [yLims(1), yLims(1), yLims(2), yLims(2)], ...
    C_black, 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off')
xline(54.0, '-', 'Color', C_black, 'LineWidth', 0.8, 'Alpha', 0.4, 'HandleVisibility', 'off')
xline(63.3, '-', 'Color', C_black, 'LineWidth', 0.8, 'Alpha', 0.4, 'HandleVisibility', 'off')

% Label centered in shaded region at the bottom
text(mean([54.0, 63.3]), yLims(1) + 0.3, '', ...
    'Color', C_black, 'FontSize', 10, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'Interpreter', 'none')

xlim([0,85])
hold off
grid off
title('Cylinder Position (100 bar) - Manual Operation', 'FontWeight', 'normal')
xlabel('Time [s]')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.03;
lg.Position(2) = lg.Position(1) - 0.05;
saveFigure(hfig9, 'ManualDriving')



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
    hw_ratio = 0.65;
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', 15)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig, 'Position');
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', 'PaperSize', [pos(3), pos(4)])
    print(hfig, fname, '-dpdf', '-painters', '-fillpage')
end