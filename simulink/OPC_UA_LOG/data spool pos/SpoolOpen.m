clc; close all; 

load torjus1.mat

PistonPos = data{1}.extractTimetable;
SpoolPos = data{2}.extractTimetable;

hfig = figure;  % save the figure handle in a variable
hold on
plot(PistonPos.Time, PistonPos.Variables,'color',[1 0.38 0.51],'LineWidth',1.5,'DisplayName','Ufiltrert');
plot(SpoolPos.Time, SpoolPos.Variables,'color',[174 129 255]./255,'LineWidth',1.5,'DisplayName','$\tau = 0.2$');
xlabel('tid $t$ (s)')
ylabel('Signal')
xlim([seconds(31.36) seconds(31.46)])
fname = 'SpoolActive';
legend('Location','northwest')

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document

set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig,fname,'-dpdf','-painters','-fillpage')