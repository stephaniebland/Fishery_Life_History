nicheweb=   [0 0 0 0 0 0 0 0 0; %1
             1 0 0 0 0 0 0 0 0; %2
             1 0 0 0 0 0 0 0 0; %3
             0 0 1 0 0 0 0 0 0; %4
             0 0 0 1 0 0 0 0 0; %5
             0 0 0 0 1 0 1 0 0; %6
             0 1 0 0 0 0 0 0 0; %7
             0 0 0 0 0 1 0 0 0; %8
             0 0 0 0 0 0 0 1 0];%9
Z=[1;2;2;2;2;2;500;2;2];                    
         
nichewebsize = length(nicheweb);
nicheweb1=+nicheweb;
prey=sum(nicheweb1,2); %sum of each row
basalsp = find(sum(nicheweb,2)==0);

    Z_0=Z;
    origstuff=randi(10,nichewebsize,1)-5
    Z=exp(origstuff)
    
    Mass1=NaN(nichewebsize,1);  % Set up vector
    Mass1(1)=1; % Basal species defined to have mass equivalent to Z
    
    A=nicheweb.*Z;%Setup weighted nicheweb matrix - this is like the standard matrix used for Dijkstra algorithm, except weights represent allometric scaling instead of edge length (so multiplicative instead of additive)
    A(6,7)=exp(15)
    
    Assign mass for non basal species
    YES, *of course* you can use same method with Z=[1 1 ...1] for calculating Trophic levels T1, and it's prob cleaner, but both methods work. 
    for k=0:nichewebsize%We need to iterate the while loop extra times than min req'd to calculate all Masses - because you only just got the right mass for all the prey species of an apex predator. Since Z is positive, it won't change after the longest possible simple path.
        C=A*diag(Mass1)%Find shortest paths - so C_ij is the mass if it were calculated using path going from pred i to prey j.       
        C(C==0)=NaN;%Don't mistake 0s for shortest path.  
        Mass1=min(C,[],2);%Find smallest path for each predator now that you excluded 0s
        Mass1(basalsp)=Z(basalsp);%Redefine basal species mass     
    end
    [log(Mass1), origstuff]
    [Mass1, Z]