% Assignment 4 Problem 2 - Production Planning
clc; clear; close all

% Made 2023 by Trym Arve Gabrielsen for MATLAB 2022a
% For Problem text, see:  https://github.com/TrymArve/QP/blob/main/Exercises/Production%20Planning/Production%20Planning.pdf

% This is a template for problem 2

%% a)    Define QP

%=====================================================================
% FILL OUT HERE:

% Objective
H = [  ,  ;
       ,  ;
c = [ , ];

% Constraints
A = [ , ;
      , ];
b = [  ;
      ];

% Limits:
x1_min = ;  
x2_min = ;

%=====================================================================

%% b)    Plot Contours and Constraints
close all

% Find "QP" class at: https://github.com/TrymArve/QP
ReactorsQP = QP('Production Planning for Two Reactors');

%=====================================================================
% FILL OUT HERE:

% Assign objective
ReactorsQP.H = ;
ReactorsQP.c = ;

% Assign constraints
ReactorsQP.set_Ab( , )

% Name the constraints
ReactorsQP.Constraints(1).DisplayName = ' '; % Add some reasonable name
ReactorsQP.Constraints(2).DisplayName = ' '; % Add some reasonable name

% Labels
xlabel(' ')
ylabel(' ')

%=====================================================================

% What area of x to show
buffer = -0.5;
ReactorsQP.Range_x1(buffer,10);
ReactorsQP.Range_x2(buffer,10);

% Assign limits
ReactorsQP.Limits = [x1_min inf;
                     x2_min inf];

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
