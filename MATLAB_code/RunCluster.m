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
    name=sprintf('BLANDsim=%04d-phase%d-year=%03d.txt',simnum,phase,rep)
    %dlmwrite(name,answer,',') 
    
end