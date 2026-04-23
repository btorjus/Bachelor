clc; clear; close all;
% Ctrl R for comment
% Ctrl T for uncomment

%% Loading csv
%dataKVFF    = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_26.03.26.csv');
dataKVFF     = loadCSV('SineWave_PaLower_PF_KVFF_100bar_0.05freq_20.04.26.csv');
dataNoFF    = loadCSV('SineWave_NoFF_PF_KVFF_100bar_0.05freq_31.03.26.csv');
dataNoPosFB = loadCSV('SineWave_NoPositionFeedback_PF_KVFF_100bar_0.05freq_31.03.26.csv');
dataOtherFF = loadCSV('SineWave_OtherFF_PF_100bar_0.05freq_31.03.26.csv');
dataOtherFF2 = loadCSV('SineWave_Other_FF_100bar_0.05freq_fUFF_08.04.26.csv');
data8Grade = loadCSV('SineWave_8gradePoly_PF_KVFF_100bar_0.05freq_10.04.26.csv');
data019 = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_10.04.26.csv');

%% Fig1
% All Control Signals

fU_Smooth = movmean(dataKVFF.fU, 1);
hfig1 = figure;
plot(dataKVFF.fTimer, fU_Smooth, '-', 'Color', '#000000', 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer, dataKVFF.fU_FF, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$u_{FF}$')
plot(dataKVFF.fTimer, dataKVFF.fUpfb, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataKVFF.fTimer, dataKVFF.fPID, '-', 'Color', '#2ECC71', 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off
xlim([30, 105])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve & Control Signals (100 bar, 0.05 Hz)', 'FontWeight', 'normal')
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.060;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig1, 'AllSignals')



%% Fig2
% All signals subplot
mask = dataKVFF.fTimer <= 92;

dt = mean(diff(dataKVFF.fTimer));
vActualKVFF = gradient(dataKVFF.fPistonPosition, dt);
vSmoothKVFF = movmean(vActualKVFF, 1000);

hfig2 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer(mask), dataKVFF.fXRef(mask), '-', 'Color', '#000000', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fPistonPosition(mask), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
hold off
grid off;
xlim([30, 110]);
title('Sinusoidal Trajectory (100 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.07;
lg.Position(2) = lg.Position(2) - 0.01;

subplot(2,1,2)
plot(dataKVFF.fTimer(mask), fU_Smooth(mask), '-', 'Color', '#000000', 'LineWidth', 2, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fU_FF(mask), '-', 'Color', '#1E90FF', 'LineWidth', 2, 'DisplayName', '$u_{FF}$')
plot(dataKVFF.fTimer(mask), dataKVFF.fUpfb(mask), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(dataKVFF.fTimer(mask), dataKVFF.fPID(mask), '-', 'Color', '#2ECC71', 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off
xlim([30, 110]);
xlabel('Time [s]')
ylabel('Signal [-]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.035;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig2, 'AllSignals_Subplot')







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