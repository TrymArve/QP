classdef QP < handle

    properties(Access = public)
        resolution (1,1) {mustBePositive,mustBeReal} = 0.1;
        H (2,2) double {mustBeReal} = [0 0; 0 0];
        c (2,1) double {mustBeReal} = [0;0];
        levels (:,1) double {mustBeReal} = [];
        Limits (2,2) double {mustBeReal} = [0 inf; 0 inf]; % [x1_lower x1_upper;  x2_lower x2_upper]
        x0 (2,1) double {mustBeReal} = [0; 0]; % initial guess for optimization algorithm (when using 'active-set')

        fig (1,1);
        ax (1,1);
        x1_label (1,1) string = "x_1";
        x2_label (1,1) string = "x_2";
        Constraints (1,:) struct;
        Objective (1,1) struct = struct('DisplayName','Objective Function','LineStyle','-','LineWidth',0.5);
        OptimalPoint (1,1) struct = struct('DisplayName','Optimal Point','MarkerSize',10,'Marker','hexagram','MarkerEdgeColor',[0 0.4470 0.7410],'MarkerFaceColor',[1 0.5478 0.8196]);
        Points (1,:) struct = struct('DisplayName',{},'MarkerSize',{},'Marker',{},'MarkerEdgeColor',{},'MarkerFaceColor',{});
        options = optimoptions('quadprog','Display','none');
        Hull (1,:) struct = struct('Color',[],'Opacity',[]);
    end

    properties(Access = private)
        % variables
        X1_mesh;
        X2_mesh;
        leg (1,1) struct;
        nc (1,1) double = 0;
        tempIteration (2,1) double {mustBeReal};


        %Flags
        printConstraints (1,1) {mustBeNumericOrLogical} = true;
        printOpt (1,1) {mustBeNumericOrLogical} = false;
        printPoints (1,1) {mustBeNumericOrLogical} = false;
        printLegend (1,1) {mustBeNumericOrLogical} = true;
        printHulls (1,1) {mustBeNumericOrLogical} = false;
        printObjective (1,1) {mustBeNumericOrLogical} = true;
        includeLimits (2,2) {mustBeNumericOrLogical} = [false, false;
                                                        false, false];
        printMaxIterExc (1,1) {mustBeNumericOrLogical} = true;
        stopIterations (1,1) {mustBeNumericOrLogical} = false;



        % base settings
        base_constraint (1,1) struct = struct('DisplayName',[],'LineStyle','-','LineWidth',2,'Color',[0.4 0.4 0.4]);
        base_point (1,1) struct = struct('DisplayName','Point','MarkerSize',6.5,'Marker','o','MarkerEdgeColor',[0 0.4470 0.7410],'MarkerFaceColor',[0.466 0.674 0.188]);
        defualt_constraints_name (1,1) string = "Constraint";
        base_hull (1,1) struct = struct('Color',[0.635 0.078 0.184],'Opacity',0.1)
        hulls (1,:) cell = {};
        Colors (1,:) cell = {[0.6350    0.0780    0.1840], [0    0.4470    0.7410], [0.4660    0.6740    0.1880], [0.9290    0.6940    0.1250], [0.4940    0.1840    0.5560], [0.8500    0.3250    0.0980], [0.3010    0.7450    0.9330], [0.9686    0.4980    0.7451]};
    end

    properties(SetAccess = private, GetAccess = public)
        Name (1,1) string;
        x1_range (1,:) = 0:0.1:5;
        x2_range (1,:) = 0:0.1:5;
        solution (:,1) double;
        objective_value (1,1) double;
        exitflag;
        output;
        lagrange_multipliers;
        A (:,2) double {mustBeReal} = [4     -3;     % constraint 1
                                       4.8   -1.5;   % constraint 2
                                       1      1];    % constraint 3
        b (:,1) double {mustBeReal} =  [  0;        % constraint 1
                                          0;        % constraint 2
                                          5];       % constraint 3

        Iterations (2,:) double {mustBeReal} = [;];
        points (1,:) cell = {};
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
            QP.setDefaultConstraints();
            QP.setDefaultHulls();
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
                QP.Constraints((length(QP.Constraints)+1):QP.nc) = QP.base_constraint;
            end
            QP.setDefaultConstraints();
            QP.setDefaultHulls();
        end

        function[] = algAS(QP)
            QP.options.Algorithm = 'active-set';
        end

        function[] = algIP(QP)
            QP.options.Algorithm = 'interior-point-convex';
        end
        
        function[] = toggleConstraits(QP,input)
            if nargin > 1
                QP.printConstraints = input;
            else
                QP.printConstraints = ~QP.printConstraints;
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
        
        function[] = toggleLegend(QP,input)
            if nargin > 1
                QP.printLegend = input;
            else
                QP.printLegend = ~QP.printLegend;
            end
        end

        function[] = toggleHulls(QP,input)
            if nargin > 1
                QP.printHulls = input;
            else
                QP.printHulls = ~QP.printHulls;
            end
        end

        function[] = toggleObjective(QP,input)
            if nargin > 1
                QP.printObjective = input;
            else
                QP.printObjective = ~QP.printObjective;
            end
        end
        
        function[] = toggleLimits(QP,input)
            if size(input,1) == 1 && size(input,2) == 1
                QP.includeLimits(:,:) = input;
            elseif size(input,1) == 2 && size(input,2) == 2
                QP.includeLimits(1,1) = input(1,1);
                QP.includeLimits(1,2) = input(1,2);
                QP.includeLimits(2,1) = input(2,1);
                QP.includeLimits(2,2) = input(2,2);
            else
                disp('toggleLimits: input must have size (1,1) or (2,2).')
            end
        end
        
        function[] = plot(QP)
            cla(QP.ax);
            figure(QP.fig);
            QP.setMesh();
            axis(QP.ax,[QP.x1_range(1) QP.x1_range(end) QP.x2_range(1) QP.x2_range(end)])
            if QP.printObjective == true
                QP.plotObjective();
            end
            if any(QP.includeLimits,"all")
                QP.plotLimits();
            end
            if QP.printConstraints == true
                QP.plotConstraints();
            end
            if QP.printPoints == true
                QP.plotPoints();
            end
            if QP.printOpt == true
                QP.solve();
                if QP.exitflag == 1
                    QP.plotOptimalPoint();
                end
            end
            legend()
            QP.fig.Visible = 'on';
        end
    
        function[] = plotIterations(QP)
            

            QP.solveIterations();
            if QP.stopIterations
                QP.stopIterations = false;
                disp('Cannot plot iterations')
                return;
            end

            nPrevPoints = length(QP.points);

            QP.addPoints(QP.Iterations);
            
            I = (1:size(QP.Iterations,2)) + nPrevPoints;
            color1 = [0.3010    0.7450    0.9330]; % cyan
            color2 = [0.4660    0.6740    0.1880]; % green
            color3 = [0.9290    0.6940    0.1250]; % yellow
            color4 = [0.6350    0.0780    0.1840]; % red
            I1 = I(1);
            I4 = I(end);
            I2 =   (I4-I1)/3 + I1;
            I3 = 2*(I4-I1)/3 + I1;
            for i = I
                QP.Points(i).DisplayName = ['Iter ' num2str(i-1)];
                color = interp1([I1,I2,I3,I4],[color1; color2; color3; color4], i);
                QP.Points(i).MarkerFaceColor = color;
            end
            
            % Store setting
            printPoints = QP.printPoints;
            printOpt = QP.printOpt;

            % set settings
            QP.printPoints = true;
            QP.printOpt = true;

            % plot
            QP.plot()

            % Restore settings
            QP.printOpt = printOpt;
            QP.printPoints = printPoints;
        end
        
        function[] = solveIterations(QP)

            % Check that solution exists
            QP.solve();
            if QP.exitflag ~= 1 || all(~QP.H,"all")
                QP.stopIterations = true;
                disp('Cannot solve for iterations')
                return;
            end
            nIter = QP.output.iterations;

            maxIterations = QP.options.MaxIterations;
            displaySetting = QP.options.Display;
            QP.printMaxIterExc = false;

            % find initial guess: (not definable via x0 for all algorithms)
            QP.options.MaxIterations = 0;
            QP.solve();
            QP.Iterations = QP.tempIteration;
            
            for i = 1:nIter-1
                QP.options.MaxIterations = i;
                QP.solve();
                QP.Iterations(:,end+1) = QP.tempIteration;
            end

            if isnumeric(maxIterations)
                QP.options.MaxIterations = maxIterations;
            else
                QP.options = resetoptions(QP.options,'MaxIterations');
            end
            QP.options.Display = displaySetting;
        end
        
        function[] = solve(QP)

            % Inequalities
            if QP.printConstraints == true
                A = QP.A; %#ok<PROP> 
                b = QP.b; %#ok<PROP> 
            else
                A = []; %#ok<PROP> 
                b = []; %#ok<PROP> 
            end

            % Limits
            lb = [];
            ub = [];
            if any(QP.includeLimits(:,1))
                lb = -inf(2,1);
                lb(QP.includeLimits(:,1)) = QP.Limits(QP.includeLimits(:,1),1);
            end
            if any(QP.includeLimits(:,2))
                ub = inf(2,1);
                ub(QP.includeLimits(:,2)) = QP.Limits(QP.includeLimits(:,2),2);
            end

            % Might include later:
            Aeq = []; 
            beq = [];

            % Solve:
            if any(QP.H)
                [solution, QP.objective_value, QP.exitflag, QP.output, QP.lagrange_multipliers] = quadprog(2*QP.H, QP.c, A, b, Aeq,beq,lb,ub,QP.x0, QP.options); %#ok<PROP> 
            else
                options = optimoptions("linprog",QP.options);
                [solution, objective_value, QP.exitflag, QP.output, QP.lagrange_multipliers] = linprog(QP.c, A, b, Aeq,beq,lb,ub, options); %#ok<PROP> 
            end
            switch QP.exitflag
                case 1
                    QP.solution = solution; %#ok<*PROP> 
                case 0
                    if QP.printMaxIterExc
                        disp('Maximum Iterations Exceeded...')
                    else
                        QP.tempIteration = solution;
                    end
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
    
        function[] = savePDF(QP)
            set(QP.fig,'Units','inches');
            screenposition = get(QP.fig,'Position');
            set(QP.fig,...
                'PaperPosition',[0 0 screenposition(3:4)],...
                'PaperSize',[screenposition(3:4)]);
            print(QP.Name,'-dpdf','-bestfit')
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
            frame = [x1_low x1_high x1_high x1_low;
                     x2_low x2_low  x2_high x2_high];
            b_frame = QP.A*frame;
            
            % Find where constraints touch the frame:
            Right   = all([x2_low <  f_2(x1_high), f_2(x1_high) <= x2_high],2);
            Left    = all([x2_low <= f_2(x1_low) , f_2(x1_low)  <  x2_high],2);
            Top     = all([x1_low <= f_1(x2_high), f_1(x2_high) <  x1_high],2);
            Bottom  = all([x1_low <  f_1(x2_low) , f_1(x2_low)  <= x1_high],2);
            Inframe = (Right + Left + Top + Bottom >= 2);

            % Plot the constraints that appear in range:
            p = [];
            for i = 1:QP.nc
                if Inframe(i)
                    x = [];
                    if Bottom(i)
                        f1 = f_1(x2_low);
                        x(:,end+1) = [f1(i); x2_low]; %#ok<*AGROW> 
                    end
                    if Right(i)
                        f2 = f_2(x1_high);
                        x(:,end+1) = [x1_high; f2(i)];
                    end
                    if Top(i)
                        f1 = f_1(x2_high);
                        x(:,end+1) = [f1(i); x2_high];
                    end
                    if Left(i)
                        f2 = f_2(x1_low);
                        x(:,end+1) = [x1_low; f2(i)];
                    end
                    if QP.printHulls == true
                        plotHull();
                    end
                    p(end+1) = plot(QP.ax,x(1,1:2)',x(2,1:2)','LineStyle',QP.Constraints(i).LineStyle,'LineWidth',QP.Constraints(i).LineWidth,'Color',QP.Constraints(i).Color,'DisplayName',QP.Constraints(i).DisplayName);
                end
            end

            for i = 1:length(p)
                uistack(p(i),'top');
            end
            
            function[] = plotHull()
                inhull = (b_frame(i,:) > QP.b(i));
                frameHull = frame(:,inhull);
                hull = [frameHull x];
                hull_ind = convhull(hull(1,:)',hull(2,:)');
                FILL = fill(QP.ax,hull(1,hull_ind),hull(2,hull_ind),QP.Hull(i).Color,'FaceAlpha',QP.Hull(i).Opacity,'LineStyle','none');
                FILL.Annotation.LegendInformation.IconDisplayStyle = 'off';
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
    
        function[] = plotLimits(QP)
            x1_low  = QP.x1_range(1);
            x1_high = QP.x1_range(end);
            x2_low  = QP.x2_range(1);
            x2_high = QP.x2_range(end);

            color = [0.494 0.184 0.556];
            alpha = 0.15;

            % Lower Limit on x1:
            if QP.includeLimits(1,1) && QP.Limits(1,1) > x1_low && QP.Limits(1,1) < x1_high
                hull = [x1_low QP.Limits(1,1) QP.Limits(1,1)  x1_low;
                        x2_low    x2_low         x2_high      x2_high];
                FILL = fill(QP.ax,hull(1,:),hull(2,:),color,'FaceAlpha',alpha,'LineStyle','none');
                FILL.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end

            % Lower Limit on x2:
            if QP.includeLimits(2,1) && QP.Limits(2,1) > x2_low && QP.Limits(2,1) < x2_high
                hull = [x1_low    x1_high      x1_high             x1_low;
                        x2_low    x2_low    QP.Limits(2,1)     QP.Limits(2,1)];
                FILL = fill(QP.ax,hull(1,:),hull(2,:),color,'FaceAlpha',alpha,'LineStyle','none');
                FILL.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end

            % Upper Limit on x1:
            if QP.includeLimits(1,2) && QP.Limits(1,2) > x1_low && QP.Limits(1,2) < x1_high
                hull = [QP.Limits(1,2) x1_high   x1_high    QP.Limits(1,2) ;
                            x2_low     x2_low    x2_high       x2_high];
                FILL = fill(QP.ax,hull(1,:),hull(2,:),color,'FaceAlpha',alpha,'LineStyle','none');
                FILL.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end

            % Upper Limit on x2:
            if QP.includeLimits(2,2) && QP.Limits(2,2) > x2_low && QP.Limits(2,2) < x2_high
                hull = [    x1_low            x1_high       x1_high x1_low;
                        QP.Limits(2,2)     QP.Limits(2,2)   x2_high x2_high];
                FILL = fill(QP.ax,hull(1,:),hull(2,:),color,'FaceAlpha',alpha,'LineStyle','none');
                FILL.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
        end
        
        function[] = setDefaultConstraints(QP)
            for i = 1:QP.nc
                QP.Constraints(i).DisplayName = [char(QP.defualt_constraints_name), ' ', num2str(i)];
                %color = 0.25*[1 1 1]*(i-1)./(QP.nc-1) + 0.65*[1 1 1]*((QP.nc-1)-(i-1))./(QP.nc-1);
                QP.Constraints(i).Color = QP.Colors{i};
            end
        end
   
        function[] = setDefaultHulls(QP)
            for i = 1:QP.nc
                QP.Hull(i).Color = QP.base_hull.Color;
                QP.Hull(i).Opacity = QP.base_hull.Opacity;
            end
        end
    end

end



























