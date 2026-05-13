%% Setup
clear; close all; clc;

%% Colors
C_red    = [0.9490, 0.0196, 0.0196];
C_blue   = [0.3725, 0.7608, 0.8510];
C_lblue  = [0.0118, 0.6510, 0.5333];
C_yellow = [0.9490, 0.6235, 0.0196];
C_orange = [0.9490, 0.4549, 0.0196];
C_black  = [0.1608, 0.1294, 0.1216];

%% Test 1: ps 100 -> 150 bar at 25 s, Kp = 14
ds = loadDS('../SineWaveRobust_ps100barto150bar_at25s_Kp14.mat');
[t, xref]    = getSig(ds, 8);
[~, x]       = getSig(ds, 21);
[~, xdotref] = getSig(ds, 7);
[~, xdot]    = getSig(ds, 22);
[~, u]       = getSig(ds, 15);   % combined u
[~, uFF]     = getSig(ds, 1);
[~, uPID]    = getSig(ds, 10);
[~, uPFB]    = getSig(ds, 12);

hfig = figure;
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(t, xref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{\mathrm{ref}}$'); hold on
plot(t, x,    '-',  'Color', C_red,   'LineWidth', 1.5, 'DisplayName', '$x$');
ylabel('$x$ [m]')
xlim([23 27])
legend('Location','best')

nexttile
plot(t, xdotref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{\mathrm{ref}}$'); hold on
plot(t, xdot,    '-',  'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}$');
ylabel('$\dot{x}$ [m/s]')
xlim([23 27])
legend('Location','best')

nexttile
plot(t, uFF,  '-', 'Color', C_orange,   'LineWidth', 1.5, 'DisplayName', '$u_{FF}$');  hold on
%plot(t, uPID, '-', 'Color', C_yellow, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$');
%plot(t, uPFB, '-', 'Color', C_orange, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$');
plot(t, u,    '-', 'Color', C_black,    'LineWidth', 1.5, 'DisplayName', '$u$');
xlabel('time $t$ [s]')
ylabel('$u$ [-]')
xlim([23 27])
sgtitle('Supply pressure step $p_s$: $100 \rightarrow 150$ bar at $t = 25$ s, $K_p = 14$, $f = 0.05$ Hz', 'Interpreter','latex')
legend('Location','best')

exportFig(hfig, 'robustness_ps100to150_Kp14', 20, 0.65)

%% Test 2: ps 100 -> 150 bar at 35 s, Kp = 14 retraction
ds = loadDS('../SineWaveRobust_ps100barto150bar_at35s_Kp14_ret.mat');
[t, xref]    = getSig(ds, 8);
[~, x]       = getSig(ds, 21);
[~, xdotref] = getSig(ds, 7);
[~, xdot]    = getSig(ds, 22);
[~, u]       = getSig(ds, 15);
[~, uFF]     = getSig(ds, 1);
[~, uPID]    = getSig(ds, 10);
[~, uPFB]    = getSig(ds, 12);

hfig = figure;
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(t, xref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{\mathrm{ref}}$'); hold on
plot(t, x,    '-',  'Color', C_red,   'LineWidth', 1.5, 'DisplayName', '$x$');
ylabel('$x$ [m]')
xlim([33 37])
legend('Location','best')

nexttile
plot(t, xdotref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{\mathrm{ref}}$'); hold on
plot(t, xdot,    '-',  'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}$');
ylabel('$\dot{x}$ [m/s]')
xlim([33 37])
legend('Location','best')

nexttile
plot(t, uFF,  '-', 'Color', C_orange,   'LineWidth', 1.5, 'DisplayName', '$u_{FF}$');  hold on
%plot(t, uPID, '-', 'Color', C_yellow, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$');
%plot(t, uPFB, '-', 'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$');
plot(t, u,    '-', 'Color', C_black,    'LineWidth', 1.5, 'DisplayName', '$u$');
xlabel('time $t$ [s]')
ylabel('$u$ [-]')
xlim([33 37])
sgtitle('Supply pressure step $p_s$: $100 \rightarrow 150$ bar at $t = 35$ s, $K_p = 14$, $f = 0.05$ Hz', 'Interpreter','latex')
legend('Location','best')

exportFig(hfig, 'robustness_ps100to150_Kp14_ret', 20, 0.65)

%% Test 3: Payload 316 -> 416 kg at 35 s, Kp = 14 retraction
ds = loadDS('../SineWaveRobust_payload_100kg_35s_Kp14_ret.mat');
[t, xref]    = getSig(ds, 8);
[~, x]       = getSig(ds, 21);
[~, xdotref] = getSig(ds, 7);
[~, xdot]    = getSig(ds, 22);
[~, u]       = getSig(ds, 15);
[~, uFF]     = getSig(ds, 1);
[~, uPID]    = getSig(ds, 10);
[~, uPFB]    = getSig(ds, 12);

hfig = figure;
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(t, xref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{\mathrm{ref}}$'); hold on
plot(t, x,    '-',  'Color', C_red,   'LineWidth', 1.5, 'DisplayName', '$x$');
ylabel('$x$ [m]')
xlim([33 37])
sgtitle('Payload step: $+100$ kg at $t = 35$ s ($p_S = 100$ bar, $K_p = 14$, $f = 0.05$ Hz)', 'Interpreter','latex')
legend('Location','best')

nexttile
plot(t, xdotref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{\mathrm{ref}}$'); hold on
plot(t, xdot,    '-',  'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}$');
ylabel('$\dot{x}$ [m/s]')
xlim([33 37])
legend('Location','best')

nexttile
plot(t, uFF,  '-', 'Color', C_orange,   'LineWidth', 1.5, 'DisplayName', '$u_{FF}$');  hold on
%plot(t, uPID, '-', 'Color', C_yellow, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$');
plot(t, uPFB, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$');
plot(t, u,    '-', 'Color', C_black,    'LineWidth', 1.5, 'DisplayName', '$u$');
xlabel('time $t$ [s]')
ylabel('$u$ [-]')
xlim([33 37])
ylim([-0.7, 0.7])
legend('Location','northeast','NumColumns',3)

exportFig(hfig, 'robustness_payload_100kg_35s_Kp14_ret', 20, 0.65)

%% Test 4: Payload 316 -> 416 kg at 25 s, Kp = 14 extention 150 bar
ds = loadDS('../SineWaveRobust_payload_100kg_25s_Kp14_150bar_ex.mat');
[t, xref]    = getSig(ds, 8);
[~, x]       = getSig(ds, 21);
[~, xdotref] = getSig(ds, 7);
[~, xdot]    = getSig(ds, 22);
[~, u]       = getSig(ds, 15);
[~, uFF]     = getSig(ds, 1);
[~, uPID]    = getSig(ds, 10);
[~, uPFB]    = getSig(ds, 12);

hfig = figure;
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(t, xref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{\mathrm{ref}}$'); hold on
plot(t, x,    '-',  'Color', C_red,   'LineWidth', 1.5, 'DisplayName', '$x$');
ylabel('$x$ [m]')
xlim([24 27])
sgtitle('Payload step: $+100$ kg at $t = 25$ s ($p_S = 150$ bar, $K_p = 14$, $f = 0.05$ Hz)', 'Interpreter','latex')
legend('Location','best')

nexttile
plot(t, xdotref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{\mathrm{ref}}$'); hold on
plot(t, xdot,    '-',  'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}$');
ylabel('$\dot{x}$ [m/s]')
xlim([23 27])
legend('Location','best')

nexttile
plot(t, uFF,  '-', 'Color', C_orange,   'LineWidth', 1.5, 'DisplayName', '$u_{FF}$');  hold on
%plot(t, uPID, '-', 'Color', C_yellow, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$');
plot(t, uPFB, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$');
plot(t, u,    '-', 'Color', C_black,    'LineWidth', 1.5, 'DisplayName', '$u$');
xlabel('time $t$ [s]')
ylabel('$u$ [-]')
xlim([23 27])
ylim([-0.5, 0.8])
legend('Location','southeast','NumColumns',3)
exportFig(hfig, 'robustness_payload_100kg_25s_Kp14_150bar_ext', 20, 0.65)

%% Test 5: Payload 316 -> 516 kg at 30 s, Kp = 14 extention 150 bar
ds = loadDS('../SineWaveRobust_payload_200kg_30s_Kp14_150bar_ret.mat');
[t, xref]    = getSig(ds, 8);
[~, x]       = getSig(ds, 21);
[~, xdotref] = getSig(ds, 7);
[~, xdot]    = getSig(ds, 22);
[~, u]       = getSig(ds, 15);
[~, uFF]     = getSig(ds, 1);
[~, uPID]    = getSig(ds, 10);
[~, uPFB]    = getSig(ds, 12);

hfig = figure;
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(t, xref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{\mathrm{ref}}$'); hold on
plot(t, x,    '-',  'Color', C_red,   'LineWidth', 1.5, 'DisplayName', '$x$');
ylabel('$x$ [m]')
xlim([29 33])
sgtitle('Payload step: $+200$ kg at $t = 30$ s ($p_S = 150$ bar, $K_p = 14$, $f = 0.05$ Hz)', 'Interpreter','latex')
legend('Location','best')

nexttile
plot(t, xdotref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{\mathrm{ref}}$'); hold on
plot(t, xdot,    '-',  'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}$');
ylabel('$\dot{x}$ [m/s]')
xlim([29 33])
legend('Location','best')

nexttile
plot(t, uFF,  '-', 'Color', C_orange,   'LineWidth', 1.5, 'DisplayName', '$u_{FF}$');  hold on
plot(t, uPID, '-', 'Color', C_yellow, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$');
plot(t, uPFB, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$');
plot(t, u,    '-', 'Color', C_black,    'LineWidth', 1.5, 'DisplayName', '$u$');
xlabel('time $t$ [s]')
ylabel('$u$ [-]')
xlim([29 33])
ylim([-0.5, 0.7])
legend('Location','northeast','NumColumns',3)
exportFig(hfig, 'robustness_payload_200kg_30s_Kp14_150bar_ret', 20, 0.65)

%% Test 6: Payload 316 -> 516 kg at 30 s, Kp = 14 extention 250 bar
ds = loadDS('../SineWaveRobust_payload_200kg_30s_Kp14_250bar_ret.mat');
[t, xref]    = getSig(ds, 8);
[~, x]       = getSig(ds, 21);
[~, xdotref] = getSig(ds, 7);
[~, xdot]    = getSig(ds, 22);
[~, u]       = getSig(ds, 15);
[~, uFF]     = getSig(ds, 1);
[~, uPID]    = getSig(ds, 10);
[~, uPFB]    = getSig(ds, 12);

hfig = figure;
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(t, xref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{\mathrm{ref}}$'); hold on
plot(t, x,    '-',  'Color', C_red,   'LineWidth', 1.5, 'DisplayName', '$x$');
ylabel('$x$ [m]')
xlim([29 33])
sgtitle('Payload step: $+200$ kg at $t = 30$ s ($p_S = 250$ bar, $K_p = 14$, $f = 0.05$ Hz)', 'Interpreter','latex')
legend('Location','best')

nexttile
plot(t, xdotref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{\mathrm{ref}}$'); hold on
plot(t, xdot,    '-',  'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}$');
ylabel('$\dot{x}$ [m/s]')
xlim([29 33])
legend('Location','best')

nexttile
plot(t, uFF,  '-', 'Color', C_orange,   'LineWidth', 1.5, 'DisplayName', '$u_{FF}$');  hold on
plot(t, uPID, '-', 'Color', C_yellow, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$');
plot(t, uPFB, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$');
plot(t, u,    '-', 'Color', C_black,    'LineWidth', 1.5, 'DisplayName', '$u$');
xlabel('time $t$ [s]')
ylabel('$u$ [-]')
xlim([29 33])
ylim([-0.5, 0.7])
legend('Location','northeast','NumColumns',3)
exportFig(hfig, 'robustness_payload_200kg_30s_Kp14_250bar_ret', 20, 0.65)

%% Test 7: Ps 200 -> 100 bar at 17.5 s, Kp = 8 freq 0.1 ret 
ds = loadDS('../SineWaveRobust_ps200barto100bar_at17.5s_Kp8_ret');
[t, xref]    = getSig(ds, 8);
[~, x]       = getSig(ds, 21);
[~, xdotref] = getSig(ds, 7);
[~, xdot]    = getSig(ds, 22);
[~, u]       = getSig(ds, 15);
[~, uFF]     = getSig(ds, 1);
[~, uPID]    = getSig(ds, 10);
[~, uPFB]    = getSig(ds, 12);

hfig = figure;
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(t, xref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{\mathrm{ref}}$'); hold on
plot(t, x,    '-',  'Color', C_red,   'LineWidth', 1.5, 'DisplayName', '$x$');
ylabel('$x$ [m]')
xlim([17 19])
sgtitle('Supply pressure drop $p_s$: $200 \rightarrow 100$ bar at $t = 17.5$ s, $K_p = 14$, $f = 0.1$ Hz', 'Interpreter','latex')
legend('Location','best')

nexttile
plot(t, xdotref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{\mathrm{ref}}$'); hold on
plot(t, xdot,    '-',  'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}$');
ylabel('$\dot{x}$ [m/s]')
xlim([17 19])
legend('Location','best')

nexttile
plot(t, uFF,  '-', 'Color', C_orange,   'LineWidth', 1.5, 'DisplayName', '$u_{FF}$');  hold on
%plot(t, uPID, '-', 'Color', C_yellow, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$');
%plot(t, uPFB, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$');
plot(t, u,    '-', 'Color', C_black,    'LineWidth', 1.5, 'DisplayName', '$u$');
xlabel('time $t$ [s]')
ylabel('$u$ [-]')
xlim([17 19])
%ylim([-1 -0.3])

legend('Location','east','NumColumns',3)
exportFig(hfig, 'Robustness_ps200barto100bar_at175s_Kp8_01freq_ret', 20, 0.65)

%% Test 8: Ps 250 bar increasing freq 0.05 plus 0.01*t, Kp = 8
ds = loadDS('../SineWaveRobust_ps250bar_freqIncrease0.05plus0.01t_Kp8_ret');
[t, xref]    = getSig(ds, 8);
[~, x]       = getSig(ds, 21);
[~, xdotref] = getSig(ds, 7);
[~, xdot]    = getSig(ds, 22);
[~, u]       = getSig(ds, 15);
[~, uFF]     = getSig(ds, 1);
[~, uPID]    = getSig(ds, 10);
[~, uPFB]    = getSig(ds, 12);

hfig = figure;
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(t, xref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$x_{\mathrm{ref}}$'); hold on
plot(t, x,    '-',  'Color', C_red,   'LineWidth', 1.5, 'DisplayName', '$x$');
ylabel('$x$ [m]')
xlim([5 28])
sgtitle('Increasing refrence frequency $f = (0.05 + 0.01 \cdot t)$ [Hz], $K_p = 14$, $p_s = 250$ bar', 'Interpreter','latex')
legend('Location','best')

nexttile
plot(t, xdotref, '--', 'Color', C_black, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}_{\mathrm{ref}}$'); hold on
plot(t, xdot,    '-',  'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$\dot{x}$');
ylabel('$\dot{x}$ [m/s]')
xlim([5 28])
legend('Location','best')

nexttile
plot(t, uFF,  '-', 'Color', C_orange,   'LineWidth', 1.5, 'DisplayName', '$u_{FF}$');  hold on
plot(t, uPID, '-', 'Color', C_yellow, 'LineWidth', 1.5, 'DisplayName', '$u_{PID}$');
plot(t, uPFB, '-', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', '$u_{PFB}$');
plot(t, u,    '-', 'Color', C_black,    'LineWidth', 1.5, 'DisplayName', '$u$');
xlabel('time $t$ [s]')
ylabel('$u$ [-]')
xlim([5 28])
ylim([-1.5, 1.5])

legend('Location','southwest','NumColumns',4)
exportFig(hfig, 'Robustness_ps250bar_increase_freq_005plus001t_Kp8', 20, 0.65)

%% --- local functions ---
function ds = loadDS(file)
    S  = load(file);
    ds = S.(char(fieldnames(S)));
end

function [t, y] = getSig(ds, i)
    v = ds{i}.Values;
    t = v.Time;
    y = v.Data;
end

function exportFig(hfig, fname, picturewidth, hw_ratio)
    set(findall(hfig,'-property','FontSize'),'FontSize',11)
    set(findall(hfig,'-property','Box'),'Box','off')
    set(findall(hfig,'-property','Interpreter'),'Interpreter','latex')
    set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig,'Position');
    set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
    print(hfig,fname,'-dpdf','-vector','-fillpage')
end