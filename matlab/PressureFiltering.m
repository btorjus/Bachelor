clc; clear; close all;

%% Pressure filter calculation
% Filter constants
fNum = 0.003137;
fDen = 0.9969;

% Initial conditions
s = 0;      
n = 0;      

% Cycles to show in command window
display_cycles = [1, 2, 3, 500, 1000];

fprintf('%-10s %-20s %-20s %-20s\n', 'Cycle', 'Raw Pressure', 'New State', 'Output');
fprintf('%s\n', repmat('-', 1, 70));

for k = 1:2000
    % Step change: pressure jumps to 5 bar at cycle 2
    if k >= 2
        n = 5.0;
    else
        n = 0.0;
    end

    % Filter state update
    s = n + fDen * s;

    % Filtered output
    y = fNum * s;

    % Print selected cycles
    if ismember(k, display_cycles)
        fprintf('%-10d %-20.4f %-20.4f %-20.4f\n', k, n, s, y);
    end
end
