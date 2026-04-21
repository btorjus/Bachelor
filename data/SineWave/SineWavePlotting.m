clc; clear; close all;
% Ctrl R for comment
% Ctrl T for uncomment

%%
% Sine lower reversal point
%data1 = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_26.03.26.csv');
data2 = loadCSV('SineWave_NoPF_KVFF_100bar_0.05freq_26.03.26.csv');
data1 = loadCSV('SineWave_PaLower_PF_KVFF_100bar_0.05freq_20.04.26.csv');

%%
% PF vs no PF
hfig = plotPistonPosition(data1, data2, 'Active PF', 'No PF', 1, 1);
title('Cylinder Position (100 bar, 0.05 Hz)')
xlabel('Time [s]')
ylabel('Position [m]')
saveFigure(hfig, 'SineReversalPoint')
%%
% No PF and Active PF vs Xref - subplot
idx1 = data1.fTimer >= 6 & data1.fTimer <= 72;
idx2 = data2.fTimer >= 6 & data2.fTimer <= 72;

hfig3 = figure;
subplot(2,1,1)
plot(data2.fTimer(idx2), data2.fPistonPosition(idx2), '-', 'Color', '#000000', 'LineWidth', 1.5, 'DisplayName', 'No PF')
hold on
plot(data2.fTimer(idx2), data2.fXRef(idx2), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold off
grid off;
title('Cylinder Position (100 bar, 0.05 Hz)')
ylabel('Position [m]')
xlim([8, 85]);
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.0;

subplot(2,1,2)
plot(data1.fTimer(idx1), data1.fPistonPosition(idx1), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Active PF')
hold on
plot(data1.fTimer(idx1), data1.fXRef(idx1), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold off
grid off;
title('')
xlabel('Time [s]')
ylabel('Position [m]')
xlim([8, 85]);
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.0;
saveFigure(hfig3, 'PF_noPF_SineWave_Subplot')











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

% PF vs no PF
function hfig = plotPistonPosition(data1, data2, label1, label2, reset1, reset2)
    x1 = data1.fTimer(reset1:end);
    y1 = data1.fPistonPosition(reset1:end);
    x2 = data2.fTimer(reset2:end);
    y2 = data2.fPistonPosition(reset2:end);
    hfig = figure;
    % plot(x1, y1, 'k-', 'LineWidth', 3, 'DisplayName', label1)
    % hold on
    % plot(x2, y2, 'r--', 'LineWidth', 3, 'DisplayName', label2)
    % hold off
    plot(data1.fTimer, data1.fPistonPosition, '-', 'Color', '#000000', 'LineWidth', 3, 'DisplayName', 'Active PF')
    hold on
    plot(data2.fTimer, data2.fPistonPosition, '-', 'Color', '#F92672', 'LineWidth', 3, 'DisplayName', 'No PF')
    hold off
    grid off
    xlim([55,59])
    ylim([0.05,0.08])
    legend('Interpreter', 'latex')
end

% Position vs Xref
function hfig = plotPistonVsXRef(data, label, reset)
    t    = data.fTimer(reset:end);
    ypos = data.fPistonPosition(reset:end);
    yref = data.fXRef(reset:end);
    hfig = figure;
plot(t, ypos, '-', 'Color', '#000000', 'LineWidth', 3, 'DisplayName', 'Piston Position')
    hold on
    plot(t, yref, '--', 'Color', '#ff1245', 'LineWidth', 3, 'DisplayName', '$x_{ref}$')
    hold off
    grid on
    xlim([6.5, inf])
    legend('location','northeast','Interpreter', 'latex')
end


%%
% Plot function
function saveFigure(hfig, fname)
    picturewidth = 20;
    hw_ratio = 0.99; 
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', 17)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig, 'Position');
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', 'PaperSize', [pos(3), pos(4)])
    print(hfig, fname, '-dpdf', '-painters', '-fillpage')
    %print(hfig, fname, '-dpng', '-painters')
end
