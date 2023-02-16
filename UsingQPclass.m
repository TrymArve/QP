% Using the QP class

% HOW TO:
% Run the sections successively by using ctrl + shift + enter,
% and stop at each one to see what the secion does. 


clc;clear;close all;

myQP = QP('myQP name'); % Instansiate an instance of the QP class

myQP.plot() % Plot the default QP




%% Define your own QP
clc;clear;close all;

myQP = QP('myQP name'); % Instansiate an instance of the QP class
% Define Objective (f = x*H*x + c*x):
myQP.H = 2*[1 0;
            0 1];
myQP.c = -[10 10];

% Define linear constraints (Ax <= b):
A =    [2    5;   % constraint 1
        1   -2.5;   % constraint 2
        5.2    2.1;   % constraint 3
         -1     0;     % Limit on x1
         0     -1];    % Limit on x2
b =    [ 20.5 ;       % constraint 1
         -5   ;       % constraint 2
          15   ;       % constraint 3
          0   ;     % Limit on x1
          0   ];    % Limit on x2
myQP.set_Ab(A,b)      % Add constraints to your QP object

% Define range (where to plot / what x values to show):
myQP.Range_x1( -0.5,  5.5) % From x1 = -1.1 to x1 = 5.5
myQP.Range_x2( -0.5,  6.1) % From x2 = -0.5 to x2 = 6.1

% Define levels at which to draw contour lines of the objective (optional)
myQP.levels = -30:3:10; % (Don't set this if you want MATLAB to choose them for you)
% myQP.levels = []; % OR set it to an empty array to make MATLAB choose for you

% Plot your QP:
myQP.plot()


%% Plot without constraints

% Three options:
myQP.toggleConstraits();   % Toggles constraints on and off
myQP.toggleConstraits(1);  % Turns constraints on
myQP.toggleConstraits(0);  % Turns constraints off

myQP.plot()


%% Plot constaints and infeasible regions

myQP.toggleConstraits(1);  % Turn constraints back on
myQP.toggleHulls(1);       % Turn on infeasible hulls

%myQP.toggleObjective(0);   % Try turning off objective contours

myQP.plot()


%% Style your plot

% Constraints on
myQP.toggleConstraits(1)

% ..and hulls off
myQP.toggleHulls(0)


%%%%%% Style the objective contours
myQP.Objective.DisplayName = 'Sweetness of my Smoothie';  % Define legend entry
myQP.Objective.LineStyle   = '--';                        % Define countour line syle (dashed)
myQP.Objective.LineWidth   = 1.5;                         % Define contour line thickness


%%%%%% Style the constraints
% Constraint 1:
i = 1;
myQP.Constraints(i).DisplayName = 'Calorie Limit';     % Define legend entry
myQP.Constraints(i).Color       = [0.466 0.674 0.188]; % Define color of constraint line (green)
myQP.Constraints(i).LineStyle   = '-';                 % Define line style (solid)
myQP.Constraints(i).LineWidth   = 2;                   % Define contour line thickness

% Constraint 2:
i = 2;
myQP.Constraints(i).DisplayName = 'Bitterness Limit';  % Define legend entry
myQP.Constraints(i).Color       = [0.635 0.078 0.184]; % Define color of constraint line (red)
myQP.Constraints(i).LineStyle   = '-';                 % Define line style (solid)
myQP.Constraints(i).LineWidth   = 2;                   % Define contour line thickness

% Constraint 3:
i = 3;
myQP.Constraints(i).DisplayName = 'Price Limit';       % Define legend entry
myQP.Constraints(i).Color       = [0.494 0.184 0.556]; % Define color of constraint line (red)
myQP.Constraints(i).LineStyle   = '-';                 % Define line style (solid)
myQP.Constraints(i).LineWidth   = 2;                   % Define contour line thickness

% Constraint 4 (Limit on x1):
i = 4;
myQP.Constraints(i).DisplayName = 'Apple Limit';       % Define legend entry
myQP.Constraints(i).Color       = 'b';                 % Define color of constraint line (red)
myQP.Constraints(i).LineStyle   = ':';                 % Define line style (solid)
myQP.Constraints(i).LineWidth   = 1.5;                 % Define contour line thickness

% Constraint 5 (Limit on x2):
i = 5;
myQP.Constraints(i).DisplayName = 'Strawberry Limit';       % Define legend entry
myQP.Constraints(i).Color       = 'black';                 % Define color of constraint line (red)
myQP.Constraints(i).LineStyle   = ':';                 % Define line style (solid)
myQP.Constraints(i).LineWidth   = 1.5;                 % Define contour line thickness

%%%%%% Set appropriate labels and title
xlabel(myQP.ax,'Apples [hg]')
ylabel(myQP.ax,'Strawberries [hg]')
title( myQP.ax,'My Optimal Smoothie')


% plot:
myQP.plot()




%% Solve the QP

myQP.solve() % Solve the QP

disp('Solution:')
disp(myQP.solution)
disp('Objective value:')
disp(myQP.objective_value)

%% Solve the problem and plot the optimal point by truning on "toggleOptimalPoint" before plotting

% Three options:
myQP.toggleOptimalPoint();   % Toggles optimal point on and off
myQP.toggleOptimalPoint(0);  % Turns optimal point off
myQP.toggleOptimalPoint(1);  % Turns optimal point on

myQP.plot()



%% Try without constraints (optimal point follows!)
myQP.toggleConstraits(0)
myQP.plot()

myQP.toggleConstraits() % Turn them on again

%% Style The optimal point

myQP.OptimalPoint.DisplayName       = 'My optimal Smoothie';
myQP.OptimalPoint.MarkerSize        = 11;                  % Marker size
myQP.OptimalPoint.Marker            = 'pentagram';         % Five pointed star
myQP.OptimalPoint.MarkerEdgeColor   = [0.850 0.325 0.098]; % Orange edge
myQP.OptimalPoint.MarkerFaceColor   = [0.929 0.694 0.125]; % Yellow fill

myQP.plot()


%% Add other points

% Make some points
p = [2 3;  % point 1 (x1, x2)
     4 2;  % point 2 
     0 1]; % point 3

myQP.addPoints(p') % add points to your QP object (add points as columns)


myQP.togglePoints(1)
myQP.plot()


%% Style your points

% see what field can be set:
disp('These field are available for styling your points:')
myQP.Points


% Style point 1:
myQP.Points(1).DisplayName = "Monday's Smoothie";
myQP.Points(1).MarkerFaceColor = 'r'; % red

% Style point 2:
myQP.Points(2).DisplayName = "Tuesdays's Smoothie";
myQP.Points(2).MarkerSize = 12;

% Style point 3:
myQP.Points(3).MarkerEdgeColor = 'k'; % black
myQP.Points(3).Marker = 'd'; % diamond shape


% Update figure:
myQP.plot()

%% Clear points and add new ones

myQP.clearPoints()

p = [2.1 3.6;  % point 1 (x1, x2)
     4.1 2.8;  % point 2 
     0.9 1.4]; % point 3
myQP.addPoints(p')

myQP.Points(1).DisplayName = "Eric's Smoothie";
myQP.Points(2).DisplayName = "Fiona's Smoothie";
myQP.Points(2).MarkerFaceColor = 'r';
myQP.Points(3).DisplayName = "Carl's Smoothie";
myQP.Points(3).MarkerFaceColor = 'b';

myQP.plot()




