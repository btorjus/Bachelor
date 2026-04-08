clc; clear; close all;
% Ctrl R for comment
% Ctrl T for uncomment

%% Loading csv
dataKVFF    = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_26.03.26.csv');
dataNoFF    = loadCSV('SineWave_NoFF_PF_KVFF_100bar_0.05freq_31.03.26.csv');
dataNoPosFB = loadCSV('SineWave_NoPositionFeedback_PF_KVFF_100bar_0.05freq_31.03.26.csv');
dataOtherFF = loadCSV('SineWave_OtherFF_PF_100bar_0.05freq_31.03.26.csv');
dataOtherFF2 = loadCSV('SineWave_Other_FF_100bar_0.05freq_fUFF_08.04.26.csv');


%% Plots

% % No FF (Xdotref, Xdotactual, PistonPo.)
% % Beregn faktisk hastighet (numerisk derivasjon)
% dt = mean(diff(dataNoFF.fTimer));
% vActual = gradient(dataNoFF.fPistonPosition, dt);
% 
% % Glatt hastigheten
% windowSize = 1000;
% vSmooth = movmean(vActual, windowSize);
% 
% idx = dataNoFF.fTimer >= 0.0 & dataNoFF.fTimer <= 92.65;
% 
% dt = mean(diff(dataNoFF.fTimer(idx)));
% vActual = gradient(dataNoFF.fPistonPosition(idx), dt);
% windowSize = 1000;
% vSmooth = movmean(vActual, windowSize);
% 
% hfig1 = figure;
% subplot(2,1,1)
% plot(dataNoFF.fTimer(idx), dataNoFF.fPistonPosition(idx), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
% grid off;
% ylim([0.05, 0.35]);
% xlim([28.6,110])
% title('No FF (100 bar, 0.05 Hz)')
% ylabel('Position [m]')
% lg = legend('Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) - 0.0;
% lg.Position(2) = lg.Position(2) + 0.02;
% 
% subplot(2,1,2)
% plot(dataNoFF.fTimer(idx), dataNoFF.fXDotRef(idx), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
% hold on
% plot(dataNoFF.fTimer(idx), vSmooth, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
% hold off
% grid off
% ylim([-0.06, 0.06])
% xlim([28.6,110])
% xlabel('Time [s]')
% ylabel('Velocity [m/s]')
% lg = legend('Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) - 0.015;
% lg.Position(2) = lg.Position(2) - 0.019;
% saveFigure(hfig1, 'Subplot_NoFF')
 

%%
% KVFF (Xdotref, Xdotactual, PistonPos.)
dt = mean(diff(dataKVFF.fTimer));
vActualKVFF = gradient(dataKVFF.fPistonPosition, dt);
windowSize = 1000;
vSmoothKVFF = movmean(vActualKVFF, windowSize);
hfig2 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer, dataKVFF.fPistonPosition, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
grid off;
xlim([7, 89]);
%ylim([0.05, 0.35]);
title('Active FF (100 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.0;
lg.Position(2) = lg.Position(2) + 0.01;

subplot(2,1,2)
plot(dataKVFF.fTimer, dataKVFF.fXDotRef, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
hold on
plot(dataKVFF.fTimer, vSmoothKVFF, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
hold off
grid off
xlim([7, 89])
%ylim([-0.06, 0.06])
xlabel('Time [s]')
ylabel('Velocity [m/s]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.015;
lg.Position(2) = lg.Position(2) - 0.019;

saveFigure(hfig2, 'Subplot_KVFF')
%%
%% Plot fU and fU_FF vs Time
dt = mean(diff(dataOtherFF2.fTimer));
vActualOtherFF2 = gradient(dataOtherFF2.fPistonPosition, dt);
windowSize = 1000;
vSmoothOtherFF2 = movmean(vActualOtherFF2, windowSize);

hfig4 = figure;
subplot(2,1,1)
plot(dataOtherFF2.fTimer, dataOtherFF2.fPistonPosition, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
grid off;
xlim([7, 89]);
title('Other FF (100 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.0;
lg.Position(2) = lg.Position(2) + 0.01;

subplot(2,1,2)
plot(dataOtherFF2.fTimer, dataOtherFF2.fU, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$f_U$')
hold on
plot(dataOtherFF2.fTimer, dataOtherFF2.fU_FF, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$f_{U,FF}$')
hold off
grid off
xlim([7, 89])
xlabel('Time [s]')
ylabel('Force [N]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.015;
lg.Position(2) = lg.Position(2) - 0.019;

saveFigure(hfig4, 'Subplot_OtherFF2_fU')



%%
% % Plot Cylinder Pos with and without Pos.FB
% 
% % NoPosFB vs KVFF - PistonPosition and XRef subplot
% idxNoPosFB = dataNoPosFB.fTimer >= 0 & dataNoPosFB.fTimer <= 187;
% idxKVFF    = dataKVFF.fTimer    >= 0 & dataKVFF.fTimer    <= 85;
% 
% hfig3 = figure;
% subplot(2,1,1)
% plot(dataNoPosFB.fTimer(idxNoPosFB), dataNoPosFB.fPistonPosition(idxNoPosFB), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
% hold on
% plot(dataNoPosFB.fTimer(idxNoPosFB), dataNoPosFB.fXRef(idxNoPosFB), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
% hold off
% grid off;
% title('No Position Feedback (100 bar, 0.05 Hz)')
% ylabel('Position [m]')
% xlim([27,197])
% lg = legend('location', 'northwest', 'Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) + 0.05;
% lg.Position(2) = lg.Position(2) - 0.05;
% 
% subplot(2,1,2)
% plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fPistonPosition(idxKVFF), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
% hold on
% plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fXRef(idxKVFF), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
% hold off
% grid off;
% title('Active Position Feedback (100 bar, 0.05 Hz)')
% xlabel('Time [s]')
% ylabel('Position [m]')
% xlim([8,85])
% ylim([0.04,0.5])
% lg = legend('location', 'northwest', 'Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) + 0.05;
% lg.Position(2) = lg.Position(2) - 0.03;
% 
% saveFigure(hfig3, 'Subplot_NoPosFB_PosFB')











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