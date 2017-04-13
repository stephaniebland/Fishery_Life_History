%--------------------------------------------------------------------------
% Program by: Stephanie Bland
% April 12, 2017
%--------------------------------------------------------------------------
% Cluster Simulation
%--------------------------------------------------------------------------
% The looping script to run on ACENET clusters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACENET (www.ace-net.ca) provides cluster computing resources for researchers at Dal (and elsewhere).
% Your thesis supervisor will have to get an account before you can, but both are free.
% The process is described in more detail at https://www.ace-net.ca/wiki/Get_an_Account.
%
% If you have never used a cluster before you will want some training.
% There are several classroom and web training sessions scheduled for early May;
% see http://www.ace-net.ca/training/workshops-seminars/ for details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RunCluster(seed_0,simnum,Exper)
    %% Set Seed
    rng(seed_0+simnum)
    
    %% Initial Setup
    beep off
    warning off MATLAB:divideByZero;
    global reprod cont_reprod Effort;
    
    %% Protocol Parameters
    Parameters;
    
    %% Setup
    setup;% creation of a new food web
    
    %% Experimental Parameters
    switch Exper
        case 1
            %% 1st Simulation: Extended_nicheweb + Lifehistory: B_orig & linked
            lifestages_linked=true;
            B0=B_orig;
            Adults_only=0;
        case 2
            %% 2nd Simulation: Extended_nicheweb: B_orig & NOT linked
            lifestages_linked=false;
            B0=B_orig;
            Adults_only=0;
        case 3 
            %% 3rd Simulation: Nicheweb: B_orig=B_orig.*orig.nodes';%(Start with adults only) & NOT linked
            lifestages_linked=false;
            B0=B_orig.*orig.nodes';%Start with adults only. %CAUTION - changes total biomass, consider normalizing so all experiments have same total biomass. Or maybe sum juvenile stages to adult instead.
            Adults_only=1;
    end
            
    %% Simulation
    simulations;
    
    %% Export Data
    name=sprintf('BLANDseed%d_sim%06d_link%d_AdultOnly%d_Exper%d',seed_0,simnum,lifestages_linked,Adults_only,Exper)
    dlmwrite(strcat(name,'.txt'),B);
    
    %% Save A Figure
    figure(1); hold on;
    p=plot(day_t,log10(B),'LineWidth',1);
    [~,~,ind_species]=unique(isfish.*species');
    [~,~,ind_lifestage]=unique(lifestage);
    %colours=get(gca,'colororder');
    colours=parula(sum(orig.isfish)+1);
    %mark={'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'}
    line_lifestage={'-','--',':','-.','-.','-.'};
    for i=1:nichewebsize
        p(i).Color=colours(ind_species(i),1:3);
        %p(i).Marker=char(mark(ind(i)))
        p(i).LineStyle=char(line_lifestage(lifestage(i)));%Youngest lifestage is given same line type as non-fish species
    end
    xlabel('time (1/100 years)'); ylabel('log10 biomass')
    title('Fish Species by colour (invertebrates are all same colour), and lifestage by line type')
    grid on;
    saveas(gcf,name,'png')
    
end






