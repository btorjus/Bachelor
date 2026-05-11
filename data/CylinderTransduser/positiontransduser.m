close all; clc;

% Transducer position (m)
pos = [0.00, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50];

% Delta (m) -- measured
error = [0.0000, 0.0010, 0.0010, 0.0090, 0.0130, 0.0170, 0.0185, 0.0190, 0.0150, 0.0100, 0.0000];

% Dense x-grid for a smooth curve
xq = linspace(min(pos), max(pos), 1000);

% 6th-order polynomial evaluated on the dense grid (smooth)
pol_q = -59.608.*xq.^6 + 86.335.*xq.^5 - 44.643.*xq.^4 + 8.5147.*xq.^3 ...
        - 0.1469.*xq.^2 - 0.0085.*xq + 0.0002;

% Optional: smooth interpolation of the measured data (spline)
error_spline_q = spline(pos, error, xq);

% C_red    = '#f21a00'; 
% C_blue   = '#3b9ab2'; 
% C_lblue  = '#78b7c5';   
% C_yellow = '#ebcc2a';
% C_orange = '#e1af00';
% C_red = '#f21a00';

C_red    = [0.9490, 0.0196, 0.0196];  % #F20505
C_blue   = [0.3725, 0.7608, 0.8510];  % #5FC2D9
C_lblue  = [0.0118, 0.6510, 0.5333];  % #03A688
C_yellow = [0.9490, 0.6235, 0.0196];  % #F29F05
C_orange = [0.9490, 0.4549, 0.0196];  % #F27405
C_black  = [0.1608, 0.1294, 0.1216];

hfig = figure;  % save the figure handle in a variable
plot(pos, error, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5, 'DisplayName', 'Measured deviation');
hold on
plot(xq, error_spline_q,'color', C_red, 'LineWidth', 1.5, 'DisplayName', 'Spline fit');
plot(xq, pol_q, 'color', C_lblue, 'LineWidth', 1.5, 'DisplayName', 'Polynomial fit ($6^{th}$ order)');
xlabel('Stroke position [m]')
ylabel('Deviation [m]')
legend('Location','northwest');

% File name
fname = 'transdusererror';

% Template figure sizing & formatting (kept from your template, with var fix)
picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.45; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',11) % adjust fontsize to your document

set(findall(hfig,'-property','Box'),'Box','Off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
figpos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[figpos(3), figpos(4)])
print(hfig, fname, '-dpdf', '-vector', '-fillpage')

%fiks er stygg