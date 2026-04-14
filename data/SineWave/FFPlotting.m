clc; clear; close all;
% Ctrl R for comment
% Ctrl T for uncomment

%% Loading csv
dataKVFF    = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_26.03.26.csv');
dataNoFF    = loadCSV('SineWave_NoFF_PF_KVFF_100bar_0.05freq_31.03.26.csv');
dataNoPosFB = loadCSV('SineWave_NoPositionFeedback_PF_KVFF_100bar_0.05freq_31.03.26.csv');
dataOtherFF = loadCSV('SineWave_OtherFF_PF_100bar_0.05freq_31.03.26.csv');
dataOtherFF2 = loadCSV('SineWave_Other_FF_100bar_0.05freq_fUFF_08.04.26.csv');
data8Grade = loadCSV('SineWave_8gradePoly_PF_KVFF_100bar_0.05freq_10.04.26.csv');
data019 = loadCSV('SineWave_PF_KVFF_100bar_0.05freq_10.04.26.csv');
%%




% %% No FF (Xdotref, Xdotactual, PistonPo.)
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
% plot(dataNoFF.fTimer(idx), dataNoFF.fXRef(idx), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
% hold on
% plot(dataNoFF.fTimer(idx), dataNoFF.fPistonPosition(idx), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
% hold off
% grid off;
% ylim([0.04, 0.35]);
% xlim([28.6,110])
% title('No FF (100 bar, 0.05 Hz)')
% ylabel('Position [m]')
% lg = legend('Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) + 0.07;
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
% lg.Position(1) = lg.Position(1) - 0.017;
% lg.Position(2) = lg.Position(2) - 0.019;
% saveFigure(hfig1, 'Subplot_NoFF')


%%
% KVFF (Xdotref, Xdotactual, PistonPos.)
dt = mean(diff(dataKVFF.fTimer));
vActualKVFF = gradient(dataKVFF.fPistonPosition, dt);
vSmoothKVFF = movmean(vActualKVFF, 1000);

hfig2 = figure;
subplot(2,1,1)
plot(dataKVFF.fTimer, dataKVFF.fPistonPosition, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
hold on
plot(dataKVFF.fTimer, dataKVFF.fXRef, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold off
grid off;
xlim([7, 89]);
%ylim([0.05, 0.35]);
title('Active FF (100 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.07;
lg.Position(2) = lg.Position(2) + 0.02;

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
lg.Position(1) = lg.Position(1) - 0.017;
lg.Position(2) = lg.Position(2) - 0.019;

saveFigure(hfig2, 'Subplot_KVFF')

% Kv FF contribution
fU_Smooth = movmean(dataKVFF.fU, 1000);
hfig4 = figure;
plot(dataKVFF.fTimer, fU_Smooth, '-', 'Color', '#000000', 'LineWidth', 2, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer, dataKVFF.fU_FF, '-', 'Color', '#1E90FF', 'LineWidth', 2, 'DisplayName', '$u_{FF}$')
%plot(dataKVFF.fTimer, dataKVFF.fUpfb, '-', 'Color', '#000000', 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
%plot(dataKVFF.fTimer, dataKVFF.fPID, '-', 'Color', '#2ECC71', 'LineWidth', 1.5, 'DisplayName', '$u_{PF}$')
hold off
grid off
xlim([8, 89])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve Signals, Active FF (100 bar, 0.05 Hz)')
lg = legend('Interpreter', 'latex');
%lg.Position(1) = lg.Position(1) - 0.020;
%lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig4, 'KvFF_Contribution')


%% 8 Grade - Ikke i bruk
% KVFF (Xdotref, Xdotactual, PistonPos.)
dt = mean(diff(data8Grade.fTimer));
vActualKVFF = gradient(data8Grade.fPistonPosition, dt);
vSmoothKVFF = movmean(vActualKVFF, 1000);
hfig2 = figure;
subplot(2,1,1)
plot(data8Grade.fTimer, data8Grade.fPistonPosition, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
hold on
plot(data8Grade.fTimer, data8Grade.fXRef, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold off
grid off;
xlim([7, 89]);
%ylim([0.05, 0.35]);
title('Active FF (100 bar, 0.05 Hz)')
ylabel('Position [m]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.07;
lg.Position(2) = lg.Position(2) + 0.02;
subplot(2,1,2)
plot(data8Grade.fTimer, data8Grade.fXDotRef, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
hold on
plot(data8Grade.fTimer, vSmoothKVFF, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
hold off
grid off
xlim([7, 89])
%ylim([-0.06, 0.06])
xlabel('Time [s]')
ylabel('Velocity [m/s]')
lg = legend('Interpreter', 'latex');
lg.Position(1) = lg.Position(1) - 0.017;
lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig2, 'Subplot_KVFF')
% Kv FF contribution
fU_Smooth = movmean(data8Grade.fU, 1);
hfig4 = figure;
plot(data8Grade.fTimer, fU_Smooth, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(data8Grade.fTimer, data8Grade.fU_FF, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$u_{FF}$')
plot(data8Grade.fTimer, data8Grade.fUpfb, '-', 'Color', '#000000', 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$')
plot(data8Grade.fTimer, data8Grade.fPID, '-', 'Color', '#2ECC71', 'LineWidth', 1.5, 'DisplayName', '$u_{PF}$')
hold off
grid on
xlim([8, 89])
xlabel('Time [s]')
ylabel('Signal [-]')
title('Valve Signals, Active FF (100 bar, 0.05 Hz)')
lg = legend('Interpreter', 'latex');
%lg.Position(1) = lg.Position(1) - 0.020;
%lg.Position(2) = lg.Position(2) - 0.019;
saveFigure(hfig4, 'KvFF_Contribution')




%%
% Other FF
% %% Other FF (Xdotref, Xdotactual, PistonPos.)
% dt = mean(diff(dataOtherFF2.fTimer));
% vActualOtherFF2 = gradient(dataOtherFF2.fPistonPosition, dt);
% vSmoothOtherFF2 = movmean(vActualOtherFF2, 1000);
% 
% hfig5 = figure;
% subplot(2,1,1)
% plot(dataOtherFF2.fTimer, dataOtherFF2.fPistonPosition, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
% hold on
% plot(dataOtherFF2.fTimer, dataOtherFF2.fXRef, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
% hold off
% grid off;
% xlim([7, 89]);
% title('Other FF (100 bar, 0.05 Hz)')
% ylabel('Position [m]')
% lg = legend('Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) + 0.07;
% lg.Position(2) = lg.Position(2) + 0.02;
% 
% subplot(2,1,2)
% plot(dataOtherFF2.fTimer, dataOtherFF2.fXDotRef, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
% hold on
% plot(dataOtherFF2.fTimer, vSmoothOtherFF2, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
% hold off
% grid off
% xlim([7, 89])
% xlabel('Time [s]')
% ylabel('Velocity [m/s]')
% lg = legend('Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) - 0.017;
% lg.Position(2) = lg.Position(2) - 0.019;
% 
% saveFigure(hfig5, 'Subplot_OtherFF2')





% %% Other FF (Xdotref, Xdotactual, PistonPos.)
% dt = mean(diff(dataOtherFF.fTimer));
% vActualOtherFF = gradient(dataOtherFF.fPistonPosition, dt);
% vSmoothOtherFF = movmean(vActualOtherFF, 1000);
% 
% hfig6 = figure;
% subplot(2,1,1)
% plot(dataOtherFF.fTimer, dataOtherFF.fPistonPosition, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
% hold on
% plot(dataOtherFF.fTimer, dataOtherFF.fXRef, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
% hold off
% grid off;
% xlim([7, 89]);
% title('Other FF (100 bar, 0.05 Hz)')
% ylabel('Position [m]')
% lg = legend('Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) + 0.07;
% lg.Position(2) = lg.Position(2) + 0.02;
% 
% subplot(2,1,2)
% plot(dataOtherFF.fTimer, dataOtherFF.fXDotRef, '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{ref}$')
% hold on
% plot(dataOtherFF.fTimer, vSmoothOtherFF, '-', 'Color', '#1E90FF', 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{actual}$')
% hold off
% grid off
% xlim([7, 89])
% xlabel('Time [s]')
% ylabel('Velocity [m/s]')
% lg = legend('Interpreter', 'latex');
% lg.Position(1) = lg.Position(1) - 0.017;
% lg.Position(2) = lg.Position(2) - 0.019;
% 
% saveFigure(hfig6, 'Subplot_OtherFF')



%%
% Plot Cylinder Pos with and without Pos.FB

% NoPosFB vs KVFF - PistonPosition and XRef subplot
idxNoPosFB = dataNoPosFB.fTimer >= 0 & dataNoPosFB.fTimer <= 187;
idxKVFF    = dataKVFF.fTimer    >= 0 & dataKVFF.fTimer    <= 85;

hfig3 = figure;
subplot(2,1,1)
plot(dataNoPosFB.fTimer(idxNoPosFB), dataNoPosFB.fPistonPosition(idxNoPosFB), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
hold on
plot(dataNoPosFB.fTimer(idxNoPosFB), dataNoPosFB.fXRef(idxNoPosFB), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold off
grid off;
title('No Position Feedback (100 bar, 0.05 Hz)')
ylabel('Position [m]')
xlim([27,197])
lg = legend('location', 'northwest', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
lg.Position(2) = lg.Position(2) - 0.05;

subplot(2,1,2)
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fPistonPosition(idxKVFF), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
hold on
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fXRef(idxKVFF), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold off
grid off;
title('Active Position Feedback (100 bar, 0.05 Hz)')
xlabel('Time [s]')
ylabel('Position [m]')
xlim([8,85])
ylim([0.04,0.5])
lg = legend('location', 'northwest', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.05;
lg.Position(2) = lg.Position(2) - 0.03;

saveFigure(hfig3, 'Subplot_NoPosFB_PosFB')

%% PID Signal

% NoPosFB vs KVFF - PistonPosition and XRef subplot (reordered)
idxNoPosFB = dataNoPosFB.fTimer >= 0 & dataNoPosFB.fTimer <= 187;
idxKVFF    = dataKVFF.fTimer    >= 0 & dataKVFF.fTimer    <= 85;
hfig7 = figure;

% --- Øverste subplot: tidligere nederste (KVFF PistonPosition + XRef) ---
subplot(2,1,1)
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fPistonPosition(idxKVFF), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Cylinder Position')
hold on
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fXRef(idxKVFF), '-', 'Color', '#F92672', 'LineWidth', 1.5, 'DisplayName', '$x_{ref}$')
hold off
grid off;
title('Active Position Feedback (100 bar, 0.05 Hz)')
ylabel('Position [m]')
xlim([8,85])
ylim([0.04,0.5])
lg = legend('location', 'northeast', 'Interpreter', 'latex');
lg.Position(1) = lg.Position(1) + 0.07;
lg.Position(2) = lg.Position(2) - 0.03;

% --- Nederste subplot: fU og fPID mot tid ---
subplot(2,1,2)
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fU(idxKVFF), 'k-', 'LineWidth', 1.5, 'DisplayName', '$u$')
hold on
plot(dataKVFF.fTimer(idxKVFF), dataKVFF.fPID(idxKVFF), '-', 'Color', '#00C853', 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$')
hold off
grid off;
xlabel('Time [s]')
ylabel('Control Signal [-]')
xlim([8,85])
lg = legend('location', 'northeast', 'Interpreter', 'latex');
%lg.Position(1) = lg.Position(1) + 0.05;
lg.Position(2) = lg.Position(2) - 0.03;

saveFigure(hfig7, 'PID_Signal')










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
    hw_ratio = 0.55;
    set(findall(hfig, '-property', 'FontSize'),             'FontSize', 15)
    set(findall(hfig, '-property', 'Box'),                  'Box', 'off')
    set(findall(hfig, '-property', 'Interpreter'),          'Interpreter', 'latex')
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex')
    set(hfig, 'Units', 'centimeters', 'Position', [3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig, 'Position');
    set(hfig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', 'PaperSize', [pos(3), pos(4)])
    print(hfig, fname, '-dpdf', '-painters', '-fillpage')
end