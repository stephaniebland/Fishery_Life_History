function [answer]= RunCluster(var_x,var_y,var_z)

    answer=var_x*var_y^var_z
    dlmwrite('testing.txt',answer,',') 

end