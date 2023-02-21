% Assignment 4 Problem 2 - Production Planning
clc; clear; close all

% Made 2023 by Trym Arve Gabrielsen for MATLAB 2022a
% For Problem text, see:  https://github.com/TrymArve/QP/blob/main/Exercises/Production%20Planning/Production%20Planning.pdf

%% a)    Define QP

% Objective/Cost:  x_1*(3 - 0.4*x_1) + x_2*(2 - 0.2*x_2) =    - 0.4*x_1^2 - 0.2*x_2^2 + 3*x_1 + 2*x_2
H = [0.4    0   ;
     0      0.2];
c = -[3 2];

% Constraints due to fully booking the reactors:
A = [2 1;   % Time spent using reactor 1 per tonne of A
     1 3];  % Time spent using reactor 2 per tonne of B
b = [ 8;    % Total available time at reactor A
     15];   % Total available time at reactor B

% Cannot produce negative tonnes:
x1_min = 0;  
x2_min = 0;

%% b)    Plot Contours and Constraints
close all

% Find "QP" class at: https://github.com/TrymArve/QP
ReactorsQP = QP('Production Planning for Two Reactors');

% Assign objective
ReactorsQP.H = H;
ReactorsQP.c = c;

% Assign constraints
ReactorsQP.set_Ab(A,b)

% What area of x to show
buffer = -0.5;
ReactorsQP.Range_x1(buffer,10);
ReactorsQP.Range_x2(buffer,10);

% Name the constraints
ReactorsQP.Constraints(1).DisplayName = 'R_{I}  fully booked';
ReactorsQP.Constraints(2).DisplayName = 'R_{II} fully booked';

% Assign limits
ReactorsQP.Limits = [x1_min inf;
                     x2_min inf];

% Labels
xlabel('A [tonnes]')
ylabel('B [tonnes]')

% Turn on hulls(infeasible zones) and limits
ReactorsQP.toggleHulls(1)
ReactorsQP.toggleLimits(1)

% plot
ReactorsQP.plot()


%% c)    Solve problem and plot iterations

ReactorsQP.algAS            % Set Algorithm to 'Active-Set'
ReactorsQP.x0 = [0;0];      % Set initial guess
ReactorsQP.plotIterations() % Solve and plot the iterations
ReactorsQP.Iterations       % Print iterations to command window

%% Save as PDF

ReactorsQP.savePDF()
