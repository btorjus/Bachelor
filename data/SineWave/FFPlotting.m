clc; clear; close all;
% Ctrl R to comment
% Ctrl T to uncomment

% 100bar
%dataKVFF           = loadCSV('SineWave_100bar_0.025_14.05.26.csv');
%dataKVFF           = loadCSV('SineWave_100bar_0.05_14.05.26.csv');
%dataKVFF           = loadCSV('SineWave_100bar_0.075_14.05.26.csv');
%dataKVFF            = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.075freq_24.04.26.csv');

% 120bar
dataKVFF    = loadCSV('SineWave_120bar_0.025_14.05.26.csv');
%dataKVFF    = loadCSV('SineWave_120bar_0.05_14.05.26.csv');
%dataKVFF    = loadCSV('SineWave_120bar_0.075_14.05.26.csv');

% Other
dataNoFF    = loadCSV('SineWave_NoFF_PF_KVFF_100bar_0.05freq_31.03.26.csv');
dataNoPosFB = loadCSV('SineWave_NoPID_100bar_0.05freq_04.05.26.csv');
dataNaiveFF = loadCSV('SineWave_NaiveFF_PF_100bar_0.05freq_22.04.26.csv');

% Colors
C_red    = [0.9490, 0.1020, 0.0000];
C_lblue   = '#5FC2D9';
C_blue  = '#1E90FF';
C_yellow = '#F29F05';
C_orange = '#F27405';
C_green =  '#2ECC71';
C_purple = '#A020F0';
C_black  = [0.1608, 0.1294, 0.1216];

% Speed calculation
COL_time     = 'fTimer';
COL_fU       = 'fU';
COL_spool    = 'fSpoolPosition';
COL_pSupply  = 'fPs';
COL_pA       = 'fPaLower';
COL_pB       = 'fPb';
COL_flow     = 'fFlow';
COL_position = 'fPistonPosition';

VEL_SMOOTH_SPAN   = 800;        % Smoothing
VEL_SMOOTH_METHOD = 'gaussian';  % 'sgolay' | 'movmean' | 'gaussian'

% Smoothing function
idxPF = dataKVFF.fTimer >= 0 & dataKVFF.fTimer <= 150;
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


%% Fig1 
% No FF (Xdotref, Xdotactual, PistonPo.)
idx = dataNoFF.fTimer >= 0.0 & dataNoFF.fTimer <= 92.65;
t_NoFF   = dataNoFF.fTimer(idx);
pos_NoFF = dataNoFF.fPistonPosition(idx);
vSmoothNoFF = smoothdata(gradient(pos_NoFF, t_NoFF), VEL_SMOOTH_METHOD, VEL_SMOOTH_SPAN);

hfig1 = figure;
subplot(2,1,1)
plot(dataNoFF.fTimer(idx), dataNoFF.fXRef(idx), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataNoFF.fTimer(idx), dataNoFF.fPistonPosition(idx), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
ylim([0.04, 0.35]);
xlim([28.6,110])
title('No Active FF (100 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.04;
lg.Position(2) = lg.Position(2) + 0.02;

subplot(2,1,2)
plot(dataNoFF.fTimer(idx), dataNoFF.fXDotRef(idx), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
hold on
plot(dataNoFF.fTimer(idx), vSmoothNoFF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
hold off
grid off
ylim([-0.06, 0.06])
xlim([28.6,110])
xlabel('Time [s]')
ylabel('Velocity [m/s]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.065;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig1, 'Subplot_NoFF')


%% Fig2
% KVFF All Control Signals
fU_Smooth = movmean(dataKVFF.fU, 1);
hfig2 = figure;
plot(dataKVFF.fTimer, fU_Smooth, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer, dataKVFF.fU_FF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{FF}$')
plot(dataKVFF.fTimer, dataKVFF.fUpfb, '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataKVFF.fTimer, dataKVFF.fPID, '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off
xlim([13, 130])
ylim([-0.5,0.4])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve \& Control Signals (120 bar, 0.025 Hz)', 'FontWeight', 'normal')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.090;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig2, 'AAAllSignals')


%% Fig3
% KVFF Sine trajectory and speed + speed ref
mask = dataKVFF.fTimer >= 0 & dataKVFF.fTimer <= 116;
t_KVFF   = dataKVFF.fTimer(mask);
pos_KVFF = dataKVFF.fPistonPosition(mask);
vSmoothKVFF = smoothdata(gradient(pos_KVFF, t_KVFF), VEL_SMOOTH_METHOD, VEL_SMOOTH_SPAN);

hfig3 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer(mask), dataKVFF.fXRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fPistonPosition(mask), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
xlim([13, 130])
ylim([0.025,0.37])
title('Active Kv FF (120 bar, 0.025 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.035;

subplot(2,1,2)
plot(dataKVFF.fTimer(mask), dataKVFF.fXDotRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
hold on
plot(dataKVFF.fTimer(mask), vSmoothKVFF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
hold off
grid off
xlim([13, 130])
ylim([-0.03, 0.03]);
xlabel('Time [s]')
ylabel('Velocity [m/s]')
lg = legend('Interpreter', 'latex')
lg.Position(1) = lg.Position(1) + 0.055;
saveFigure(hfig3, 'AASubplot_KVFF')

%% Fig xx 
% Selected pressure and pressure gradient
hfig5 = figure;
subplot(2,1,1)
plot(t, pxSmooth, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$p_x$')
xlim([13, 130])
ylim([-100, 50])
grid off;
title('(120 bar, 0.025 Hz) - Selected Pressure')
ylabel('Pressure [bar]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
%lg.Position(2) = lg.Position(2) - 0.03;

subplot(2,1,2)
plot(t, gradSmooth, '-', 'Color', C_purple, 'LineWidth', 1.5, 'DisplayName', '$\nabla p$')
xlim([13, 130])
ylim([-2300, 1500])
grid off;
title('(120 bar, 0.025 Hz) - Pressure Gradient')
xlabel('Time [s]')
ylabel('Gradient [bar/s]')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.07;
%lg.Position(2) = lg.Position(2) - 0.03;
saveFigure(hfig5, 'AAPF_CompletePressure')


%% Fig4
% KvFF uFF and u
mask = dataKVFF.fTimer >= 0 & dataKVFF.fTimer <= 97;
t_KVFF = dataKVFF.fTimer(mask);
fU_Smooth = movmean(dataKVFF.fU(mask), 1000);

hfig4 = figure;
plot(t_KVFF, fU_Smooth, '-', 'Color', C_black, 'LineWidth', 2, 'DisplayName', '$u$')
hold on
plot(t_KVFF, dataKVFF.fU_FF(mask), '-', 'Color', C_blue, 'LineWidth', 2, 'DisplayName', '$u_{FF}$')
hold off
grid off
xlim([12, 105])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve Signals, Active Kv FF (100 bar, 0.05 Hz)')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.10;
saveFigure(hfig4, 'KvFF_Contribution')

%% Fig5
% Position Feedback drifting
idxNoPosFB = dataNoPosFB.fTimer >= 0 & dataNoPosFB.fTimer <= 95;
idxKVFF    = dataKVFF.fTimer    >= 0 & dataKVFF.fTimer    <= 95;

hfig5 = figure;
subplot(2,1,1)
plot(dataNoPosFB.fTimer(idxNoPosFB), dataNoPosFB.fXRef(idxNoPosFB), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataNoPosFB.fTimer(idxNoPosFB), dataNoPosFB.fPistonPosition(idxNoPosFB), '-', 'Color', C_red,'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
title('No Position Feedback (100 bar, 0.05 Hz)')
ylabel('Position [m]')
%xlim([27,197])
xlim([10,100])
ylim([-0.01,0.35])
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
lg.Position(2) = lg.Position(2) - 0.01;

subplot(2,1,2)
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fXRef(idxKVFF), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fPistonPosition(idxKVFF), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
title('Active Position Feedback (100 bar, 0.05 Hz)')
xlabel('Time [s]')
ylabel('Position [m]')
%xlim([8,85])
xlim([10,100])
ylim([0.03,0.4])
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
lg.Position(2) = lg.Position(2) - 0.01;
saveFigure(hfig5, 'Subplot_NoPosFB_PosFB')


%% Fig6
% Position and PID control signal
idxNoPosFB = dataNoPosFB.fTimer >= 0 & dataNoPosFB.fTimer <= 187;
idxKVFF    = dataKVFF.fTimer    >= 0 & dataKVFF.fTimer    <= 85;
hfig6 = figure;

subplot(2,1,1)
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fXRef(idxKVFF), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fPistonPosition(idxKVFF), '-','Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
title('Active Position Feedback (100 bar, 0.05 Hz)')
ylabel('Position [m]')
xlim([10,100])
ylim([0.0,0.5])
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
%lg.Position(2) = lg.Position(2) - 0.03;

subplot(2,1,2)
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fU(idxKVFF), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fPID(idxKVFF), '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off;
xlabel('Time [s]')
ylabel('Control Signal [-]')
xlim([10,100])
ylim([-0.85,0.6])
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.06;
%lg.Position(2) = lg.Position(2) - 0.03;
saveFigure(hfig6, 'PID_Signal')


%% Fig7 
% PID Signal and lower reversal point
idxNoPosFB = dataNoPosFB.fTimer >= 0 & dataNoPosFB.fTimer <= 187;
idxKVFF    = dataKVFF.fTimer    >= 0 & dataKVFF.fTimer    <= 85;
hfig7 = figure;

subplot(2,1,1)
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fXRef(idxKVFF), '-', 'Color', C_black, 'LineWidth', 2, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fPistonPosition(idxKVFF), '-','Color', C_red, 'LineWidth', 2, 'DisplayName', '$x$')
hold off
grid off;
title('Active Position Feedback (100 bar, 0.05 Hz)')
ylabel('Position [m]')
xlim([55.5,59])
ylim([0.045,0.075])
lg = legend('location', 'northwest', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.03;
lg.Position(2) = lg.Position(2) - 0.01;

subplot(2,1,2)
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fPID(idxKVFF), '-', 'Color', C_green, 'LineWidth', 2, 'DisplayName', '$u_{PID}$')
hold off
grid off;
xlabel('Time [s]')
ylabel('Control Signal [-]')
xlim([55.5,59])
ylim([-0.04,0.01])
lg = legend('location', 'northwest', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.04;
lg.Position(2) = lg.Position(2) + 0.01;
saveFigure(hfig7, 'PID_Signal_Short')


%% Fig8
% Nominal FF - Sine trajectory and speed
mask = dataNaiveFF.fTimer >= 20 & dataNaiveFF.fTimer <= 97;
t_NaiveFF   = dataNaiveFF.fTimer(mask);
pos_NaiveFF = dataNaiveFF.fPistonPosition(mask);
vSmoothNaiveFF = smoothdata(gradient(pos_NaiveFF, t_NaiveFF), VEL_SMOOTH_METHOD, VEL_SMOOTH_SPAN);

hfig8 = figure;
subplot(2,1,1)
plot(dataNaiveFF.fTimer(mask), dataNaiveFF.fXRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataNaiveFF.fTimer(mask), dataNaiveFF.fPistonPosition(mask), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
%xlim([45, 130]);
xlim([27, 107]);
title('Active Nominal FF (100 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.04;

subplot(2,1,2)
plot(dataNaiveFF.fTimer(mask), dataNaiveFF.fXDotRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
hold on
plot(dataNaiveFF.fTimer(mask), vSmoothNaiveFF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
hold off
grid off
%xlim([27, 130]);
xlim([27, 107]);
ylim([-0.06, 0.06])
xlabel('Time [s]')
ylabel('Velocity [m/s]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.06;
saveFigure(hfig8, 'Subplot_NaiveFF')


%% Fig9
% NaiveFF - All control signals
maskNaive = dataNaiveFF.fTimer >= 0 & dataNaiveFF.fTimer <= 97;
t_Naive = dataNaiveFF.fTimer(maskNaive);

hfig9 = figure;
plot(t_Naive, dataNaiveFF.fU(maskNaive), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(t_Naive, dataNaiveFF.fUpfb(maskNaive), '-', 'Color', C_red, 'LineWidth', 2, 'DisplayName', '$u_{PFB}$')
plot(t_Naive, dataNaiveFF.fPID(maskNaive), '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
plot(t_Naive, dataNaiveFF.fU_FF_Naive(maskNaive), '-', 'Color', C_blue, 'LineWidth', 2, 'DisplayName', '$u_{FF  nominal}$')
hold off
grid off;
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve Signals, Nominal FF (100 bar, 0.05 Hz)')
xlim([27, 107]);
ylim([-0.85, 0.6])
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.08;
saveFigure(hfig9, 'PID_Signal_NaiveFF')



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
    hw_ratio = 0.75;
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', 15)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig, 'Position');
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', 'PaperSize', [pos(3), pos(4)])
    print(hfig, fname, '-dpdf', '-painters', '-fillpage')
end