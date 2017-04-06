clear;
nicheweb=   [0 0 0 0 0 0 0 0 0; %1
             1 0 0 0 0 0 0 0 0; %2
             1 0 0 0 0 0 0 0 0; %3
             0 0 1 0 0 0 0 0 0; %4
             0 0 0 1 0 0 0 0 0; %5
             0 0 0 0 1 0 1 0 0; %6
             0 1 0 0 0 0 0 0 0; %7
             0 0 0 0 0 1 0 0 0; %8
             0 0 0 0 0 0 0 1 0];%9                 
         
nichewebsize = length(nicheweb);
basalsp = find(sum(nicheweb,2)==0);

    edge_weight=randi(10,nichewebsize,1)-5
    Z=exp(edge_weight)
    
    Mass1=zeros(nichewebsize,1);  % Set up vector
    Mass_old=Mass1
    Mass1(1)=1; % Basal species defined to have mass equivalent to Z
    
    A=nicheweb.*Z;%Setup weighted nicheweb matrix - this is like the standard matrix used for Dijkstra algorithm, except weights represent allometric scaling instead of edge length (so multiplicative instead of additive)
    %A(6,7)=exp(15)%If you want to test changing an edge weight - this shows you can generalize the calculation to giving different edges different weights.
    
    
    while sum(Mass_old~=Mass1)~=0 %We need to iterate the while loop extra times than min req'd to calculate all Masses - because you only just got the right mass for all the prey species of an apex predator. Since Z is positive, it won't change after the longest possible simple path.
        Mass_old=Mass1
        C=A*diag(Mass1)%Find shortest paths - so C_ij is the mass if it were calculated using path going from pred i to prey j.       
        C(C==0)=NaN;%Don't mistake 0s for shortest path.  
        Mass1=min(C,[],2);%Find smallest path for each predator now that you excluded 0s
        Mass1(basalsp)=Z(basalsp);%Redefine basal species mass     
    end
    [log(Mass1), edge_weight]
    [Mass1, Z];