% Plotting a QP
%   - Contours/Level curves of the objective function
%   - Contours/Level curves of the constraints (c(x) = 0)
%   - Optimal points


% Use F5 to run the enitre scrip in one go, or
% use 'ctrl + enter' to run only the current section (defined by "%%").
% Use 'ctrl + shift + enter' to run section and proceed to the next section




%% Start from scratch
clc        % clear the command window
clear      % clear the workspace (where you variables are defined)
close all  % close all figures





%% Define region to plot:

% Resolution of the contours: (interval between the points that make up the contour lines)
resolution = 0.1;

% x1 interval:
x1_low  = -1.5;  
x1_high = 5.5;
x1_array = x1_low : resolution : x1_high;
% x2 interval:
x2_low  = -1.5;  
x2_high = 5.5;
x2_array = x2_low : resolution : x2_high;

% Now make a 'meshgrid' (https://se.mathworks.com/help/matlab/ref/meshgrid.html):
[X1_mesh,X2_mesh] = meshgrid(x1_array,x2_array);




%% Define objective function:

% Make an 'anonymous' function:
f = @(x1,x2) (x1 - 1).^2 + (x2 - 2.5).^2; %(remember to use the point: .^ (elementwise operation))

% This anonynous function can be used to evaluate the objective
% function at f.ex: x1 = 2.1 and x2 = 4.3, and storing it in the variable "obj":

%   obj = f(2.1,4.3)

% or evaluate the objective function at every point in the meshgrid:
F = f(X1_mesh,X2_mesh);





%% Define the levels at which to plot the levelcurves of the objective function:

levels = 0:4:32;   % This creates a row-vector of levels at which to plot the level curves
levels = levels';  % We use a ' to transpose the vector into a column-vector.





%% Create a figure
close all; clc
% There is a datatype/class, like "single", "double", "char", "string",
% "struct", etc., called "figure". We will use this class to make figures.

QP_figure = figure('Name','QP plot'); % Create a variable of class "Figure", and simultaneously assign the value: "QP plot" to the Name-property.
% The "Figure" object can be thought of as the window that pops up.
% The figure then needs to contain a sub-variable called "axes", which is
% another datatype. Think of the axes object as the canvas inside of the
% window, that you draw/plot in.

% Create an "axes" variable inside the figure object:
axes(QP_figure)
% (you may now find the newly created axes object in "QP_figure.Children(1)")

% Give the axes object a handle, so its easier to refere to it:
QP_axes = QP_figure.Children(1);

% Give the axes object a title:
myTitle = 'Quadratic Program Visualized';
title(QP_axes,myTitle) % Add to current axes 

% Give labels to the axes:
xlabel('x_1'); ylabel('x_2')
%xlabel('x_1','interpreter','latex') % To specify that a latex interpreter of the text shuld be used

% Some properties of the newly created axes object:
hold on    % graphs are not deleted when new graphs are plotted
grid off   % grid lines are not present in the figure (this is default)
axis equal % Define the x- and y- axis to be equal
% (there functions automatically applies the various properties to the 'current' axes. The 'current' axes is the axes object you last created/edited)


%%%%% Placement and size of figure (window):
% (if you have some form of automatic snapping of windows active, then the posistion property of the figure will be overridden)

% Units:
QP_figure.Units = 'centimeters'; % set the units of the figure to centimeters. (Default is 'pixels')

% Position/size on screen:
LowerLeftCorner = [3,2]; % Position of the lower left corner of the figure window will be 3cm right to-, and 2cm above the lower left corner of the screen
width = 15;    % The figure will be 11cm wide
height = 15;   % The figure will be 11cm tall
QP_figure.Position = [LowerLeftCorner, width, height];


%% Plot the contours of the objective function

% clear the axes object:
cla % (deletes any lines/points already drawn in the axes object)
clc
% Plot the contours of f at "levels" in the axes object in the figure:
contour(QP_axes,X1_mesh,X2_mesh,F,levels,'DisplayName','Objective Function')

legend() % Add a legend that displays the "DisplayName"


% Plot the constraints


%%%%%% Find what points are in the plotting range:

% Define linear constraints:
A = -[4     -3;    % constraint 1
     4.8   -1.5;   % constraint 2
     1      1];    % constraint 3

b = -[  0;        % constraint 1
        0;        % constraint 2
        5];       % constraint 3

% Solve for x1 and x2:
f_1 = @(x2) (-A(:,2).*x2+b)./A(:,1);  % x1 = f_1(x2)
f_2 = @(x1) (-A(:,1).*x1+b)./A(:,2);  % x2 = f_2(x1)

% Find where constraints touch the frame:
Right   = all([x2_low <  f_2(x1_high), f_2(x1_high) <= x2_high],2);
Left    = all([x2_low <= f_2(x1_low) , f_2(x1_low)  <  x2_high],2);
Top     = all([x1_low <= f_1(x2_high), f_1(x2_high) <  x1_high],2);
Bottom  = all([x1_low <  f_1(x2_low) , f_1(x2_low)  <= x1_high],2);
Inframe = (Right + Left + Top + Bottom >= 2);

%%%%%% Plot the constraints:

% Properties:
LineWidth = [2,3,4];                   % First cinstraint will be 2 pixles wide, second will be 3 px, and thrid 1px.
LineStyle = {'-.','-','--'};           % Choose from: '-', ':', '--', '.-'
RGB = {[0.4000    0.4000    0.4000];   % Constraint 1 is grey
       [0.6350    0.0780    0.1840];   % Constraint 2 is red
       [0.4660    0.6740    0.1880]};  % Constraint 3 is green

% Plot the constraints that appear in range:
for i = 1:length(b)
    if Inframe(i)
        x = [];
            if Right(i)
                f2 = f_2(x1_high);
                x(:,end+1) = [x1_high; f2(i)];
            end
            if Left(i)
                f2 = f_2(x1_low);
                x(:,end+1) = [x1_low; f2(i)];
            end
            if Top(i)
                f1 = f_1(x2_high);
                x(:,end+1) = [f1(i); x2_high];
            end
            if Bottom(i)
                f1 = f_1(x2_low);
                x(:,end+1) = [f1(i); x2_low]; %#ok<*SAGROW> 
            end
        plot(QP_axes,x(1,1:2)',x(2,1:2)','LineStyle',LineStyle{i},'LineWidth',LineWidth(i),'Color',RGB{i},'DisplayName',['Constraint ',num2str(i)])
    end
end

legend()




%% Find Solution to QP

% NOTE: the objective function can be written as:
% f = [x1 x2]*[1 0 ; 0 1]*[x1; x2] - [2 5]*[x;x2];

% Define the QP problem
H = 2*[1 0; 0 1];
f = [-2 -5];
%f = [-8 -2]
% A and b are defined above

% Solve the QP problem
[x, fval] = quadprog(H, f, A, b);
disp('Solution: x = ');disp(x)
disp('Objective value:');disp(fval)

%%%%%% Plot solution

% plot x*
plot(QP_axes,x(1),x(2),'Marker','hexagram','MarkerEdgeColor',[0 0.4470 0.7410],'MarkerFaceColor',[1 0.5478 0.8196],'MarkerSize',10,'LineStyle','none','DisplayName','Optimal Point')
legend()

% Add values to the title:
newTitle = [myTitle, ',   x_{opt} = [',num2str(x(1)),'; ',num2str(x(2)),'],   f(x_{opt}) = ',num2str(fval)];
title(newTitle)




%% Write text in figure

myText = 'Best constrained solution';      % The text to write
whereText = x - 0.4*[3; 1]; % Where to write the text. Write it just next to the solution x.

text(QP_axes,whereText(1),whereText(2),myText,'FontSize',12,'BackgroundColor',[0.6990 1 0.2820],'Color','k') % (k means black)











