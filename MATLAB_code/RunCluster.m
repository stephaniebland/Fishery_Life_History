function [answer]= RunCluster(seed_0,simnum,lifestages_linked,Adults_only)

    answer=seed_0+simnum*lifestages_linked^Adults_only
    dlmwrite('testing.txt',answer,',') 

end