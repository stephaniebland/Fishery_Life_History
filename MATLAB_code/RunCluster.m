function [answer]= RunCluster(seed_0,simnum,lifestages_linked,Adults_only)
    rng(seed_0+simnum)
    answer=seed_0+simnum*lifestages_linked^Adults_only
    dlmwrite('testing.txt',answer,',') 
    
end