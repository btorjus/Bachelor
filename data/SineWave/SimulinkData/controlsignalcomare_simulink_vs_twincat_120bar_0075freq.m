clc; clear; close all;

%% Load data
% Measured (real system) - 0.075 Hz, speed threshold 0.02
dataKVFF = loadCSV('../SineWave_120bar_0.075_14.05.26.csv');
%dataKVFF = loadCSV('../SineWave_KVFF_100bar_0.075freq_04.05.26.csv');

% Sign convention: real system uses opposite sign for control signals
dataKVFF.fU     = -dataKVFF.fU;
dataKVFF.fU_FF  = -dataKVFF.fU_FF;
dataKVFF.fPID   = -dataKVFF.fPID;
dataKVFF.fUpfb  = -dataKVFF.fUpfb;

% Pressure aliases (project convention)100
dataKVFF.fPS  = dataKVFF.fPs;
dataKVFF.fPA1 = dataKVFF.fPaLower;       % DCV -> CBV   
dataKVFF.fPA2 = dataKVFF.fPa;            % CBV -> cylinder bore
dataKVFF.fPB  = dataKVFF.fPb;            % rod side

% Simulation (Simscape) - matching 0.075 Hz case
dataSim = loadSim('SineWave_KVFF_120Bar_0.075freq_8kp_110526_Simulink.mat');

% Time alignment - shift sim forward if its trajectory starts at t=0
% (Measured trajectory begins around t=30 s)
t_offset = -1.33;
dataSim.fTimer = dataSim.fTimer + t_offset;

%% Colors
C_red    = [0.9490, 0.0196, 0.0196];  % #F20505
C_blue   = [0.3725, 0.7608, 0.8510];  % #5FC2D9
C_lblue  = [0.0118, 0.6510, 0.5333];  % #03A688
C_yellow = [0.9490, 0.6235, 0.0196];  % #F29F05
C_orange = [0.9490, 0.4549, 0.0196];  % #F27405
C_black  = [0.1608, 0.1294, 0.1216];

%% Fig1 - Position tracking comparison
hfig1 = figure;
plot(dataKVFF.fTimer, dataKVFF.fXRef, '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer, dataKVFF.fPistonPosition, '-', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', '$x_{meas}$')
plot(dataSim.fTimer,  dataSim.fPistonPosition,  '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$x_{sim}$')
hold off
grid off
xlim([44, 46.75])
xlabel('Time [s]')
ylabel('Position [m]')
title('Position Tracking - Measured vs.\ Simulated (120 bar, 0.075 Hz)', 'FontWeight', 'normal')
legend('location', 'northeast', 'Interpreter', 'latex')
formatFigure(hfig1)
saveFigure(hfig1, 'PositionComparison075')

%% Fig2 - Total valve signal comparison
hfig2 = figure;
plot(dataKVFF.fTimer, dataKVFF.fU, '-', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', 'Measured $u$')
hold on
plot(dataSim.fTimer,  dataSim.fU,  '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', 'Simulated $u$')
hold off
grid off
xlim([30, 65])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Total Valve Signal - Measured vs.\ Simulated', 'FontWeight', 'normal')
legend('location', 'northeast', 'Interpreter', 'latex')
formatFigure(hfig2)
% saveFigure(hfig2, 'USignalComparison075')

%% Fig3 - Control components subplot
hfig3 = figure;
subplot(3,1,1)
plot(dataKVFF.fTimer, dataKVFF.fU_FF, '-', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', '$u_{meas}$')
hold on
plot(dataSim.fTimer,  dataSim.fU_FF, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{sim}$')
hold off
xlim([30, 65])
ylabel('$u_{FF}$ [-]')
title('Control Signal Components')
legend('Location','northeast')

subplot(3,1,2)
plot(dataKVFF.fTimer, dataKVFF.fPID, '-', 'Color', C_red,  'LineWidth', 1.5)
hold on
plot(dataSim.fTimer,  dataSim.fPID, '-', 'Color', C_blue, 'LineWidth', 1.5)
hold off
xlim([30, 65])
ylabel('$u_{PID}$ [-]')

subplot(3,1,3)
plot(dataKVFF.fTimer, dataKVFF.fUpfb, '-', 'Color', C_red,  'LineWidth', 1.5)
hold on
plot(dataSim.fTimer,  dataSim.fUpfb, '-', 'Color', C_blue, 'LineWidth', 1.5)
hold off
xlim([30, 65])
xlabel('Time [s]')
ylabel('$u_{PFB}$ [-]')
formatFigure(hfig3)
saveFigure(hfig3, 'ControlComponentsComparison075')

%% Fig4 - Position + total signal subplot
mask = dataKVFF.fTimer <= 200;
hfig4 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer(mask), dataKVFF.fXRef(mask),          '-', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold on
plot(dataKVFF.fTimer(mask), dataKVFF.fPistonPosition(mask),'-', 'Color', C_red,   'LineWidth', 1.5, 'DisplayName', 'Measured')
plot(dataSim.fTimer,        dataSim.fPistonPosition,       '-', 'Color', C_blue,  'LineWidth', 1.5, 'DisplayName', 'Simulated')
hold off
grid off
xlim([30, 65])
title('Sinusoidal Trajectory (120 bar, 0.075 Hz)')
ylabel('Position [m]')
legend('Location','best')

subplot(2,1,2)
plot(dataKVFF.fTimer(mask), dataKVFF.fU(mask), '-', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', 'Measured $u$')
hold on
plot(dataSim.fTimer,        dataSim.fU,        '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', 'Simulated $u$')
hold off
grid off
xlim([30, 65])
xlabel('Time [s]')
ylabel('Signal [-]')
legend('Location','best')
formatFigure(hfig4)
% saveFigure(hfig4, 'AllSignals_Comparison_Subplot075')

%% Fig5 - Pressure comparison
hfig5 = figure;
subplot(4,1,1)
plot(dataKVFF.fTimer, dataKVFF.fPS,    '-', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', '$p_{meas}$')
hold on
plot(dataSim.fTimer,  dataSim.fPS/1e5, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$p_{sim}$')
hold off
xlim([30, 65])
ylim([110, 130])
ylabel('$p_s$ [bar]')
title('Pressure Comparison (120 bar, 0.075 Hz)')
legend('Location','northwest', 'NumColumns',2)

subplot(4,1,2)
plot(dataKVFF.fTimer, dataKVFF.fPA1,    '-', 'Color', C_red,  'LineWidth', 1.5)
hold on
plot(dataSim.fTimer,  dataSim.fPA1/1e5, '-', 'Color', C_blue, 'LineWidth', 1.5)
hold off
xlim([30, 65])
%ylim([0, 150])
ylabel('$p_{A1}$ [bar]')

subplot(4,1,3)
plot(dataKVFF.fTimer, dataKVFF.fPA2,    '-', 'Color', C_red,  'LineWidth', 1.5)
hold on
plot(dataSim.fTimer,  dataSim.fPA2, '-', 'Color', C_blue, 'LineWidth', 1.5)
hold off
xlim([30, 65])
%ylim([0, 150])
ylabel('$p_{A2}$ [bar]')

subplot(4,1,4)
plot(dataKVFF.fTimer, dataKVFF.fPB,    '-', 'Color', C_red,  'LineWidth', 1.5)
hold on
plot(dataSim.fTimer,  dataSim.fPB, '-', 'Color', C_blue, 'LineWidth', 1.5)
hold off
xlim([30, 65])
%ylim([0, 60])
xlabel('Time [s]')
ylabel('$p_B$ [bar]')
formatFigure(hfig5)
saveFigure(hfig5, 'PressureComparison075')

%% FF/PID/PFB contribution (Measured)
valid_idx = (abs(dataKVFF.fU) > 0.01) & (dataKVFF.fTimer > 10);
FF_pct  = (abs(dataKVFF.fU_FF(valid_idx))  ./ abs(dataKVFF.fU(valid_idx))) * 100;
PID_pct = (abs(dataKVFF.fPID(valid_idx))   ./ abs(dataKVFF.fU(valid_idx))) * 100;
PFB_pct = (abs(dataKVFF.fUpfb(valid_idx))  ./ abs(dataKVFF.fU(valid_idx))) * 100;

fprintf('=== Measured: avg contribution to valve signal ===\n');
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
         4, 'fPS'; ...     % supply
         2, 'fPA1'; ...    % DCV -> CBV
         3, 'fPB_F'; ...   % DCV port B (kept for completeness)
        13, 'fPA2'; ...    % CBV -> cylinder bore
        14, 'fPB'; ...     % cylinder rod
        11, 'fPX'; ...
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
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', 11)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
end

function saveFigure(hfig, fname)
    picturewidth = 20;
    hw_ratio = 0.35;
    formatFigure(hfig)
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig, 'Position');
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', 'PaperSize', [pos(3), pos(4)])
    print(hfig, fname, '-dpdf', '-vector', '-fillpage')
end