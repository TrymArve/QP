%% Bake sale
clc;clear;close all;

%{ You are baking cookies and cake for a bake sale.
%  You have 10 bars of chocolate, and have to decide how many cakes and cookies to make
%  in order to spend the chocolate in the best possible way, to make as much money as possible.
%  A chocolate bar is 200g each.  
%  A cookie is sold for 15kr and a slice of cake is sold for 10kr.
%  A cookie uses 1.1hg of cookie dough, and a slice of cake needs 0.8 cake
%  dough
%  Cookie dough requires 10g of chocolate per hg of dough.
%  Cake dough requires 32g of chocolate per hg of dough.
%  You only have enough topping to make 30hg of cake.
%  You only have enough butter to make 35hg of cookie cough.
%  Each hg of cookie dough requires 30g of sugar, and each hg of cake dough
%  requires 16g of sugar, and you only have 1.8kg of sugar.
% 
% 
% 
% }


myQP = QP('Optimal Bake Sale'); % Instansiate an instance of the QP class

% x1 = How much cookie dough to make [hg]
% x2 = How much cake dough to make [hg]

% Profit (negative)
myQP.c = -[15/1.1;  10/0.8];

% Define linear constraints (Ax <= b):
A =    [15      32;      % Total use of chocolate [g]
        30       16];     % Total use of sugar [g]
b =    [ 1800;           % Cannot use more than 200g of chocolate
         1700];          % Cannot use more than 100g of sugar

x1_min = 0;    % Cannot make negative cookie dough
x1_max = 50;   % Only have enough butter for 30hg of cookie dough
x2_min = 0;    % Cannot make negative cake dough
x2_max = 50;   % Only have enough topping for 35hg of cake dough

myQP.Limits = [x1_min x1_max; x2_min x2_max]; % Set limits
myQP.toggleLimits(1)  % Turn on limits

myQP.set_Ab(A,b)      % Add constraints to your QP object

% Define range (where to plot / what x values to show):
myQP.Range_x1( -10,  70) % From x1 = -0.5 to x1 = 5.5
myQP.Range_x2( -10,  70) % From x2 = -0.5 to x2 = 6.1


myQP.toggleHulls(1);         % Turn on infeasible hulls
myQP.toggleOptimalPoint(1);


%%%%%% Style the objective contours
myQP.Objective.DisplayName = 'Profit';  % Define legend entry



%%%%%% Style the constraints
% Constraint 1:
i = 1;
myQP.Constraints(i).DisplayName = '10 chocolate bars';    % Define legend entry
myQP.Constraints(i).Color       = [0.5451 0.2706 0.0745]; % Define color of constraint line (brown)
myQP.Constraints(i).LineWidth   = 2;                      % Define contour line thickness

% Constraint 2:
i = 2;
myQP.Constraints(i).DisplayName = 'Use all the sugar';  % Define legend entry
myQP.Constraints(i).Color       = [0.301 0.745 0.9330]; % Define color of constraint line (red)
myQP.Constraints(i).LineWidth   = 2;                    % Define contour line thickness



%%%%%% Set appropriate labels and title
xlabel(myQP.ax,'Cookie dough [hg]')
ylabel(myQP.ax,'Cake dough [hg]')


myQP.OptimalPoint.MarkerFaceColor = 'y';
myQP.OptimalPoint.DisplayName = 'Optimal Cookie and Cake combo';

% plot:
myQP.plot

%% Save as PDF

myQP.savePDF()