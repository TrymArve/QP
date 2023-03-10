% Example 1

% You throw a party, and want to make it super fun for all your guests, but
% you don't have a large budget, so want out how to make the best party
% with the amount of money you have.

% You are buying Coca Cola and Mountain Dew for your party.

% Let x1 be how many liters of Coca Cola you buy,
% and x2 be how many liters of Mounatin Dew you buy.

% How much Mountain Dew and how much Coca Cola should you buy?







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;clear;close all;
myQP = QP('Best Possible Party');


% Define how fun a party is based on how much Coca Cola and Mountain Dew you buy:
% (f = x*H*x + c*x)
myQP.H =  3*[2 0;
             0 1];
myQP.c = -10*[2 5];



% You cannot buy less then 0 liters of soda (Ax <= b)
% And you know a friend that you already know is going to want Coca Cola,
% so you want to buy at least 1.5 liters of Coca Cola:
A =    [-1     0;     % Limit on x1
         0    -1];    % Limit on x2
b =   -[ 1.5 ;     % Limit on x1
          0 ];     % Limit on x2



% You also cannot afford to spend more than 100 NOK
% Coca Cola     - 28.5 NOK/liter
% Mountatin Dew - 24.6 NOK/liter
A = [     A      ;
      28.5  24.6];
b = [ b  ;
     100];

myQP.set_Ab(A,b);




%%%%%%% Style QP appropriately
myQP.Objective.DisplayName = 'Funness of Party';

myQP.Constraints(1).DisplayName = 'Minimum liters of Coca Colca';
myQP.Constraints(1).Color = 'k';
myQP.Constraints(1).LineStyle = '--';

myQP.Constraints(2).DisplayName = 'Minimum liters of Mountain Dew';
myQP.Constraints(2).Color = 'g';
myQP.Constraints(2).LineStyle = '--';

myQP.Constraints(3).DisplayName = '100 NOK';
myQP.Constraints(3).Color = 'r';
myQP.Constraints(3).LineStyle = '-';

xlabel('Coca Cola [liters]')
ylabel('Mountain Dew [liters]')

% Define range (where to plot / what x values to show):
myQP.Range_x1( 0,  5.5) % From x1 = 0 to x1 = 5.5
myQP.Range_x2( 0,  6.1) % From x2 = 0 to x2 = 6.1




%%%%%%% Various Settings:
myQP.toggleHulls(1)          % Show red where the region is infeasible
myQP.toggleOptimalPoint(1)   % Find and display optimal point



%%%%%% Plot the QP
myQP.plot()






















