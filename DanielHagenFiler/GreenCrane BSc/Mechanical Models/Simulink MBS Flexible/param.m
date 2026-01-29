%% Spring Damper Data
E= 210000e6;                    % Young's modulus
I= 8.8524720000000004e-6;       % Area moment of inertia
m_arm=82;                       % Mass of arm
dens_arm= m_arm/3.68;           % Density arm
DR=0.246;                       % Damping ratio
I_arm = 3.6;                    % Length of long arm [m]
I_short= 0.552809260752356;     % Length from MJ to cyl [m]
I_long= I_arm-I_short;          % Length from cyl to end
no_sec_long= 5;                 % Number of long sections [-]
I_sec_long= I_long/no_sec_long; % Length of long section [m]
m_sec_long= dens_arm*I_sec_long;% Mass of long section
J_sec_long= (1/3)*m_sec_long*I_sec_long^2; % Moment of inertia, long section
no_sec_short= 4;                  % Number of long sections [-]
I_sec_short= I_short/no_sec_short; % Length of long section [m]
m_sec_short= dens_arm*I_sec_short;% Mass of long section
J_sec_short= (1/3)*m_sec_short*I_sec_short^2; % Moment of inertia, long section

% Spring Damper Long Sections
k_eff_long=E*I/I_sec_long*0.80;   % Effective stiffness of long section
d_eff_long=DR*sqrt(2*J_sec_long*k_eff_long); % Effective damping of long section
% Spring Damper Short Sections
k_eff_short=E*I/I_sec_short*0.80;   % Effective stiffness of long section
d_eff_short=DR*sqrt(2*J_sec_short*k_eff_short); % Effective damping of long section


% Simscape(TM) Multibody(TM) version: 5.1

% This is a model data file derived from a Simscape Multibody Import XML file using the smimport function.
% The data in this file sets the block parameter values in an imported Simscape Multibody model.
% For more information on this file, see the smimport function help page in the Simscape Multibody documentation.
% You can modify numerical values, but avoid any other changes to this file.
% Do not add code to this file. Do not edit the physical units shown in comments.

%%%VariableName:smiData


%============= RigidTransform =============%

%Initialize the RigidTransform structure array by filling in null values.
smiData.RigidTransform(63).translation = [0.0 0.0 0.0];
smiData.RigidTransform(63).angle = 0.0;
smiData.RigidTransform(63).axis = [0.0 0.0 0.0];
smiData.RigidTransform(63).ID = '';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(1).translation = [-1.1102230246251565e-13 722.00000000000023 0];  % mm
smiData.RigidTransform(1).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(1).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(1).ID = 'B[Cyl_hus_part-1:-:Cyl_rod_part-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(2).translation = [2.4829027722717001e-12 -50.259544455820055 5.8920380567815703e-15];  % mm
smiData.RigidTransform(2).angle = 2.0943951023931948;  % rad
smiData.RigidTransform(2).axis = [-0.57735026918962562 -0.57735026918962629 -0.57735026918962551];
smiData.RigidTransform(2).ID = 'F[Cyl_hus_part-1:-:Cyl_rod_part-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(3).translation = [-49.999999999999979 74.999999999999844 3600.0000000000009];  % mm
smiData.RigidTransform(3).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(3).axis = [0.57735026918962573 0.57735026918962584 0.57735026918962573];
smiData.RigidTransform(3).ID = 'B[Arm_assembly-1:-:Arm_ballast_big-4]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(4).translation = [-50.000000000000938 81.421392473445749 104.99999999999957];  % mm
smiData.RigidTransform(4).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(4).axis = [0.57735026918962584 0.57735026918962562 0.57735026918962584];
smiData.RigidTransform(4).ID = 'F[Arm_assembly-1:-:Arm_ballast_big-4]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(5).translation = [-224.99999999999994 6.3108872417680944e-30 -2.8421709430404007e-14];  % mm
smiData.RigidTransform(5).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(5).axis = [0.57735026918962584 0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(5).ID = 'B[Arm_assembly-1:-:Base_assembly-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(6).translation = [-890 1740.0000000000007 224.99999999999994];  % mm
smiData.RigidTransform(6).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(6).axis = [1 4.6967067134323562e-34 2.7755059762165175e-16];
smiData.RigidTransform(6).ID = 'F[Arm_assembly-1:-:Base_assembly-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(7).translation = [0 0 0];  % mm
smiData.RigidTransform(7).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(7).axis = [0.57735026918962584 0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(7).ID = 'B[Arm_assembly-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(8).translation = [0 -99.999999999999616 0];  % mm
smiData.RigidTransform(8).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(8).axis = [-1 1.0494341676531588e-32 -2.4451527764766893e-16];
smiData.RigidTransform(8).ID = 'F[Arm_assembly-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(9).translation = [0 0 0];  % mm
smiData.RigidTransform(9).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(9).axis = [0.57735026918962584 0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(9).ID = 'B[Arm_ballast_big-4:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(10).translation = [3341.1451362868756 -1125.5805246531663 0];  % mm
smiData.RigidTransform(10).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(10).axis = [-1 9.0934818697440832e-33 -1.6686879824876025e-16];
smiData.RigidTransform(10).ID = 'F[Arm_ballast_big-4:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(11).translation = [0 0 0];  % mm
smiData.RigidTransform(11).angle = 0;  % rad
smiData.RigidTransform(11).axis = [0 0 0];
smiData.RigidTransform(11).ID = 'B[Base_assembly-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(12).translation = [889.99999999999989 -1840.0000000000002 0];  % mm
smiData.RigidTransform(12).angle = 0;  % rad
smiData.RigidTransform(12).axis = [0 0 0];
smiData.RigidTransform(12).ID = 'F[Base_assembly-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(13).translation = [0 20.000000000000007 48.000000000000043];  % mm
smiData.RigidTransform(13).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(13).axis = [-0.57735026918962584 -0.57735026918962573 -0.57735026918962573];
smiData.RigidTransform(13).ID = 'B[CB_assembly-1:-:Cyl_hus_part-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(14).translation = [2.7906931238770917e-13 -2.1145023193627654e-14 19.999999999999993];  % mm
smiData.RigidTransform(14).angle = 3.0414605391635394e-16;  % rad
smiData.RigidTransform(14).axis = [-0.30357134494025351 -0.95280871035647308 4.3986426807714303e-17];
smiData.RigidTransform(14).ID = 'F[CB_assembly-1:-:Cyl_hus_part-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(15).translation = [-99.999999999999773 625 49.999999999999943];  % mm
smiData.RigidTransform(15).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(15).axis = [-0.57735026918962562 -0.57735026918962573 -0.57735026918962573];
smiData.RigidTransform(15).ID = 'B[Base_assembly-1:-:CB_assembly-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(16).translation = [363.00000000000006 -49.999999999999943 -9.9999999999997655];  % mm
smiData.RigidTransform(16).angle = 1.570796326794897;  % rad
smiData.RigidTransform(16).axis = [-7.8504622934188734e-17 -7.8504622934188734e-17 -1];
smiData.RigidTransform(16).ID = 'F[Base_assembly-1:-:CB_assembly-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(17).translation = [0 0 0];  % mm
smiData.RigidTransform(17).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(17).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(17).ID = 'B[CB_assembly-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(18).translation = [427.00000000000006 -1205.0000000000005 0];  % mm
smiData.RigidTransform(18).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(18).axis = [-1 -0 -0];
smiData.RigidTransform(18).ID = 'F[CB_assembly-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(19).translation = [2.886579864025407e-12 2.2204460492503131e-13 15];  % mm
smiData.RigidTransform(19).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(19).axis = [1 0 0];
smiData.RigidTransform(19).ID = 'B[Cyl_rod_part-1:-:CB_assembly-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(20).translation = [8.5265128291212022e-14 -14.999999999999993 48.000000000000014];  % mm
smiData.RigidTransform(20).angle = 2.0943951023931962;  % rad
smiData.RigidTransform(20).axis = [-0.57735026918962595 -0.57735026918962573 -0.57735026918962562];
smiData.RigidTransform(20).ID = 'F[Cyl_rod_part-1:-:CB_assembly-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(21).translation = [-49.999999999999986 -75.000000000000071 276.40463037617803];  % mm
smiData.RigidTransform(21).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(21).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(21).ID = 'B[Arm_assembly-1:-:CB_assembly-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(22).translation = [-271.09536962382174 50.000000000000128 -9.999999999999865];  % mm
smiData.RigidTransform(22).angle = 3.5437645158249467e-16;  % rad
smiData.RigidTransform(22).axis = [-0.61678804276360322 0.78322291144584544 0.078322291144584541];
smiData.RigidTransform(22).ID = 'F[Arm_assembly-1:-:CB_assembly-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(23).translation = [0 0 0];  % mm
smiData.RigidTransform(23).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(23).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(23).ID = 'B[CB_assembly-2:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(24).translation = [498.8984779829463 -341.00115905592497 0];  % mm
smiData.RigidTransform(24).angle = 4.8413394244973844e-16;  % rad
smiData.RigidTransform(24).axis = [0.16024303461581207 -0.98707759059615752 -3.8288291654692844e-17];
smiData.RigidTransform(24).ID = 'F[CB_assembly-2:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(25).translation = [-889.99999999999955 424.99999999999983 0];  % mm
smiData.RigidTransform(25).angle = 0;  % rad
smiData.RigidTransform(25).axis = [0 0 0];
smiData.RigidTransform(25).ID = 'AssemblyGround[Base_assembly-1:Base_profil_cyl_mount_support_sideways-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(26).translation = [-150.00000000000014 50.000000000000043 0];  % mm
smiData.RigidTransform(26).angle = 0;  % rad
smiData.RigidTransform(26).axis = [0 0 0];
smiData.RigidTransform(26).ID = 'AssemblyGround[Base_assembly-1:Base_profil_base_support-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(27).translation = [0 50.000000000000043 -275];  % mm
smiData.RigidTransform(27).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(27).axis = [0 1 0];
smiData.RigidTransform(27).ID = 'AssemblyGround[Base_assembly-1:Base_profil_base_along_arm-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(28).translation = [-149.99999999999969 287.50000000000011 0];  % mm
smiData.RigidTransform(28).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(28).axis = [-1 -0 -0];
smiData.RigidTransform(28).ID = 'AssemblyGround[Base_assembly-1:Base_profil_base_support_2-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(29).translation = [0 0 0];  % mm
smiData.RigidTransform(29).angle = 0;  % rad
smiData.RigidTransform(29).axis = [0 0 0];
smiData.RigidTransform(29).ID = 'AssemblyGround[Base_assembly-1:Base_bearing_mount-1:Base_bearing_mount_sideways-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(30).translation = [175.00000000000006 0 -149.99999999999997];  % mm
smiData.RigidTransform(30).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(30).axis = [0 1 0];
smiData.RigidTransform(30).ID = 'AssemblyGround[Base_assembly-1:Base_bearing_mount-1:Base_bearing_mount_support-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(31).translation = [-175.00000000000006 0 -150.00000000000006];  % mm
smiData.RigidTransform(31).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(31).axis = [3.4694469519536132e-16 -1 -0];
smiData.RigidTransform(31).ID = 'AssemblyGround[Base_assembly-1:Base_bearing_mount-1:Base_bearing_mount_support-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(32).translation = [-1040 1860.0000000000002 0];  % mm
smiData.RigidTransform(32).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(32).axis = [-0 -1 -0];
smiData.RigidTransform(32).ID = 'AssemblyGround[Base_assembly-1:Base_bearing_mount-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(33).translation = [-789.99999999999977 1020 -275];  % mm
smiData.RigidTransform(33).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(33).axis = [-1 -0 -0];
smiData.RigidTransform(33).ID = 'AssemblyGround[Base_assembly-1:Base_profil_tower-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(34).translation = [-989.99999999999966 1020 275];  % mm
smiData.RigidTransform(34).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(34).axis = [-1 -0 -0];
smiData.RigidTransform(34).ID = 'AssemblyGround[Base_assembly-1:Base_profil_tower-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(35).translation = [0 50.000000000000043 275];  % mm
smiData.RigidTransform(35).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(35).axis = [0 1 0];
smiData.RigidTransform(35).ID = 'AssemblyGround[Base_assembly-1:Base_profil_base_along_arm-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(36).translation = [990 50.000000000000043 0];  % mm
smiData.RigidTransform(36).angle = 0;  % rad
smiData.RigidTransform(36).axis = [0 0 0];
smiData.RigidTransform(36).ID = 'AssemblyGround[Base_assembly-1:Base_profil_base_sideways-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(37).translation = [20.139789775528993 860.13978977554859 275.00000000000017];  % mm
smiData.RigidTransform(37).angle = 1.7177715174584061;  % rad
smiData.RigidTransform(37).axis = [-0.35740674433659753 -0.86285620946101327 -0.35740674433659791];
smiData.RigidTransform(37).ID = 'AssemblyGround[Base_assembly-1:Base_profil_incline-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(38).translation = [-519.99999999999977 550 0];  % mm
smiData.RigidTransform(38).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(38).axis = [-6.1232339957367636e-17 1 6.1232339957367636e-17];
smiData.RigidTransform(38).ID = 'AssemblyGround[Base_assembly-1:Base_profil_cyl_mount1-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(39).translation = [-990.00000000000011 50.000000000000043 0];  % mm
smiData.RigidTransform(39).angle = 0;  % rad
smiData.RigidTransform(39).axis = [0 0 0];
smiData.RigidTransform(39).ID = 'AssemblyGround[Base_assembly-1:Base_profil_base_sideways-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(40).translation = [20.139789775548312 860.13978977552893 -274.99999999999977];  % mm
smiData.RigidTransform(40).angle = 1.7177715174583978;  % rad
smiData.RigidTransform(40).axis = [0.3574067443365887 0.86285620946102037 -0.35740674433658887];
smiData.RigidTransform(40).ID = 'AssemblyGround[Base_assembly-1:Base_profil_incline-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(41).translation = [-890 1740.0000000000002 165.00000000000006];  % mm
smiData.RigidTransform(41).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(41).axis = [0 0 1];
smiData.RigidTransform(41).ID = 'AssemblyGround[Base_assembly-1:Bearing_house_SKF_SNA_513-611-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(42).translation = [-989.99999999999966 1020 -275];  % mm
smiData.RigidTransform(42).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(42).axis = [-1 -0 -0];
smiData.RigidTransform(42).ID = 'AssemblyGround[Base_assembly-1:Base_profil_tower-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(43).translation = [-890 1740.0000000000005 -164.99999999999991];  % mm
smiData.RigidTransform(43).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(43).axis = [-0 -3.4694469519536137e-16 -1];
smiData.RigidTransform(43).ID = 'AssemblyGround[Base_assembly-1:Bearing_house_SKF_SNA_513-611-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(44).translation = [0 0 0];  % mm
smiData.RigidTransform(44).angle = 0;  % rad
smiData.RigidTransform(44).axis = [0 0 0];
smiData.RigidTransform(44).ID = 'AssemblyGround[Base_assembly-1:Base_bottomplate-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(45).translation = [-789.99999999999977 1020 275];  % mm
smiData.RigidTransform(45).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(45).axis = [1 0 0];
smiData.RigidTransform(45).ID = 'AssemblyGround[Base_assembly-1:Base_profil_tower-4]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(46).translation = [0 0 0];  % mm
smiData.RigidTransform(46).angle = 0;  % rad
smiData.RigidTransform(46).axis = [0 0 0];
smiData.RigidTransform(46).ID = 'AssemblyGround[Arm_assembly-1:Arm1-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(47).translation = [0 0 0];  % mm
smiData.RigidTransform(47).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(47).axis = [-0.70710678118654746 -3.9252311467094373e-17 0.70710678118654757];
smiData.RigidTransform(47).ID = 'AssemblyGround[Arm_assembly-1:Arm_pipe_reinforcement-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(48).translation = [0 0 0];  % mm
smiData.RigidTransform(48).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(48).axis = [5.5511151231257802e-17 -1 -5.5511151231257821e-17];
smiData.RigidTransform(48).ID = 'AssemblyGround[Arm_assembly-1:Arm_shaft-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(49).translation = [0 0 276.4046303761782];  % mm
smiData.RigidTransform(49).angle = 0;  % rad
smiData.RigidTransform(49).axis = [0 0 0];
smiData.RigidTransform(49).ID = 'AssemblyGround[Arm_assembly-1:Arm_short-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(50).translation = [0 0 1771.685556451414];  % mm
smiData.RigidTransform(50).angle = 0;  % rad
smiData.RigidTransform(50).axis = [0 0 0];
smiData.RigidTransform(50).ID = 'AssemblyGround[Arm_assembly-1:Arm_long-4]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(51).translation = [0 0 414.60694556426716];  % mm
smiData.RigidTransform(51).angle = 0;  % rad
smiData.RigidTransform(51).axis = [0 0 0];
smiData.RigidTransform(51).ID = 'AssemblyGround[Arm_assembly-1:Arm_short-4]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(52).translation = [0 0 0];  % mm
smiData.RigidTransform(52).angle = 0;  % rad
smiData.RigidTransform(52).axis = [0 0 0];
smiData.RigidTransform(52).ID = 'AssemblyGround[Arm_assembly-1:Arm2-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(53).translation = [0 0 138.20231518808905];  % mm
smiData.RigidTransform(53).angle = 0;  % rad
smiData.RigidTransform(53).axis = [0 0 0];
smiData.RigidTransform(53).ID = 'AssemblyGround[Arm_assembly-1:Arm_short-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(54).translation = [0 0 552.80926075235618];  % mm
smiData.RigidTransform(54).angle = 0;  % rad
smiData.RigidTransform(54).axis = [0 0 0];
smiData.RigidTransform(54).ID = 'AssemblyGround[Arm_assembly-1:Arm_long-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(55).translation = [0 0 1162.2474086018854];  % mm
smiData.RigidTransform(55).angle = 0;  % rad
smiData.RigidTransform(55).axis = [0 0 0];
smiData.RigidTransform(55).ID = 'AssemblyGround[Arm_assembly-1:Arm_long-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(56).translation = [0 0 2990.5618521504725];  % mm
smiData.RigidTransform(56).angle = 0;  % rad
smiData.RigidTransform(56).axis = [0 0 0];
smiData.RigidTransform(56).ID = 'AssemblyGround[Arm_assembly-1:Arm_long-6]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(57).translation = [0 0 2381.1237043009428];  % mm
smiData.RigidTransform(57).angle = 0;  % rad
smiData.RigidTransform(57).axis = [0 0 0];
smiData.RigidTransform(57).ID = 'AssemblyGround[Arm_assembly-1:Arm_long-5]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(58).translation = [0 31 10.000000000000009];  % mm
smiData.RigidTransform(58).angle = 1.5707963267948966;  % rad
smiData.RigidTransform(58).axis = [1 0 0];
smiData.RigidTransform(58).ID = 'AssemblyGround[CB_assembly-1:CB_850-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(59).translation = [0 -31 10.000000000000009];  % mm
smiData.RigidTransform(59).angle = 1.5707963267948966;  % rad
smiData.RigidTransform(59).axis = [1 0 0];
smiData.RigidTransform(59).ID = 'AssemblyGround[CB_assembly-1:CB_850-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(60).translation = [0 0 0];  % mm
smiData.RigidTransform(60).angle = 0;  % rad
smiData.RigidTransform(60).axis = [0 0 0];
smiData.RigidTransform(60).ID = 'AssemblyGround[CB_assembly-1:CB_plate-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(61).translation = [0 30.999999999999986 10.000000000000064];  % mm
smiData.RigidTransform(61).angle = 1.570796326794897;  % rad
smiData.RigidTransform(61).axis = [1 -1.1102230246251564e-16 1.1102230246251562e-16];
smiData.RigidTransform(61).ID = 'AssemblyGround[CB_assembly-2:CB_850-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(62).translation = [0 0 0];  % mm
smiData.RigidTransform(62).angle = 0;  % rad
smiData.RigidTransform(62).axis = [0 0 0];
smiData.RigidTransform(62).ID = 'AssemblyGround[CB_assembly-2:CB_plate-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(63).translation = [0 -30.999999999999986 10.000000000000064];  % mm
smiData.RigidTransform(63).angle = 1.570796326794897;  % rad
smiData.RigidTransform(63).axis = [1 -1.1102230246251564e-16 1.1102230246251562e-16];
smiData.RigidTransform(63).ID = 'AssemblyGround[CB_assembly-2:CB_850-2]';


%============= Solid =============%
%Center of Mass (CoM) %Moments of Inertia (MoI) %Product of Inertia (PoI)

%Initialize the Solid structure array by filling in null values.
smiData.Solid(23).mass = 0.0;
smiData.Solid(23).CoM = [0.0 0.0 0.0];
smiData.Solid(23).MoI = [0.0 0.0 0.0];
smiData.Solid(23).PoI = [0.0 0.0 0.0];
smiData.Solid(23).color = [0.0 0.0 0.0];
smiData.Solid(23).opacity = 0.0;
smiData.Solid(23).ID = '';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(1).mass = 4.8165837227212061;  % kg
smiData.Solid(1).CoM = [2.860907107888448e-12 -292.43013265615258 0];  % mm
smiData.Solid(1).MoI = [209187.87288806378 1419.2827378787788 209422.54761435269];  % kg*mm^2
smiData.Solid(1).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(1).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(1).opacity = 1;
smiData.Solid(1).ID = 'Cyl_rod_part*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(2).mass = 9.6329999999999938;  % kg
smiData.Solid(2).CoM = [0 0 0];  % mm
smiData.Solid(2).MoI = [353691.65000000031 353691.65000000031 29059.549999999988];  % kg*mm^2
smiData.Solid(2).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(2).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(2).opacity = 1;
smiData.Solid(2).ID = 'Base_profil_cyl_mount_support_sideways*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(3).mass = 6.6689999999999969;  % kg
smiData.Solid(3).CoM = [0 0 0];  % mm
smiData.Solid(3).MoI = [122598.44999999997 122598.44999999997 20118.149999999987];  % kg*mm^2
smiData.Solid(3).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(3).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(3).opacity = 1;
smiData.Solid(3).ID = 'Base_profil_base_support*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(4).mass = 27.861599999999967;  % kg
smiData.Solid(4).CoM = [0 0 0];  % mm
smiData.Solid(4).MoI = [8248194.4999999879 8248194.4999999879 84049.159999999887];  % kg*mm^2
smiData.Solid(4).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(4).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(4).opacity = 1;
smiData.Solid(4).ID = 'Base_profil_base_along_arm*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(5).mass = 5.557500000000001;  % kg
smiData.Solid(5).CoM = [0 0 0];  % mm
smiData.Solid(5).MoI = [73509.515624999956 73509.515624999956 16765.124999999996];  % kg*mm^2
smiData.Solid(5).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(5).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(5).opacity = 1;
smiData.Solid(5).ID = 'Base_profil_base_support_2*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(6).mass = 12.167999999999999;  % kg
smiData.Solid(6).CoM = [0 0 15];  % mm
smiData.Solid(6).MoI = [7402.1999999999998 429327.59999999998 434904.60000000003];  % kg*mm^2
smiData.Solid(6).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(6).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(6).opacity = 1;
smiData.Solid(6).ID = 'Base_bearing_mount_sideways*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(7).mass = 18.402422681833922;  % kg
smiData.Solid(7).CoM = [0 0 0.17257364622951737];  % mm
smiData.Solid(7).MoI = [25375.888703044395 151754.8722992937 146008.23445687213];  % kg*mm^2
smiData.Solid(7).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(7).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(7).opacity = 1;
smiData.Solid(7).ID = 'Base_bearing_mount_support*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(8).mass = 27.268800000000017;  % kg
smiData.Solid(8).CoM = [0 0 0];  % mm
smiData.Solid(8).MoI = [7734567.8800000139 7734567.8800000139 82260.879999999946];  % kg*mm^2
smiData.Solid(8).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(8).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(8).opacity = 1;
smiData.Solid(8).ID = 'Base_profil_tower*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(9).mass = 14.819999999999997;  % kg
smiData.Solid(9).CoM = [0 0 0];  % mm
smiData.Solid(9).MoI = [1257353.4999999993 1257353.4999999993 44706.999999999971];  % kg*mm^2
smiData.Solid(9).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(9).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(9).opacity = 1;
smiData.Solid(9).ID = 'Base_profil_base_sideways*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(10).mass = 31.863000000000067;  % kg
smiData.Solid(10).CoM = [0 1.4031007751936657 -2.0702024346112401e-12];  % mm
smiData.Solid(10).MoI = [12369950.446573693 12370013.175000051 96057.321573643581];  % kg*mm^2
smiData.Solid(10).PoI = [-2.0911267792906816e-09 9.8309377794062721e-10 0];  % kg*mm^2
smiData.Solid(10).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(10).opacity = 1;
smiData.Solid(10).ID = 'Base_profil_incline*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(11).mass = 18.712511999999986;  % kg
smiData.Solid(11).CoM = [0 0 0];  % mm
smiData.Solid(11).MoI = [1158297.1021439959 1130848.153343996 88553.844287999877];  % kg*mm^2
smiData.Solid(11).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(11).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(11).opacity = 1;
smiData.Solid(11).ID = 'Base_profil_cyl_mount1*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(12).mass = 13.596540715159906;  % kg
smiData.Solid(12).CoM = [1.929750493493901e-05 -22.709191521562484 -4.4367388378324253e-07];  % mm
smiData.Solid(12).MoI = [33635.78727140413 54141.201525336743 69140.080745075509];  % kg*mm^2
smiData.Solid(12).PoI = [-0.00078600605072955392 -0.0034532237434838136 -0.031608110011349271];  % kg*mm^2
smiData.Solid(12).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(12).opacity = 1;
smiData.Solid(12).ID = 'Bearing_house_SKF_SNA_513-611*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(13).mass = 205.27308324077265;  % kg
smiData.Solid(13).CoM = [0.042974909483599 -6 0];  % mm
smiData.Solid(13).MoI = [17062075.028355043 99541009.263559639 82483860.789202377];  % kg*mm^2
smiData.Solid(13).PoI = [0 -3.1347314643341763e-08 0];  % kg*mm^2
smiData.Solid(13).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(13).opacity = 1;
smiData.Solid(13).ID = 'Base_bottomplate*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(14).mass = 1.5469015420991932;  % kg
smiData.Solid(14).CoM = [0 0 -43.501256006689573];  % mm
smiData.Solid(14).MoI = [6210.3622822762354 3169.9173485599836 7819.2461559630938];  % kg*mm^2
smiData.Solid(14).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(14).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(14).opacity = 1;
smiData.Solid(14).ID = 'Arm1*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(15).mass = 3.0392863757660535;  % kg
smiData.Solid(15).CoM = [3.5010141057413836e-05 -1.6540994796753868e-05 1.6591952190266184e-05];  % mm
smiData.Solid(15).MoI = [10014.689309435986 9956.3567994719779 3799.9257750078209];  % kg*mm^2
smiData.Solid(15).PoI = [0.00021812042439461313 -0.0087798770868252433 0.0025330309494177167];  % kg*mm^2
smiData.Solid(15).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(15).opacity = 1;
smiData.Solid(15).ID = 'Arm_pipe_reinforcement*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(16).mass = 9.7812116640445321;  % kg
smiData.Solid(16).CoM = [-0.00011807038343822437 -1.5561677800652728e-06 7.5788272412049949e-05];  % mm
smiData.Solid(16).MoI = [168960.1077177212 168919.50610679106 4421.8506169422863];  % kg*mm^2
smiData.Solid(16).PoI = [0.00074271842422807949 0.091185655046054886 0.00071970141580861172];  % kg*mm^2
smiData.Solid(16).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(16).opacity = 1;
smiData.Solid(16).ID = 'Arm_shaft*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(17).mass = 3.0787053349820184;  % kg
smiData.Solid(17).CoM = [0 0 69.101157594044508];  % mm
smiData.Solid(17).MoI = [14443.012430654891 9926.9311525128578 14569.459880246568];  % kg*mm^2
smiData.Solid(17).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(17).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(17).opacity = 1;
smiData.Solid(17).ID = 'Arm_short*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(18).mass = 13.576331732014367;  % kg
smiData.Solid(18).CoM = [0 0 304.71907392476436];  % mm
smiData.Solid(18).MoI = [462285.54095456644 442370.73557708011 64247.727199802677];  % kg*mm^2
smiData.Solid(18).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(18).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(18).opacity = 1;
smiData.Solid(18).ID = 'Arm_long*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(19).mass = 2.8434628770812136;  % kg
smiData.Solid(19).CoM = [0 0 73.413479114063975];  % mm
smiData.Solid(19).MoI = [13630.590187534424 8688.2495756761382 13955.006580209669];  % kg*mm^2
smiData.Solid(19).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(19).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(19).opacity = 1;
smiData.Solid(19).ID = 'Arm2*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(20).mass = 10.466993259886658;  % kg
smiData.Solid(20).CoM = [0.16121835460485281 260.9895378194044 0];  % mm
smiData.Solid(20).MoI = [505818.66835005226 9692.4671097065821 506227.07681252179];  % kg*mm^2
smiData.Solid(20).PoI = [0 0 386.63141878753487];  % kg*mm^2
smiData.Solid(20).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(20).opacity = 1;
smiData.Solid(20).ID = 'Cyl_hus_part*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(21).mass = 0.72391698832317963;  % kg
smiData.Solid(21).CoM = [0 23.724672073330986 0];  % mm
smiData.Solid(21).MoI = [258.27263615563447 575.80703450980798 775.68370027403932];  % kg*mm^2
smiData.Solid(21).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(21).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(21).opacity = 1;
smiData.Solid(21).ID = 'CB_850*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(22).mass = 3.616871051280758;  % kg
smiData.Solid(22).CoM = [0 0 0];  % mm
smiData.Solid(22).MoI = [7123.3284236708814 7123.3284236708796 14005.532110589711];  % kg*mm^2
smiData.Solid(22).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(22).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(22).opacity = 1;
smiData.Solid(22).ID = 'CB_plate*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(23).mass = 316.34672261924374;  % kg
smiData.Solid(23).CoM = [0 88.727510422810738 0];  % mm
smiData.Solid(23).MoI = [3518554.7762997248 15180776.541739946 16374182.906788228];  % kg*mm^2
smiData.Solid(23).PoI = [0 0 1.4057493363784136e-09];  % kg*mm^2
smiData.Solid(23).color = [0.52941176470588236 0.5490196078431373 0.5490196078431373];
smiData.Solid(23).opacity = 1;
smiData.Solid(23).ID = 'Arm_ballast_big*:*Default';


%============= Joint =============%
%X Revolute Primitive (Rx) %Y Revolute Primitive (Ry) %Z Revolute Primitive (Rz)
%X Prismatic Primitive (Px) %Y Prismatic Primitive (Py) %Z Prismatic Primitive (Pz) %Spherical Primitive (S)
%Constant Velocity Primitive (CV) %Lead Screw Primitive (LS)
%Position Target (Pos)

%Initialize the CylindricalJoint structure array by filling in null values.
smiData.CylindricalJoint(3).Rz.Pos = 0.0;
smiData.CylindricalJoint(3).Pz.Pos = 0.0;
smiData.CylindricalJoint(3).ID = '';

smiData.CylindricalJoint(1).Rz.Pos = -2.2035529218183424e-14;  % deg
smiData.CylindricalJoint(1).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(1).ID = '[Cyl_hus_part-1:-:Cyl_rod_part-1]';

smiData.CylindricalJoint(2).Rz.Pos = 73.041150614207623;  % deg
smiData.CylindricalJoint(2).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(2).ID = '[Arm_assembly-1:-:Base_assembly-1]';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.CylindricalJoint(3).Rz.Pos = 77.340746630816696;  % deg
smiData.CylindricalJoint(3).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(3).ID = '[Cyl_rod_part-1:-:CB_assembly-2]';


%Initialize the PlanarJoint structure array by filling in null values.
smiData.PlanarJoint(4).Rz.Pos = 0.0;
smiData.PlanarJoint(4).Px.Pos = 0.0;
smiData.PlanarJoint(4).Py.Pos = 0.0;
smiData.PlanarJoint(4).ID = '';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.PlanarJoint(1).Rz.Pos = 73.041150614207623;  % deg
smiData.PlanarJoint(1).Px.Pos = 0;  % mm
smiData.PlanarJoint(1).Py.Pos = 0;  % mm
smiData.PlanarJoint(1).ID = '[Arm_assembly-1:-:]';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.PlanarJoint(2).Rz.Pos = 73.041150614207652;  % deg
smiData.PlanarJoint(2).Px.Pos = 0;  % mm
smiData.PlanarJoint(2).Py.Pos = 0;  % mm
smiData.PlanarJoint(2).ID = '[Arm_ballast_big-4:-:]';

smiData.PlanarJoint(3).Rz.Pos = 90;  % deg
smiData.PlanarJoint(3).Px.Pos = 0;  % mm
smiData.PlanarJoint(3).Py.Pos = 0;  % mm
smiData.PlanarJoint(3).ID = '[CB_assembly-1:-:]';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.PlanarJoint(4).Rz.Pos = 106.95884938579239;  % deg
smiData.PlanarJoint(4).Px.Pos = 0;  % mm
smiData.PlanarJoint(4).Py.Pos = 0;  % mm
smiData.PlanarJoint(4).ID = '[CB_assembly-2:-:]';


%Initialize the PrismaticJoint structure array by filling in null values.
smiData.PrismaticJoint(1).Pz.Pos = 0.0;
smiData.PrismaticJoint(1).ID = '';

smiData.PrismaticJoint(1).Pz.Pos = 0;  % m
smiData.PrismaticJoint(1).ID = '[Arm_assembly-1:-:Arm_ballast_big-4]';


%Initialize the RevoluteJoint structure array by filling in null values.
smiData.RevoluteJoint(1).Rz.Pos = 0.0;
smiData.RevoluteJoint(1).ID = '';

smiData.RevoluteJoint(1).Rz.Pos = -85.700403983390842;  % deg
smiData.RevoluteJoint(1).ID = '[CB_assembly-1:-:Cyl_hus_part-1]';

