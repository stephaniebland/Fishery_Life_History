function [answer]= RunCluster(var_x,var_y)

    answer=var_x*var_y;
    dlmwrite('testing.txt',answer,',') 

end