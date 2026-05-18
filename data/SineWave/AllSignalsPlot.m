clc; clear; close all;

% 100bar
dataKVFF        = loadCSV('SineWave_KVFF_100bar_0.025freq_04.05.26.csv');
%dataKVFF       = loadCSV('SineWave_KVFF_100bar_0.05freq_04.05.26(2).csv');
%dataKVFF       = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.075freq_24.04.26.csv');

% 120bar
%dataKVFF       = loadCSV('-Pa_120bar_0.075_13.05.26.csv');
%dataKVFF       = loadCSV('-Pa_120bar_0.05_13.05.26.csv');
%dataKVFF       = loadCSV('pB_120bar_0.025_13.05.26.csv');

% Other
dataNaiveFF     = loadCSV('SineWave_NaiveFF_PF_100bar_0.05freq_22.04.26.csv');
dataRamp        = loadCSV('Ramp_04.05.26.csv');


% Colors
C_red    = [0.9490, 0.1020, 0.0000];
C_lblue   = '#5FC2D9';
C_blue  = '#1E90FF';
C_yellow = '#F29F05';
C_orange = '#F27405';
C_green =  '#2ECC71';
C_purple = '#A020F0';
C_black  = [0.1608, 0.1294, 0.1216];

VEL_SMOOTH_METHOD = 'movmean';
VEL_SMOOTH_SPAN   = 50;



%% Fig1
% All Control Signals
fU_Smooth = movmean(dataKVFF.fU, 1);
hfig1 = figure;
plot(dataKVFF.fTimer, fU_Smooth, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer, dataKVFF.fU_FF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{FF}$')
plot(dataKVFF.fTimer, dataKVFF.fUpfb, '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataKVFF.fTimer, dataKVFF.fPID, '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off
xlim([12, 47])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve \& Control Signals (120 bar, 0.05 Hz)', 'FontWeight', 'normal')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.090;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig1, 'AllSignals')


%% Fig2
% All signals subplot
mask = dataKVFF.fTimer <= 92;
dt = mean(diff(dataKVFF.fTimer));
fU_Smooth_KVFF = movmean(dataKVFF.fU, 1);
hfig2 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer(mask), dataKVFF.fXRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fPistonPosition(mask), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
xlim([12, 100]);
title('Sinusoidal Trajectory (120 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.045;
lg.Position(2) = lg.Position(2) - 0.01;

subplot(2,1,2)
plot(dataKVFF.fTimer(mask), fU_Smooth_KVFF(mask), '-', 'Color', C_black, 'LineWidth', 2, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fU_FF(mask), '-', 'Color', C_blue, 'LineWidth', 2, 'DisplayName', '$u_{FF}$')
plot(dataKVFF.fTimer(mask), dataKVFF.fUpfb(mask), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataKVFF.fTimer(mask), dataKVFF.fPID(mask), '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off
xlim([12, 100]);
xlabel('Time [s]')
ylabel('Signal [-]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.06;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig2, 'AllSignals_Subplot')


%% Fig3
% Lowest percentage point closeup
fU_Smooth = movmean(dataKVFF.fU, 1);
hfig3 = figure;
plot(dataKVFF.fTimer, fU_Smooth, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer, dataKVFF.fU_FF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{FF}$')
plot(dataKVFF.fTimer, dataKVFF.fUpfb, '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataKVFF.fTimer, dataKVFF.fPID, '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
xline(67.332, '--', 'Color', C_orange, 'LineWidth', 1.5, 'HandleVisibility', 'off')
text(67.332 + 0.05, 0.45, '$t = 67.33$ s', 'Interpreter', 'latex', 'FontSize', 15, 'Color', C_orange)
hold off
grid off
ylim([-0.1, 0.5])
xlim([64,75])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve \& Control Signals (100 bar, 0.05 Hz)', 'FontWeight', 'normal')
lg = legend('location', 'northwest', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.060;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig3, 'AllSignals_LowPercent')


%% Fig4
% Ramp Trajectory
mask = dataRamp.fTimer <= 200;
hfig4 = figure;
plot(dataRamp.fTimer(mask), dataRamp.fPistonPosition(mask), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$x$')
hold off
grid off;
xlim([23, 44]);
title('Cylinder Position (100 bar) - Ramp Trajectory')
xlabel('Time [s]')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.045;
lg.Position(2) = lg.Position(2) - 0.01;
saveFigure(hfig4, 'RampPosition')


%% Fig5
% Sine Wave reference trajectory and speed
mask = dataKVFF.fTimer <= 100;
hfig5 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer(mask), dataKVFF.fXRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
grid off
xlim([12, 75])
ylabel('Position [m]')
title('Sine Wave Trajectory (0.05 Hz)', 'FontWeight', 'normal')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.045;
lg.Position(2) = lg.Position(2) - 0.01;

subplot(2,1,2)
plot(dataKVFF.fTimer(mask), dataKVFF.fXDotRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
grid off
xlim([12, 75])
xlabel('Time [s]')
ylabel('Velocity [m/s]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.045;
lg.Position(2) = lg.Position(2) - 0.01;

saveFigure(hfig5, 'XRef_XDotRef_Subplot')


%% Fig6 
% NaiveFF - All Control Signals
fU_Smooth_Naive = movmean(dataNaiveFF.fU, 1);

hfig6 = figure;
plot(dataNaiveFF.fTimer, fU_Smooth_Naive, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataNaiveFF.fTimer, dataNaiveFF.fU_FF_Naive, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{FF,Naive}$')
plot(dataNaiveFF.fTimer, dataNaiveFF.fUpfb, '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataNaiveFF.fTimer, dataNaiveFF.fPID, '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off
xlim([45, 105])
%ylim([-0.2, 0.3])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve \& Control Signals - Naive FF (100 bar, 0.05 Hz)', 'FontWeight', 'normal')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.060;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig6, 'AllSignals_NaiveFF')


%% Fig7 
% Naive FF, valve signals and speed ref
hfig7 = figure;

subplot(2,1,1)
plot(dataNaiveFF.fTimer, fU_Smooth_Naive, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataNaiveFF.fTimer, dataNaiveFF.fU_FF_Naive, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{FF,Naive}$')
plot(dataNaiveFF.fTimer, dataNaiveFF.fUpfb, '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataNaiveFF.fTimer, dataNaiveFF.fPID, '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
xline(57, '--', 'Color', C_black, 'LineWidth', 1.5, 'HandleVisibility', 'off')
hold off
grid off
%xlim([55, 59])
xlim([50, 65])
ylim([-0.2, 0.3])
ylabel('Signal [-]')
title('Valve \& Control Signals - Naive FF (100 bar, 0.05 Hz)', 'FontWeight', 'normal')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.060;
lg.Position(2) = lg.Position(2) - 0.019;

subplot(2,1,2)
plot(dataNaiveFF.fTimer(mask), dataNaiveFF.fXDotRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
hold on
plot(dataNaiveFF.fTimer(mask), vSmoothNaiveFF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
xline(57, '--', 'Color', C_black, 'LineWidth', 1.5, 'HandleVisibility', 'off')
hold off
grid off
xlim([50, 65])
ylim([-0.06, 0.1])
xlabel('Time [s]')
ylabel('Velocity [m/s]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.04;

saveFigure(hfig7, 'AllSignals_NaiveFF_Combined')


%% FF least percentage
valid_idx = (dataKVFF.fTimer > 10) & (abs(dataKVFF.fU) > 0.01);
FF_percentage = (abs(dataKVFF.fU_FF(valid_idx)) ./ abs(dataKVFF.fU(valid_idx))) * 100;
[min_ff_pct, min_idx_in_valid] = min(FF_percentage);
min_idx_original = find(valid_idx);
min_idx_original = min_idx_original(min_idx_in_valid);
time_at_min = dataKVFF.fTimer(min_idx_original);
u_at_min = dataKVFF.fU(min_idx_original);
uff_at_min = dataKVFF.fU_FF(min_idx_original);
upid_at_min = dataKVFF.fPID(min_idx_original);
upfb_at_min = dataKVFF.fUpfb(min_idx_original);
pos_at_min = dataKVFF.fPistonPosition(min_idx_original);

fprintf('=== Hvor FF bidrar MINST ===\n');
fprintf('Tid (fTimer): %.3f s\n', time_at_min);
fprintf('\n');
fprintf('u (total):  %.14f\n', u_at_min);
fprintf('uFF:        %.14f\n', uff_at_min);
fprintf('uPID:       %.14f\n', upid_at_min);
fprintf('uPFB:       %.14f\n', upfb_at_min);
fprintf('\n');
fprintf('FF-bidrag: %.14f%%\n', min_ff_pct);


%% FF percentage at high velocity 
% set point:
[~, idx_max_speed] = min(abs(dataKVFF.fTimer - 48.65));

time_at_max_speed  = dataKVFF.fTimer(idx_max_speed);
u_at_max_speed     = dataKVFF.fU(idx_max_speed);
uff_at_max_speed   = dataKVFF.fU_FF(idx_max_speed);
upid_at_max_speed  = dataKVFF.fPID(idx_max_speed);
upfb_at_max_speed  = dataKVFF.fUpfb(idx_max_speed);
FF_pct_max_speed = (abs(uff_at_max_speed) / abs(u_at_max_speed)) * 100;

fprintf('=== FF-bidrag ved høyest fart ===\n');
fprintf('Tid (fTimer): %.3f s\n', time_at_max_speed);
fprintf('\n');
fprintf('u (total):  %.6f\n', u_at_max_speed);
fprintf('uFF:        %.6f\n', uff_at_max_speed);
fprintf('uPID:       %.6f\n', upid_at_max_speed);
fprintf('uPFB:       %.6f\n', upfb_at_max_speed);
fprintf('\n');
fprintf('FF-bidrag: %.2f%%\n', FF_pct_max_speed);


%% Nominal FF least percentage
valid_idx_naive = (dataNaiveFF.fTimer > 40) & (abs(dataNaiveFF.fU) > 0.01);
FF_percentage_naive = (abs(dataNaiveFF.fU_FF_Naive(valid_idx_naive)) ./ abs(dataNaiveFF.fU(valid_idx_naive))) * 100;
[min_ff_pct_naive, min_idx_in_valid_naive] = min(FF_percentage_naive);
min_idx_original_naive = find(valid_idx_naive);
min_idx_original_naive = min_idx_original_naive(min_idx_in_valid_naive);
time_at_min_naive = dataNaiveFF.fTimer(min_idx_original_naive);
u_at_min_naive    = dataNaiveFF.fU(min_idx_original_naive);
uff_at_min_naive  = dataNaiveFF.fU_FF_Naive(min_idx_original_naive);
upid_at_min_naive = dataNaiveFF.fPID(min_idx_original_naive);
upfb_at_min_naive = dataNaiveFF.fUpfb(min_idx_original_naive);

fprintf('=== Hvor NaiveFF bidrar MINST ===\n');
fprintf('Tid (fTimer): %.3f s\n', time_at_min_naive);
fprintf('\n');
fprintf('u (total):  %.14f\n', u_at_min_naive);
fprintf('uFF_Naive:  %.14f\n', uff_at_min_naive);
fprintf('uPID:       %.14f\n', upid_at_min_naive);
fprintf('uPFB:       %.14f\n', upfb_at_min_naive);
fprintf('\n');
fprintf('NaiveFF-bidrag: %.14f%%\n', min_ff_pct_naive);


%% NaiveFF contribution at high speed (set value for timer)
[~, idx_max_speed_naive] = min(abs(dataNaiveFF.fTimer - 62));

time_at_max_speed_naive  = dataNaiveFF.fTimer(idx_max_speed_naive);
u_at_max_speed_naive     = dataNaiveFF.fU(idx_max_speed_naive);
uff_at_max_speed_naive   = dataNaiveFF.fU_FF_Naive(idx_max_speed_naive);
upid_at_max_speed_naive  = dataNaiveFF.fPID(idx_max_speed_naive);
upfb_at_max_speed_naive  = dataNaiveFF.fUpfb(idx_max_speed_naive);
FF_pct_max_speed_naive = (abs(uff_at_max_speed_naive) / abs(u_at_max_speed_naive)) * 100;

fprintf('=== NaiveFF contribution at highest speed (fTimer ≈ 62 s) ===\n');
fprintf('Tid (fTimer): %.3f s\n', time_at_max_speed_naive);
fprintf('\n');
fprintf('u (total):  %.6f\n', u_at_max_speed_naive);
fprintf('uFF_Naive:  %.6f\n', uff_at_max_speed_naive);
fprintf('uPID:       %.6f\n', upid_at_max_speed_naive);
fprintf('uPFB:       %.6f\n', upfb_at_max_speed_naive);
fprintf('\n');
fprintf('NaiveFF contribution: %.2f%%\n', FF_pct_max_speed_naive);


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