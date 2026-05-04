clc; clear; close all;
% Ctrl R for comment
% Ctrl T for uncomment

% Loading csv
%dataKVFF    = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_26.03.26.csv');
%dataKVFF = loadCSV('SineWave_PaLower_PF_KVFF_100bar_0.05freq_20.04.26.csv');
%dataKVFF    = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.05freq_23.04.26.csv');
%dataKVFF    = loadCSV('SineWave_PaLower_PF_KVFF_100bar_0.05freq_21.04.26.csv');
%dataKVFF  = loadCSV('SineWave_speedtreshold0.005_KvFF_PF_100bar_0.025freq_24.04.26.csv');
%dataKVFF  = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.05freq_24.04.26.csv');

%dataKVFF    = loadCSV('SineWave_speedtreshold0.005_KvFF_PF_100bar_0.025freq_24.04.26.csv');
%dataKVFF     = loadCSV('SineWave_speedtreshold0.008_KvFF_PF_100bar_0.025freq_24.04.26.csv');
dataKVFF       = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.05freq_24.04.26.csv');
%dataKVFF     = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.075freq_24.04.26.csv');

dataNoFF    = loadCSV('SineWave_NoFF_PF_KVFF_100bar_0.05freq_31.03.26.csv');
dataNoPosFB = loadCSV('SineWave_NoPositionFeedback_PF_KVFF_100bar_0.05freq_31.03.26.csv');
%dataNaiveFF = loadCSV('SineWave_OtherFF_PF_100bar_0.05freq_31.03.26.csv');
%dataNaiveFF = loadCSV('SineWave_NaiveFF_PF_100bar_0.05freq_21.04.26.csv');
dataNaiveFF = loadCSV('SineWave_NaiveFF_PF_100bar_0.05freq_22.04.26.csv');
%dataOtherFF2 = loadCSV('SineWave_Other_FF_100bar_0.05freq_fUFF_08.04.26.csv');
%data8Grade = loadCSV('SineWave_8gradePoly_PF_KVFF_100bar_0.05freq_10.04.26.csv');
%data019 = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_10.04.26.csv');
%dataPaLower = loadCSV('SineWave_PaLower_PF_KVFF_100bar_0.05freq_20.04.26.csv');

% Colors
C_red    = [0.9490, 0.1020, 0.0000];
C_lblue   = '#5FC2D9';
C_blue  = '#1E90FF';
C_yellow = '#F29F05';
C_orange = '#F27405';
C_green =  '#2ECC71';
C_purple = '#A020F0';
C_black  = [0.1608, 0.1294, 0.1216];


% =========================================================
% Beregning av kontinuerlig fart fra SineWave CSV-data
% =========================================================

COL_time     = 'fTimer';
COL_fU       = 'fU';
COL_spool    = 'fSpoolPosition';
COL_pSupply  = 'fPs';
COL_pA       = 'fPaLower';
COL_pB       = 'fPb';
COL_flow     = 'fFlow';
COL_position = 'fPistonPosition';

VEL_SMOOTH_SPAN   = 800;        % glattevindu [samples]
VEL_SMOOTH_METHOD = 'gaussian';  % 'sgolay' | 'movmean' | 'gaussian'




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
% Sine trajectory and speed + speed ref
mask = dataKVFF.fTimer >= 0 & dataKVFF.fTimer <= 110;

t_KVFF   = dataKVFF.fTimer(mask);
pos_KVFF = dataKVFF.fPistonPosition(mask);

% Kontinuerlig fart med sgolay (erstatter movmean + mean(diff(dt)))
vSmoothKVFF = smoothdata(gradient(pos_KVFF, t_KVFF), VEL_SMOOTH_METHOD, VEL_SMOOTH_SPAN);

hfig2 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer(mask), dataKVFF.fXRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fPistonPosition(mask), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
xlim([45, 130]);
title('Active Kv FF (100 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.035;

subplot(2,1,2)
plot(dataKVFF.fTimer(mask), dataKVFF.fXDotRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
hold on
plot(dataKVFF.fTimer(mask), vSmoothKVFF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
hold off
grid off
xlim([45, 130]);
ylim([-0.06, 0.06])
xlabel('Time [s]')
ylabel('Velocity [m/s]')
lg = legend('Interpreter', 'latex')
lg.Position(1) = lg.Position(1) + 0.055;
saveFigure(hfig2, 'Subplot_KVFF')


%% Fig3
% KvFF contribution
fU_Smooth = movmean(dataKVFF.fU, 1000);
hfig3 = figure;
plot(dataKVFF.fTimer, fU_Smooth, '-', 'Color', C_black, 'LineWidth', 2, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer, dataKVFF.fU_FF, '-', 'Color', C_blue, 'LineWidth', 2, 'DisplayName', '$u_{FF}$')
%plot(dataKVFF.fTimer, dataKVFF.fUpfb, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
%plot(dataKVFF.fTimer, dataKVFF.fPID, '-', 'Color', '#2ECC71', 'LineWidth', 1.5, 'DisplayName', '$u_{PF}$')
hold off
grid off
xlim([45, 105])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve Signals, Active Kv FF (100 bar, 0.05 Hz)')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.10;
%lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig3, 'KvFF_Contribution')



%% Fig4
% Position Feedback drifting
idxNoPosFB = dataNoPosFB.fTimer >= 0 & dataNoPosFB.fTimer <= 187;
idxKVFF    = dataKVFF.fTimer    >= 0 & dataKVFF.fTimer    <= 85;

hfig4 = figure;
subplot(2,1,1)
plot(dataNoPosFB.fTimer(idxNoPosFB), dataNoPosFB.fXRef(idxNoPosFB), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataNoPosFB.fTimer(idxNoPosFB), dataNoPosFB.fPistonPosition(idxNoPosFB), '-', 'Color', C_red,'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
title('No Position Feedback (100 bar, 0.05 Hz)')
ylabel('Position [m]')
xlim([27,197])
lg = legend('location', 'northwest', 'Interpreter', 'latex');
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
xlim([8,85])
ylim([0.04,0.5])
lg = legend('location', 'northwest', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
lg.Position(2) = lg.Position(2) - 0.01;

saveFigure(hfig4, 'Subplot_NoPosFB_PosFB')

%% Fig5
% PID Signal
idxNoPosFB = dataNoPosFB.fTimer >= 0 & dataNoPosFB.fTimer <= 187;
idxKVFF    = dataKVFF.fTimer    >= 0 & dataKVFF.fTimer    <= 85;
hfig5 = figure;

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

saveFigure(hfig5, 'PID_Signal')


%% Fig6 
% PID Signal lower reversal

% NoPosFB vs KVFF - PistonPosition and XRef subplot (reordered)
idxNoPosFB = dataNoPosFB.fTimer >= 0 & dataNoPosFB.fTimer <= 187;
idxKVFF    = dataKVFF.fTimer    >= 0 & dataKVFF.fTimer    <= 85;
hfig6 = figure;

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

saveFigure(hfig6, 'PID_Signal_Short')





%% Fig7
% Sine trajectory and speed Naive FF

mask = dataNaiveFF.fTimer >= 20 & dataNaiveFF.fTimer <= 110;

t_NaiveFF   = dataNaiveFF.fTimer(mask);
pos_NaiveFF = dataNaiveFF.fPistonPosition(mask);

vSmoothNaiveFF = smoothdata(gradient(pos_NaiveFF, t_NaiveFF), VEL_SMOOTH_METHOD, VEL_SMOOTH_SPAN);

hfig7 = figure;
subplot(2,1,1)
plot(dataNaiveFF.fTimer(mask), dataNaiveFF.fXRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataNaiveFF.fTimer(mask), dataNaiveFF.fPistonPosition(mask), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
xlim([45, 130]);
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
xlim([45, 130]);
ylim([-0.06, 0.06])
xlabel('Time [s]')
ylabel('Velocity [m/s]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.06;
saveFigure(hfig7, 'Subplot_NaiveFF')


%% Fig8
% NaiveFF contribution
fU_Smooth_Naive = movmean(dataNaiveFF.fU, 1000);
hfig8 = figure;
plot(dataNaiveFF.fTimer, fU_Smooth_Naive, '-', 'Color', C_black, 'LineWidth', 2, 'DisplayName', '$u$')
hold on
plot(dataNaiveFF.fTimer, dataNaiveFF.fU_FF_Naive, '-', 'Color', C_blue, 'LineWidth', 2, 'DisplayName', '$u_{FF  naive}$')
hold off
grid off
xlim([45, 105])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve Signals, Active Nominal FF (100 bar, 0.05 Hz)')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.08;
saveFigure(hfig8, 'NaiveFF_Contribution')




%% Fig9
% NaiveFF - PID Signal
maskNaive = dataNaiveFF.fTimer >= 0 & dataNaiveFF.fTimer <= 110;

hfig9 = figure;
plot(dataNaiveFF.fTimer(maskNaive), dataNaiveFF.fU(maskNaive), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataNaiveFF.fTimer, dataNaiveFF.fUpfb, '-', 'Color', C_red, 'LineWidth', 2, 'DisplayName', '$u_{PFB}$')
plot(dataNaiveFF.fTimer(maskNaive), dataNaiveFF.fPID(maskNaive), '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
plot(dataNaiveFF.fTimer, dataNaiveFF.fU_FF_Naive, '-', 'Color', C_blue, 'LineWidth', 2, 'DisplayName', '$u_{FF  nominal}$')
hold off
grid off;
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve Signals, Nominal FF (100 bar, 0.05 Hz)')
xlim([45, 105])
ylim([-0.85, 0.6])
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.08;

saveFigure(hfig9, 'PID_Signal_NaiveFF')


%% FF-bidrag når farten er høyest (fTimer ≈ 82)
% Finn indeksen nærmest t = 82
[~, idx_max_speed] = min(abs(dataKVFF.fTimer - 82));

% Hent verdiene på det punktet
time_at_max_speed  = dataKVFF.fTimer(idx_max_speed);
u_at_max_speed     = dataKVFF.fU(idx_max_speed);
uff_at_max_speed   = dataKVFF.fU_FF(idx_max_speed);
upid_at_max_speed  = dataKVFF.fPID(idx_max_speed);
upfb_at_max_speed  = dataKVFF.fUpfb(idx_max_speed);

% Beregn FF-bidrag i prosent
FF_pct_max_speed = (abs(uff_at_max_speed) / abs(u_at_max_speed)) * 100;

% Vis resultater
fprintf('=== FF-bidrag ved høyest fart (fTimer ≈ 82 s) ===\n');
fprintf('Tid (fTimer): %.3f s\n', time_at_max_speed);
fprintf('\n');
fprintf('u (total):  %.6f\n', u_at_max_speed);
fprintf('uFF:        %.6f\n', uff_at_max_speed);
fprintf('uPID:       %.6f\n', upid_at_max_speed);
fprintf('uPFB:       %.6f\n', upfb_at_max_speed);
fprintf('\n');
fprintf('FF-bidrag: %.2f%%\n', FF_pct_max_speed);







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