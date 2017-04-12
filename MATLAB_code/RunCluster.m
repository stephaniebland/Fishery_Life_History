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

function RunCluster(seed_0,simnum,linkedstages,Adults_only)
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Simulation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 1st Simulation: Extended_nicheweb + Lifehistory: B_orig & linked
    lifestages_linked=true;
    B0=B_orig;
    simulations;
    save(strcat('complete_',num2str(simnum)))

    %% 2nd Simulation: Extended_nicheweb: B_orig & NOT linked
    lifestages_linked=false;
    B0=B_orig;
    simulations;
    save(strcat('extended_unlinked_',num2str(simnum)))

    %% 3rd Simulation: Nicheweb: B_orig=B_orig.*orig.nodes';%(Start with adults only) & NOT linked
    lifestages_linked=false;
    B_orig=B_orig.*orig.nodes';%Start with adults only. %CAUTION - changes total biomass, consider normalizing so all experiments have same total biomass. Or maybe sum juvenile stages to adult instead.
    simulations;
    save(strcat('origweb_',num2str(simnum)))
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Export Data
    name=sprintf('BLANDseed%d_sim%04d_link%d_AdultOnly%d.txt',seed_0,simnum,linkedstages,Adults_only)
    %dlmwrite(name,answer,',') 
    
end






