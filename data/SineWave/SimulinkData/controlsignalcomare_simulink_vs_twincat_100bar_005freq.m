clc; clear; close all;

%% Load data
% Actual (real system) - 0.05 Hz, speed threshold 0.02
dataKVFF = loadCSV('../SineWave_speedtreshold0.02_KvFF_PF_100bar_0.05freq_23.04.26.csv');

% Sign convention: real system uses opposite sign for control signals
dataKVFF.fU     = -dataKVFF.fU;
dataKVFF.fU_FF  = -dataKVFF.fU_FF;
dataKVFF.fPID   = -dataKVFF.fPID;
dataKVFF.fUpfb  = -dataKVFF.fUpfb;

% Simulation (Simscape) - matching 0.05 Hz case
dataSim = loadSim('SineWave_KVFF_100Bar_0.05freq_2kp_040526_Simulink.mat');

% Time alignment - shift sim forward if its trajectory starts at t=0
% (Actual trajectory begins around t=30 s)
t_offset = -3;
dataSim.fTimer = dataSim.fTimer + t_offset;

%% Colors
C_red    = [0.9490, 0.1020, 0.0000];
C_lblue  = '#5FC2D9';
C_blue   = '#1E90FF';
C_yellow = '#F29F05';
C_orange = '#F27405';
C_green  = '#2ECC71';
C_purple = '#A020F0';
C_black  = [0.1608, 0.1294, 0.1216];

%% Fig1 - Position tracking comparison
hfig1 = figure;
plot(dataKVFF.fTimer, dataKVFF.fXRef, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer, dataKVFF.fPistonPosition, '-', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', 'Actual')
plot(dataSim.fTimer,  dataSim.fPistonPosition,  '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', 'Simulation')
hold off
grid off
xlim([30, 80])
xlabel('Time [s]')
ylabel('Position [m]')
title('Position Tracking - Actual vs.\ Simulation (100 bar, 0.05 Hz)', 'FontWeight', 'normal')
legend('location', 'northeast', 'Interpreter', 'latex')
formatFigure(hfig1)
% saveFigure(hfig1, 'PositionComparison')

%% Fig2 - Total valve signal comparison
hfig2 = figure;
plot(dataKVFF.fTimer, dataKVFF.fU, '-', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', 'Actual $u$')
hold on
plot(dataSim.fTimer,  dataSim.fU,  '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', 'Simulation $u$')
hold off
grid off
xlim([30, 80])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Total Valve Signal - Actual vs.\ Simulation', 'FontWeight', 'normal')
legend('location', 'northeast', 'Interpreter', 'latex')
formatFigure(hfig2)
% saveFigure(hfig2, 'USignalComparison')

%% Fig3 - Control components subplot
hfig3 = figure;
subplot(3,1,1)
plot(dataKVFF.fTimer, dataKVFF.fU_FF, '-', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', 'Actual')
hold on
plot(dataSim.fTimer,  dataSim.fU_FF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', 'Simulation')
hold off
xlim([30, 80])
ylabel('$u_{FF}$ [-]')
title('Control Signal Components')
legend('Interpreter', 'latex')

subplot(3,1,2)
plot(dataKVFF.fTimer, dataKVFF.fPID, '-', 'Color', C_red,  'LineWidth', 1.5)
hold on
plot(dataSim.fTimer,  dataSim.fPID, '-', 'Color', C_blue, 'LineWidth', 1.5)
hold off
xlim([30, 80])
ylabel('$u_{PID}$ [-]')

subplot(3,1,3)
plot(dataKVFF.fTimer, dataKVFF.fUpfb, '-', 'Color', C_red,  'LineWidth', 1.5)
hold on
plot(dataSim.fTimer,  dataSim.fUpfb, '-', 'Color', C_blue, 'LineWidth', 1.5)
hold off
xlim([30, 80])
xlabel('Time [s]')
ylabel('$u_{PFB}$ [-]')
formatFigure(hfig3)
% saveFigure(hfig3, 'ControlComponentsComparison')

%% Fig4 - Position + total signal subplot
mask = dataKVFF.fTimer <= 200;
hfig4 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer(mask), dataKVFF.fXRef(mask),          '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fPistonPosition(mask),'-', 'Color', C_red,   'LineWidth', 1.5, 'DisplayName', 'Actual')
plot(dataSim.fTimer,        dataSim.fPistonPosition,       '-', 'Color', C_blue,  'LineWidth', 1.5, 'DisplayName', 'Simulation')
hold off
grid off
xlim([30, 80])
title('Sinusoidal Trajectory (100 bar, 0.05 Hz)')
ylabel('Position [m]')
legend('Interpreter', 'latex')

subplot(2,1,2)
plot(dataKVFF.fTimer(mask), dataKVFF.fU(mask), '-', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', 'Actual $u$')
hold on
plot(dataSim.fTimer,        dataSim.fU,        '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', 'Simulation $u$')
hold off
grid off
xlim([30, 80])
xlabel('Time [s]')
ylabel('Signal [-]')
legend('Interpreter', 'latex')
formatFigure(hfig4)
% saveFigure(hfig4, 'AllSignals_Comparison_Subplot')

%% FF/PID/PFB contribution (Actual)
valid_idx = (abs(dataKVFF.fU) > 0.01) & (dataKVFF.fTimer > 10);
FF_pct  = (abs(dataKVFF.fU_FF(valid_idx))  ./ abs(dataKVFF.fU(valid_idx))) * 100;
PID_pct = (abs(dataKVFF.fPID(valid_idx))   ./ abs(dataKVFF.fU(valid_idx))) * 100;
PFB_pct = (abs(dataKVFF.fUpfb(valid_idx))  ./ abs(dataKVFF.fU(valid_idx))) * 100;

fprintf('=== Actual: avg contribution to valve signal ===\n');
fprintf('Feed-Forward (FF):       %.2f%%\n', mean(FF_pct,  'omitnan'));
fprintf('Position Feedback (PID): %.2f%%\n', mean(PID_pct, 'omitnan'));
fprintf('Pressure Feedback (PFB): %.2f%%\n', mean(PFB_pct, 'omitnan'));

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

function data = loadSim(filename)
    S  = load(filename);
    ds = S.data;
    map = { ...
        15, 'fU'; ...
         1, 'fU_FF'; ...
        12, 'fUpfb'; ...
        10, 'fPID'; ...
         8, 'fXRef'; ...
        21, 'fPistonPosition'; ...
         2, 'fPA_F'; ...
         3, 'fPB_F'; ...
         4, 'fPP_F'; ...
        11, 'fPX'; ...
        13, 'fPA_Cyl_Bf'; ...
        14, 'fPB_Bf'; ...
        16, 'fError'; ...
        20, 'fF_fric'; ...
        22, 'fVel'; ...
    };
    tref = ds{8}.Values.Time;
    data.fTimer = tref;
    for k = 1:size(map,1)
        ts = ds{map{k,1}}.Values;
        data.(map{k,2}) = interp1(ts.Time, ts.Data, tref, 'linear', 'extrap');
    end
end

function formatFigure(hfig)
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', 15)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
end

function saveFigure(hfig, fname)
    picturewidth = 20;
    hw_ratio = 0.75;
    formatFigure(hfig)
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig, 'Position');
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', 'PaperSize', [pos(3), pos(4)])
    print(hfig, fname, '-dpdf', '-painters', '-fillpage')
end