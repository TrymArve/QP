
if ~isempty(U)
    close all
    F = figure;
    ax = axes(F);
    
    
    subplot(2,1,1);hold on; grid on; title(Title)
    for i = 1:nu
        stairs(0:N,[U(i,:) U(i,end)],'DisplayName',['u',num2str(i)],'LineWidth',2,'Color',GetColorCode('i'))
    end
    ylabel('Input value')
    xlabel('Time')
    legend
    
    if exist('X','var')
        subplot(2,1,2);hold on; grid on
        for i = 1:nx
            plot(0:N,[x0(i) X(i,:)],'DisplayName',['x',num2str(i)],'LineWidth',2,'Color',GetColorCode(i))
        end
        ylabel('State value')
        xlabel('Time')
        legend
    end
end