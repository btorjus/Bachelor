clear; close all; clc;

%% Parameters
alpha = 5;
T1    = 0.03;
T2    = 2.24;
% filepath = 'C:\Users\sujro\Documents\GitHub\Bachelor\data\spool_mapping\UpDown110Bar060326\Down110Bar65Signal060326.csv';
filepath = 'C:\Users\sujro\Documents\GitHub\Bachelor\data\spool_mapping\UpDown100Bar040326\Down100Bar65Signal040326.csv';

VEL_SMOOTH_METHOD = 'sgolay';
VEL_SMOOTH_SPAN   = 50;

%% Column names
COL_time     = 'fTimer';
COL_fU       = 'fU';
COL_pA       = 'fPa';
COL_pB       = 'fPb';
COL_position = 'fPistonPosition';

%% Plot settings
C_red    = [0.9490, 0.0196, 0.0196];  % #F20505
C_blue   = [0.3725, 0.7608, 0.8510];  % #5FC2D9
C_lblue  = [0.0118, 0.6510, 0.5333];  % #03A688
C_yellow = [0.9490, 0.6235, 0.0196];  % #F29F05
C_orange = [0.9490, 0.4549, 0.0196];  % #F27405
C_black  = [0.1608, 0.1294, 0.1216];
picturewidth    = 20;
hw_ratio        = 0.65;
hw_ratio2       = 0.45;
EXPORT_fontsize = 17;

%% Load and window
T = loadAndClean(filepath, COL_fU);
tAll = T{:,COL_time};
T = T((tAll >= T1) & (tAll <= T2), :);

t   = T{:,COL_time};
pA  = T{:,COL_pA};
pB  = T{:,COL_pB};
pos = T{:,COL_position};

%% Quantities
pCrack = pA + alpha*pB;

vel = smoothdata(gradient(pos, t), VEL_SMOOTH_METHOD, VEL_SMOOTH_SPAN);

p_vel  = polyfit(t, pos, 1);
velAvg = p_vel(1);

pCrackMean   = mean(pCrack);
pCrackMedian = median(pCrack);

fprintf('p_A + %g*p_B : mean = %.2f bar, median = %.2f bar\n', alpha, pCrackMean, pCrackMedian);
fprintf('Average piston velocity (linear fit slope): %.3f mm/s\n', velAvg*1000);

%% Plot
hfig = figure('Name','CBV crack pressure estimate');
tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

nexttile
plot(t, pCrack, '-', 'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', '$p_A + \alpha \cdot p_B$'); hold on
yline(pCrackMean,   '--', 'Color', C_red,   'LineWidth', 1.5, 'DisplayName', sprintf('Mean = %.1f bar',   pCrackMean));
yline(pCrackMedian, ':',  'Color', C_black, 'LineWidth', 1.5, 'DisplayName', sprintf('Median = %.1f bar', pCrackMedian));
hold off;
ylabel('$p_A + \alpha \cdot p_B$ [bar]')
legend('Location','best')

nexttile
plot(t, vel*1000, '-', 'Color', C_lblue, 'LineWidth', 1.5, 'DisplayName', 'Piston velocity'); hold on
yline(velAvg*1000, '--', 'Color', C_red, 'LineWidth', 1.5, 'DisplayName', sprintf('Linear-fit avg = %.2f mm/s', velAvg*1000));
hold off;
xlabel('Timer $t$ [s]')
ylabel('Piston velocity [mm/s]')
legend('Location','best')

applyFigureExportTemplate(hfig, picturewidth, hw_ratio, EXPORT_fontsize);
print(hfig, 'cbv_crack_pressure', '-dpdf', '-vector', '-fillpage')

%% Three-run pressure-flow summary
files3 = { ...
    'C:\Users\sujro\Documents\GitHub\Bachelor\data\spool_mapping\UpDown100Bar040326\Down100Bar25Signal040326.csv', ...
    'C:\Users\sujro\Documents\GitHub\Bachelor\data\spool_mapping\UpDown100Bar040326\Down100Bar65Signal040326.csv', ...
    'C:\Users\sujro\Documents\GitHub\Bachelor\data\spool_mapping\UpDown100Bar040326\Down100Bar100Signal040326.csv'};

% Annular area (Down direction → flow on rod side)
d_bore = 65e-3;
d_rod  = 35e-3;
Aa     = pi*(d_bore^2 - d_rod^2)/4;

pCrackVec = zeros(1, numel(files3));
flowVec   = zeros(1, numel(files3));

for k = 1:numel(files3)
    Tk = loadAndClean(files3{k}, COL_fU);
    tAllk = Tk{:,COL_time};
    Tk = Tk((tAllk >= T1) & (tAllk <= T2), :);

    tk   = Tk{:,COL_time};
    pAk  = Tk{:,COL_pA};
    pBk  = Tk{:,COL_pB};
    posk = Tk{:,COL_position};

    pCrackVec(k) = median(pAk + alpha*pBk);
    p_velk       = polyfit(tk, posk, 1);
    flowVec(k)   = Aa * abs(p_velk(1)) * 60000;   % m³/s → L/min

    fprintf('Run %d: pCrack = %.2f bar, flow = %.3f L/min\n', k, pCrackVec(k), flowVec(k));
end

% Linear fit
pfit = polyfit(flowVec, pCrackVec, 1);
xfit = linspace(min(flowVec), max(flowVec), 50);
yfit = polyval(pfit, xfit);

hfig2 = figure('Name','CBV pressure-flow');
plot(flowVec, pCrackVec, 'o', 'Color', C_red, 'MarkerFaceColor', C_red, ...
    'MarkerSize', 8, 'DisplayName', 'Median $p_A + \alpha \cdot p_B$'); hold on
plot(xfit, yfit, '-', 'Color', C_black, 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Linear fit: $%.2f\\,Q + %.1f$', pfit(1), pfit(2)));
hold off
xlabel('Flow $Q$ [L/min]')
ylabel('$p_A + \alpha \cdot p_B$ [bar]')
legend('Location','best')

applyFigureExportTemplate(hfig2, picturewidth, hw_ratio2, EXPORT_fontsize);
print(hfig2, 'cbv_pressure_flow', '-dpdf', '-vector', '-fillpage')

%% Local functions
function T = loadAndClean(filepath, COL_fU)
    opts = detectImportOptions(filepath, ...
        'Delimiter', ';', 'NumHeaderLines', 6, ...
        'DecimalSeparator', ',', 'VariableNamingRule', 'preserve');
    T = readtable(filepath, opts);
    T = rmmissing(T, 'MinNumMissing', width(T));

    timeVec  = T{:,1};
    resetIdx = find(diff(timeVec) < 0);
    if ~isempty(resetIdx)
        T = T(resetIdx(end)+1:end, :);
    end

    if ~ismember(COL_fU, T.Properties.VariableNames)
        error('Column "%s" not found. Available: %s', COL_fU, strjoin(T.Properties.VariableNames, ', '));
    end
    T = T(T{:,COL_fU} ~= 0, :);
end

function applyFigureExportTemplate(hfig, picturewidth, hw_ratio, fontsize)
    set(findall(hfig,'-property','FontSize'),'FontSize',fontsize)
    set(findall(hfig,'-property','Box'),'Box','off')
    set(findall(hfig,'-property','Interpreter'),'Interpreter','latex')
    set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig,'Position');
    set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
end