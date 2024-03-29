%% Define your own QP
clc;clear;close all;

%% Inerior Point Convex
IPQP = makeQP('QP - Interior-Point');
IPQP.plotIterations
% legend('off') % use this to turn off the legend form your figure if you want to.

%% Save IP as PDF
IPQP.savePDF

%% Active Set
ASQP = makeQP('QP - Active-Set');
ASQP.algAS
ASQP.plotIterations

%% Save AS as PDF
ASQP.savePDF


%% Functions

function[myQP] = makeQP(name)
myQP = QP(name); 

myQP.H = 0.5*[1 0;
            0 1];
myQP.c = -[1; 10];

A =    [-3     5;   % how exhausted you get in a day based on how much you study
        1      1;   % how much total time spent studying
        5.2  2.1];   % Some other constraint
b =    [  10 ;       % Cannot get too exhausted
           5 ;       % Must leave at least 4.5 hours for eating and sleeping
          20 ];       % Some other logical restriction

myQP.set_Ab(A,b)      % Add constraints to your QP object

% Define range (where to plot / what x values to show):
myQP.Range_x1( -1,  6) % From x1 = -0.5 to x1 = 5.5
myQP.Range_x2( -1,  6) % From x2 = -0.5 to x2 = 6.1

myQP.Limits = [0 inf ; 0 inf];
myQP.toggleLimits(1)

myQP.toggleHulls(1);         % Turn on infeasible hulls
end
