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
    
    %% Name for Exporting Data
    name=sprintf('BLANDseed%04d_sim%06d_link%d_AdultOnly%d_Exper%d',seed_0,simnum,lifestages_linked,Adults_only,Exper)
    
    %% Time Series Simulation (& Export TS dependent Properties)
    simulations;
    
    %% Export Web Properties:
    basal_ls=sum(nicheweb,2)==0;
    export_int=[T1 isfish species' orig.nodes' lifestage' basal_ls];
    export_real=[T2 TrophLevel];
    export_vals=[nichewebsize ext_thresh web_properties(nicheweb,T1,TrophLevel) isConnected(nicheweb)];
    
    dlmwrite(strcat(name,'_export_int.txt'),export_int);
    dlmwrite(strcat(name,'_export_real.txt'),export_real);
    dlmwrite(strcat(name,'_num_years.txt'),cell2mat(struct2cell(num_years)));
    dlmwrite(strcat(name,'_export_vals.txt'),export_vals);
    
end






