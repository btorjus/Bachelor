clc; clear; close all;

%% 100 bar, 10 signal
data1 = loadCSV('100bar_10signal_NoPF_26.03.26.csv');
data2 = loadCSV('100bar_10signal_PF_26.03.26.csv');
% Piston Position
plotPistonPosition(data1, data2, 'No PF', 'With PF', 71, 271);
title('Piston Pos. (100bar, 0.1 signal)')
xlabel('Tid')
% Pressure pB
plotPressureB(data1, data2, 'No PF', 'With PF', 71, 271);
title('Pressure B. (100bar, 0.1 signal)')
xlabel('Tid')

%% 100 bar, 35 signal
data3 = loadCSV('100bar_35signal_NoPF_26.03.26.csv');
data4 = loadCSV('100bar_35signal_PF_26.03.26.csv');
% Piston Position
plotPistonPosition(data3, data4, 'No PF', 'With PF', 1, 1);
title('Piston Pos. (100bar, 0.35 signal)')
xlabel('Tid')
% Pressure pB
plotPressureB(data3, data4, 'No PF', 'With PF', 1, 1);
title('Pressure B. (100bar, 0.35 signal)')
xlabel('Tid')

%% 100 bar, 50 signal
data5 = loadCSV('100bar_50signal_NoPF_26.03.26.csv');
data6 = loadCSV('100bar_50signal_PF_26.03.26.csv');
% Piston Position
plotPistonPosition(data5, data6, 'No PF', 'With PF', 108, 78);
title('Piston Pos. (100bar, 0.5 signal)')
xlabel('Tid')
% Pressure pB
plotPressureB(data5, data6, 'No PF', 'With PF', 108, 78);
title('Pressure B. (100bar, 0.5 signal)')
xlabel('Tid')

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

function plotPistonPosition(data1, data2, label1, label2, reset1, reset2)
    x1 = data1.fTimer(reset1:end);
    y1 = data1.fPistonPosition(reset1:end);
    x2 = data2.fTimer(reset2:end);
    y2 = data2.fPistonPosition(reset2:end);
    figure;
    plot(x1, y1)
    hold on
    plot(x2, y2)
    hold off
    grid on
    legend(label1, label2)
end

function plotPressureB(data1, data2, label1, label2, reset1, reset2)
    x1 = data1.fTimer(reset1:end);
    y1 = data1.fPb(reset1:end);
    x2 = data2.fTimer(reset2:end);
    y2 = data2.fPb(reset2:end);
    figure;
    plot(x1, y1)
    hold on
    plot(x2, y2)
    hold off
    grid on
    legend(label1, label2)
end