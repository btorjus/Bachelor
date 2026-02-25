clc; close all;

load torjus1.mat

%% 1. Extract timetables
PistonPos = data{1}.extractTimetable;
SpoolPos  = data{2}.extractTimetable;

%% 2. Select time interval (31.4s to 32.0s)
t_start = seconds(31.38);
t_end   = seconds(32.0);

PistonPos_sel = PistonPos(PistonPos.Time >= t_start & PistonPos.Time <= t_end, :);
SpoolPos_sel  = SpoolPos(SpoolPos.Time >= t_start & SpoolPos.Time <= t_end, :);

%% 3. Synchronize onto a common time vector
combined = synchronize(PistonPos_sel, SpoolPos_sel, 'union', 'linear');

%% 4. Convert to regular table with time in plain seconds
T = timetable2table(combined);
T.Time = seconds(T.Time);

%% 5. Export to CSV with semicolon delimiter
writetable(T, 'torjus1_export.csv', 'Delimiter', ';');

fprintf('Done! Exported %d rows to torjus1_export.csv\n', height(T));