function [answer]= RunCluster(seed_0,simnum,lifestages_linked,Adults_only)
    %% Set Seed
    rng(seed_0+simnum)
    
    %% Simulation
    answer=seed_0+simnum*lifestages_linked^Adults_only
    
    %% Export Data
    name=sprintf('BLANDsim=%04d-phase%d-year=%03d.txt',simnum,phase,rep)
    %dlmwrite(name,answer,',') 
    
end