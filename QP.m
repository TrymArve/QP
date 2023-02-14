classdef QP < handle

    properties(Access = public)
        resolution (1,1) {mustBePositive,mustBeReal} = 0.1;
        H (2,2) double {mustBeReal} = [1 0; 0 1];
        c (1,2) double {mustBeReal} = [0;0];
        levels (:,1) double {mustBeReal} = [];%(0:5)';
        A (:,2) double {mustBeReal} = -[4     -3;     % constraint 1
                                        4.8   -1.5;   % constraint 2
                                        1      1];    % constraint 3;
        b (:,1) double {mustBeReal} = -[  0;        % constraint 1
                                          0;        % constraint 2
                                          5];       % constraint 3;
        fig (1,1);
        ax (1,1);
        x1_label (1,1) string = "x_1";
        x2_label (1,1) string = "x_2";
        Constraints (1,:) struct;
        Objective (1,1) struct = struct('DisplayName','Objective Function','LineStyle','-','LineWidth',0.5);
        OptimalPoint (1,1) struct = struct('DisplayName','Optimal Point','MarkerSize',10,'Marker','hexagram','MarkerEdgeColor',[0 0.4470 0.7410],'MarkerFaceColor',[1 0.5478 0.8196]);
        Points (1,:) struct = struct('DisplayName',{},'MarkerSize',{},'Marker',{},'MarkerEdgeColor',{},'MarkerFaceColor',{});
        options = optimoptions('quadprog','Display','none');
    end

    properties(Access = private)
        Name (1,1) string;
        x1_range (1,:) = 0:0.1:5;
        x2_range (1,:) = 0:0.1:5;
        X1_mesh;
        X2_mesh;
        Constrained (1,1) {mustBeNumericOrLogical} = true;
        printOpt (1,1) {mustBeNumericOrLogical} = false;
        printPoints (1,1) {mustBeNumericOrLogical} = false;
        leg (1,1) struct;
        nc (1,1) double = 3;
        base_constraint (1,1) struct = struct('DisplayName','Constraint','LineStyle','-','LineWidth',2,'Color',[0.4 0.4 0.4]);
        points (1,:) cell = {};
        base_point (1,:) struct = struct('DisplayName','Point','MarkerSize',6.5,'Marker','o','MarkerEdgeColor',[0 0.4470 0.7410],'MarkerFaceColor',[0.466 0.674 0.188]);

    end

    properties(SetAccess = private, GetAccess = public)
        solution (:,1) double;
        objective_value (1,1) double;
        exitflag;
        output;
        lagrange_multipliers;
    end

    methods
        function[QP] = QP(name)
            QP.Name = string(name);
            QP.fig = figure("Name",QP.Name,'visible','on');
            QP.ax = axes(QP.fig);
            title(QP.Name);
            xlabel(QP.x1_label);
            ylabel(QP.x2_label);
            hold on; grid off; axis equal; legend();

            QP.Constraints = QP.base_constraint;
            QP.Constraints(1:QP.nc) = QP.base_constraint;
            for i = 1:QP.nc
                QP.Constraints(i).DisplayName = [QP.Constraints(i).DisplayName, ' ', num2str(i)];
                color = 0.25*[1 1 1]*(i-1)./(QP.nc-1) + 0.65*[1 1 1]*((QP.nc-1)-(i-1))./(QP.nc-1);
                QP.Constraints(i).Color = color;
            end
        end


        function[] = Range_x1(QP,x1_low,x1_high)
            QP.x1_range = x1_low : QP.resolution : x1_high;
        end

        function[] = Range_x2(QP,x2_low,x2_high)
            QP.x2_range = x2_low : QP.resolution : x2_high;
        end

        function[] = set_Ab(QP,A,b)
            if length(b) ~= size(A,1)
                error('ERROR: height of A must be the same as the height of b.')
            end
            QP.A  = A;
            QP.b  = b;
            QP.nc = length(b);
            if length(QP.Constraints) < QP.nc
                QP.Constraints(length(QP.Constraints)+1:QP.nc) = QP.base_constraint;
            end
        end

        function[] = toggleConstraits(QP,input)
            if nargin > 1
                QP.Constrained = input;
            else
                QP.Constrained = ~QP.Constrained;
            end
        end
   
        function[] = toggleOptimalPoint(QP,input)
            if nargin > 1
                QP.printOpt = input;
            else
                QP.printOpt = ~QP.printOpt;
            end
        end
        
        function[] = togglePoints(QP,input)
            if nargin > 1
                QP.printPoints = input;
            else
                QP.printPoints = ~QP.printPoints;
            end
        end
        
        function[] = plot(QP)
            cla(QP.ax);
            QP.setMesh();
            axis(QP.ax,[QP.x1_range(1) QP.x1_range(end) QP.x2_range(1) QP.x2_range(end)])
            QP.plotObjective();
            if QP.Constrained == true
                QP.plotConstraints();
            end
            if QP.printOpt == true
                QP.solve();
                QP.plotOptimalPoint();
            end
            if QP.printPoints == true
                QP.plotPoints();
            end

            legend()
            QP.fig.Visible = 'on';
        end
    
        function[] = solve(QP)
            if QP.Constrained == true
                A = QP.A; %#ok<PROP> 
                b = QP.b; %#ok<PROP> 
            else
                A = []; %#ok<PROP> 
                b = []; %#ok<PROP> 
            end
            [QP.solution, QP.objective_value, QP.exitflag, QP.output, QP.lagrange_multipliers] = quadprog(2*QP.H, QP.c, A, b, [],[],[],[],[], QP.options);
            switch QP.exitflag
                case 1
                case 0
                    disp('Maximum Iterations Exceeded...')
                case -2
                    disp('Problem is infeasible... Or, for "interior-point-convex", the step size was smaller than options.StepTolerance, but constraints were not satisfied.')
                case -3
                    disp('Problem is Unbounded...')
                otherwise
                    disp('OOPS, something went wrong...')
                    disp('QP.output:')
                    disp(QP.output)
            end
        end

        function[] = addPoints(QP,p)
            for i = 1:size(p,2)
                QP.points{end+1} = p(:,i);
                QP.Points(end+1) = QP.base_point;
                QP.Points(end).DisplayName = [QP.Points(end).DisplayName, ' ',num2str(length(QP.points))];
            end
        end
    
        function[] = clearPoints(QP)
            QP.points = {};
            QP.Points = struct('DisplayName',{},'MarkerSize',{},'Marker',{},'MarkerEdgeColor',{},'MarkerFaceColor',{});
        end
    end




    methods(Access = private)
        function[] = setMesh(QP)
            [QP.X1_mesh,QP.X2_mesh] = meshgrid(QP.x1_range,QP.x2_range);
        end

        function[f] = f(QP,x1,x2)
            f = QP.H(1,1).*x1.^2 + QP.H(2,2).*x2.^2 + (QP.H(1,2) + QP.H(2,1)).*x1.*x2 + QP.c(1).*x1 + QP.c(2).*x2;
        end
            
        function[F] = F(QP)
            F = QP.f(QP.X1_mesh,QP.X2_mesh);
        end

        function[] = plotObjective(QP)
            if isempty(QP.levels)
                contour(QP.ax,QP.X1_mesh,QP.X2_mesh,QP.F(),'DisplayName',QP.Objective.DisplayName,'LineStyle',QP.Objective.LineStyle,'LineWidth',QP.Objective.LineWidth);
            else
                contour(QP.ax,QP.X1_mesh,QP.X2_mesh,QP.F(),QP.levels,'DisplayName',QP.Objective.DisplayName,'LineStyle',QP.Objective.LineStyle,'LineWidth',QP.Objective.LineWidth);
            end
        end

        function[] = plotConstraints(QP)
            % Solve for x1 and x2:
            f_1 = @(x2) (-QP.A(:,2).*x2+QP.b)./QP.A(:,1);  % x1 = f_1(x2)
            f_2 = @(x1) (-QP.A(:,1).*x1+QP.b)./QP.A(:,2);  % x2 = f_2(x1)


            % Find points in range:
            x1_low  = QP.x1_range(1);
            x1_high = QP.x1_range(end);
            x2_low  = QP.x2_range(1);
            x2_high = QP.x2_range(end);
            
            % Find where constraints touch the frame:
            Right   = all([x2_low <  f_2(x1_high), f_2(x1_high) <= x2_high],2);
            Left    = all([x2_low <= f_2(x1_low) , f_2(x1_low)  <  x2_high],2);
            Top     = all([x1_low <= f_1(x2_high), f_1(x2_high) <  x1_high],2);
            Bottom  = all([x1_low <  f_1(x2_low) , f_1(x2_low)  <= x1_high],2);
            Inframe = (Right + Left + Top + Bottom >= 2);

            % Plot the constraints that appear in range:
            for i = 1:QP.nc
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
                            x(:,end+1) = [f1(i); x2_low]; %#ok<*AGROW> 
                        end
                    plot(QP.ax,x(1,1:2)',x(2,1:2)','LineStyle',QP.Constraints(i).LineStyle,'LineWidth',QP.Constraints(i).LineWidth,'Color',QP.Constraints(i).Color,'DisplayName',QP.Constraints(i).DisplayName)
                end
            end
        end

        function[] = plotOptimalPoint(QP)
            plot(QP.ax,QP.solution(1),QP.solution(2),'DisplayName',QP.OptimalPoint.DisplayName,'LineStyle','none','MarkerSize',QP.OptimalPoint.MarkerSize,'Marker',QP.OptimalPoint.Marker,'MarkerEdgeColor',QP.OptimalPoint.MarkerEdgeColor,'MarkerFaceColor',QP.OptimalPoint.MarkerFaceColor)
        end
    
        function[] = plotPoints(QP)
            for i = 1:length(QP.points)
                plot(QP.ax,QP.points{i}(1),QP.points{i}(2),'DisplayName',QP.Points(i).DisplayName,'LineStyle','none','MarkerSize',QP.Points(i).MarkerSize,'Marker',QP.Points(i).Marker,'MarkerEdgeColor',QP.Points(i).MarkerEdgeColor,'MarkerFaceColor',QP.Points(i).MarkerFaceColor)
            end
        end
    end

end



























