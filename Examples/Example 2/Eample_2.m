%% Define your own QP
clc;clear;close all;

myQP = QP('QP - Optimal Study Plan'); % Instansiate an instance of the QP class

% x1 = Time [h] spent re-watching lectures
% x2 = Time [h] spent solving exercise probelms

% Amount of learning per day (inverted due to 'minimization')(f = x*H*x + c*x):
myQP.H = 0.5*[1 0;
            0 1];
myQP.c = -[15; 10];

% Define linear constraints (Ax <= b):
A =    [3      5;   % how exhausted you get in a day based on how much you study
        1      1;   % how much total time spent studying
        5.2  2.1;   % Some other constraint
         -1    0;     % must be positive
         0    -1];    % must be positive
b =    [  19 ;       % Cannot get too exhausted
         4.5 ;       % Must leave at least 4.5 hours for eating and sleeping
          20 ;       % Some other logical restriction
           0 ;     % x1 >= 0
           0 ];    % x2 >= 0

myQP.set_Ab(A,b)      % Add constraints to your QP object

% Define range (where to plot / what x values to show):
myQP.Range_x1( -0.5,  5.5) % From x1 = -0.5 to x1 = 5.5
myQP.Range_x2( -0.5,  6.1) % From x2 = -0.5 to x2 = 6.1


myQP.toggleHulls(1);         % Turn on infeasible hulls
myQP.toggleOptimalPoint(1);  % Plot solution



%%%%%% Style the objective contours
myQP.Objective.DisplayName = 'Learning rate';  % Define legend entry



%%%%%% Style the constraints
% Constraint 1:
i = 1;
myQP.Constraints(i).DisplayName = 'Exhaustion Limit';  % Define legend entry
myQP.Constraints(i).Color       = [0.466 0.674 0.188]; % Define color of constraint line (green)
myQP.Constraints(i).LineWidth   = 2;                   % Define contour line thickness

% Constraint 2:
i = 2;
myQP.Constraints(i).DisplayName = 'Time Limit';        % Define legend entry
myQP.Constraints(i).Color       = [0.635 0.078 0.184]; % Define color of constraint line (red)
myQP.Constraints(i).LineWidth   = 2;                   % Define contour line thickness

% Constraint 3:
i = 3;
myQP.Constraints(i).DisplayName = 'Some Reasonable Limit'; % Define legend entry
myQP.Constraints(i).Color       = [0.494 0.184 0.556];     % Define color of constraint line (red)
myQP.Constraints(i).LineWidth   = 2;                       % Define contour line thickness

% Constraint 4 (Limit on x1):
i = 4;
myQP.Constraints(i).DisplayName = 'x_1 >= 0';       % Define legend entry
myQP.Constraints(i).LineWidth   = 1.5;              % Define contour line thickness

% Constraint 5 (Limit on x2):
i = 5;
myQP.Constraints(i).DisplayName = 'x_2 >= 0';       % Define legend entry
myQP.Constraints(i).LineWidth   = 1.5;              % Define contour line thickness

%%%%%% Set appropriate labels and title
xlabel(myQP.ax,'Time Spent Re-watching Lectures [h]')
ylabel(myQP.ax,'Time Spent Solving Exercises [h]')
title( myQP.ax,'Optimal Study Plan')


myQP.OptimalPoint.MarkerFaceColor = 'g';
myQP.OptimalPoint.DisplayName = 'Optimal Study Plan';

% plot:
myQP.plot()

%% Save as PDF

myQP.savePDF()