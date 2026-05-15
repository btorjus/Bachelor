clear; clc; close all

% C_red = '#f21a00';
% C_blue = '#3b9ab2';
% C_lblue = '#78b7c5';
% C_yellow = '#ebcc2a';
% C_orange = '#e1af00';
C_red    = [0.9490, 0.0196, 0.0196];  % #F20505
C_blue   = [0.3725, 0.7608, 0.8510];  % #5FC2D9
C_lblue  = [0.0118, 0.6510, 0.5333];  % #03A688
C_yellow = [0.9490, 0.6235, 0.0196];  % #F29F05
C_orange = [0.9490, 0.4549, 0.0196];  % #F27405
C_black  = [0.1608, 0.1294, 0.1216];

orifice_area_down = [4.2393051660163885E-7 6.0990466330966524E-7 9.1714720191920184E-7 1.2087141008037621E-6 1.4994972177020734E-6 1.8020370643941173E-6 2.1273065886873767E-6 2.4901976483205798E-6 2.9142237028811906E-6 3.4409251976403956E-6 4.1416262933468387E-6 5.079029548900424E-6 6.1097028608176205E-6 7.1176464951336009E-6 8.0174282153472429E-6 8.0174282153472429E-6 8.0174282153472429E-6];
orifice_area_up = [1.1603918835830638E-7 5.7071556399722429E-7 9.0225534418047417E-7 1.1836330772438E-6 1.4516865165408956E-6 1.7228750837829867E-6 2.0089555087638053E-6 2.3240358672358304E-6 2.690062054814028E-6 3.1454393888245914E-6 3.7763838877548902E-6 4.7020304135147429E-6 5.7217307776244555E-6 6.697539350504235E-6 7.5573481894191871E-6 7.5573481894191871E-6 7.5573481894191871E-6];

u_plot = [0, 0.25, 0.30:0.05:1.00];

hfig = figure;
plot(u_plot, orifice_area_up * 1e6 , '-o', 'Color', C_blue, 'LineWidth', 1.5, 'DisplayName', 'Up');
hold on;
plot(u_plot, orifice_area_down * 1e6, '-o', 'Color', C_red,  'LineWidth', 1.5, 'DisplayName', 'Down');
xlabel('Control signal $u$ [-]');
ylabel('Orifice area $A$ [mm$^2$]');
legend('Location', 'northwest');

picturewidth = 20;
hw_ratio = 0.35;
set(findall(hfig,'-property','FontSize'),'FontSize',11)
set(findall(hfig,'-property','Box'),'Box','off')
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex')
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig, 'dcv_area_vectors', '-dpdf', '-vector', '-fillpage')