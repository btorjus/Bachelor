clc; clear; close all;
% Ctrl R for comment
% Ctrl T for uncomment

% Loading csv
%dataKVFF    = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_26.03.26.csv');
%dataKVFF     = loadCSV('SineWave_PaLower_PF_KVFF_100bar_0.05freq_20.04.26.csv');
dataKVFF02    = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.05freq_23.04.26.csv');
%dataKVFF    = loadCSV('SineWave_PaLower_PF_KVFF_100bar_0.05freq_21.04.26.csv');

%dataKVFF    = loadCSV('SineWave_speedtreshold0.005_KvFF_PF_100bar_0.025freq_24.04.26.csv');
%dataKVFF     = loadCSV('SineWave_speedtreshold0.008_KvFF_PF_100bar_0.025freq_24.04.26.csv');
%dataKVFF       = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.05freq_24.04.26.csv');
dataKVFF     = loadCSV('SineWave_speedtreshold0.02_KvFF_PF_100bar_0.075freq_24.04.26.csv');

%dataNoFF    = loadCSV('SineWave_NoFF_PF_KVFF_100bar_0.05freq_31.03.26.csv');
%dataNoPosFB = loadCSV('SineWave_NoPositionFeedback_PF_KVFF_100bar_0.05freq_31.03.26.csv');
%dataOtherFF = loadCSV('SineWave_OtherFF_PF_100bar_0.05freq_31.03.26.csv');
%dataOtherFF2 = loadCSV('SineWave_Other_FF_100bar_0.05freq_fUFF_08.04.26.csv');
%data8Grade = loadCSV('SineWave_8gradePoly_PF_KVFF_100bar_0.05freq_10.04.26.csv');
%data019 = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_10.04.26.csv');

% Colors
C_red    = [0.9490, 0.1020, 0.0000];
C_lblue   = '#5FC2D9';
C_blue  = '#1E90FF';
C_yellow = '#F29F05';
C_orange = '#F27405';
C_green =  '#2ECC71';
C_purple = '#A020F0';
C_black  = [0.1608, 0.1294, 0.1216];



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
xlim([30, 105])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve \& Control Signals - Speed Cut: 0.01 (100 bar, 0.05 Hz)', 'FontWeight', 'normal')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.060;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig1, 'AllSignals')

%% Fig02
% All Control Signals

fU_Smooth = movmean(dataKVFF02.fU, 1);
hfig02 = figure;
plot(dataKVFF02.fTimer, fU_Smooth, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataKVFF02.fTimer, dataKVFF02.fU_FF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{FF}$')
plot(dataKVFF02.fTimer, dataKVFF02.fUpfb, '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataKVFF02.fTimer, dataKVFF02.fPID, '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off
xlim([30, 105])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve \& Control Signals - Speed Cut: 0.02 (100 bar, 0.05 Hz)', 'FontWeight', 'normal')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.060;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig02, 'AllSignals02')





%% Fig2
% All signals subplot
mask = dataKVFF.fTimer <= 200;

dt = mean(diff(dataKVFF.fTimer));
fU_Smooth_KVFF = movmean(dataKVFF.fU, 1);

hfig2 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer(mask), dataKVFF.fXRef(mask), '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fPistonPosition(mask), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
hold off
grid off;
xlim([30, 110]);
title('Sinusoidal Trajectory (100 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.07;
lg.Position(2) = lg.Position(2) - 0.01;

subplot(2,1,2)
plot(dataKVFF.fTimer(mask), fU_Smooth_KVFF(mask), '-', 'Color', C_black, 'LineWidth', 2, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fU_FF(mask), '-', 'Color', C_blue, 'LineWidth', 2, 'DisplayName', '$u_{FF}$')
plot(dataKVFF.fTimer(mask), dataKVFF.fUpfb(mask), '-', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataKVFF.fTimer(mask), dataKVFF.fPID(mask), '-', 'Color', C_green, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off
xlim([30, 110]);
xlabel('Time [s]')
ylabel('Signal [-]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.035;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig2, 'AllSignals_Subplot')




%% Beregn FF-bidrag prosent on average
% Fjern rader der fU er nær null OG fTimer < 10
valid_idx = (abs(dataKVFF.fU) > 0.01) & (dataKVFF.fTimer > 10);

% Beregn prosentandeler
FF_percentage = (abs(dataKVFF.fU_FF(valid_idx)) ./ abs(dataKVFF.fU(valid_idx))) * 100;
PID_percentage = (abs(dataKVFF.fPID(valid_idx)) ./ abs(dataKVFF.fU(valid_idx))) * 100;
PFB_percentage = (abs(dataKVFF.fUpfb(valid_idx)) ./ abs(dataKVFF.fU(valid_idx))) * 100;

% Finn gjennomsnittene
avg_ff = nanmean(FF_percentage);
avg_pid = nanmean(PID_percentage);
avg_pfb = nanmean(PFB_percentage);
total_avg = avg_ff + avg_pid - avg_pfb;  % RIKTIG: minus PFB

% Vis resultater
fprintf('=== Gjennomsnittlig bidrag til ventilsignal ===\n');
fprintf('Feed-Forward (FF):       %.2f%%\n', avg_ff);
fprintf('Position Feedback (PID): %.2f%%\n', avg_pid);
fprintf('Pressure Feedback (PFB): %.2f%%\n', avg_pfb);
fprintf('Totalt:                  %.2f%%\n', total_avg);
fprintf('\nAntall gyldige datapunkter: %d / %d\n', sum(valid_idx), length(dataKVFF.fU));





%% Hvor FF bidrar minst
% Filter: fTimer > 10 OG fU > 0.01
valid_idx = (dataKVFF.fTimer > 10) & (abs(dataKVFF.fU) > 0.01);
FF_percentage = (abs(dataKVFF.fU_FF(valid_idx)) ./ abs(dataKVFF.fU(valid_idx))) * 100;
% Finn minimum
[min_ff_pct, min_idx_in_valid] = min(FF_percentage);
% Finn indeksen i original data
min_idx_original = find(valid_idx);
min_idx_original = min_idx_original(min_idx_in_valid);
% Hent verdiene på det punktet
time_at_min = dataKVFF.fTimer(min_idx_original);
u_at_min = dataKVFF.fU(min_idx_original);
uff_at_min = dataKVFF.fU_FF(min_idx_original);
upid_at_min = dataKVFF.fPID(min_idx_original);
upfb_at_min = dataKVFF.fUpfb(min_idx_original);
pos_at_min = dataKVFF.fPistonPosition(min_idx_original);
% Vis resultater
fprintf('=== Hvor FF bidrar MINST ===\n');
fprintf('Tid (fTimer): %.3f s\n', time_at_min);
fprintf('\n');
fprintf('u (total):  %.14f\n', u_at_min);
fprintf('uFF:        %.14f\n', uff_at_min);
fprintf('uPID:       %.14f\n', upid_at_min);
fprintf('uPFB:       %.14f\n', upfb_at_min);
fprintf('\n');
fprintf('FF-bidrag: %.14f%%\n', min_ff_pct);






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