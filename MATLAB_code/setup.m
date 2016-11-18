%--------------------------------------------------------------------------
% Program by:  Rosalyn Rael
% Modified by Barbara Bauer & Perrine Tonin
% Last modifications March, 2012
%--------------------------------------------------------------------------
% This file runs the niche model to generate a web then runs dynamics
% (or you can enter a custom web and its parameters)
% All dynamics parameters are set here.
%--------------------------------------------------------------------------




%%-------------------------------------------------------------------------
%%  PARAMETERS
%%-------------------------------------------------------------------------

%for niche Model function
%------------------------------
% S_0  = number of species to start with
% connectance = initial connectance

%for dynamic model function
%-------------------------------
% ****almost all are set to constants independent of species
%
% meta_i - mass-specific metabolic rate
% TrophLevel_i - thophic level as define by Levine (1980)
% T1_i - trophic level as the shortest path to basal species
% IsFish_i - 0 if invertebrate and 1 if fish species
% Z_i - predator-prey body-mass ratio
% int_growth_i - intrinsic growth rate (nonzero only for basals)
% K_i - carrying capacity
% max_assim_ij - max rate i assimilates j per unit metabolic rate of i
% effic_ij - assimilation efficiency of i for j
% f_a - fraction of assimilated carbon used for production of consumers
% biomass under activity
% f_m - fraction of assimilated carbon respired by maintenance of basic
% bodily functions
% q_ij - q>0 gives type III response (set to a scalar here)
% Bsd_ji - half-saturation density of j when consumed by i
% c_ij - c>0 gives predator interference
%
% t_init - integration start
% t_final - integration end
% ext_thresh - extinction threshold (biomass set to zero if it goes under
% this value)

%for harvesting 
%-------------------------------
% mu - stiffness parameter
% ca - catchability coefficient
% co - cost per unit effort
% p  - per unit price :
%   p_a & p_b : parameters for the inverse demand curve (3 possible forms):
%   p = p_a - p_b * Y       --> linear
%   p = p_a * Y^(-p_b)      --> isoelastic
%   p = p_a / (1 + p_b * Y) --> non linear & non isoelastic




%%-------------------------------------------------------------------------
%%  NICHE MODEL
%%-------------------------------------------------------------------------

%to construct niche web, uncomment the following lines.
    %S_0=30; %Commented out this line since it's better to keep it with webdriver, I think
    connectance=0.15;
    [nicheweb,n_new,c_new,r_new] = NicheModel(S_0, connectance);%Create a connected (no infinite degrees of separation) foodweb with realistic species (eg. no predators without prey), and no isolated species.

%or enter custom web (rows eats column)
    %nicheweb = [0 0 0; 1 0 0; 0 1 0];

nichewebsize = length(nicheweb);%Steph: Find number of species (not sure why, already have S_0)
basalsp = find(sum(nicheweb,2)==0);%List the autotrophs (So whatever doesn't have prey)  Hidden assumption - can't assign negative prey values (but why would you?)

%%-------------------------------------------------------------------------
%%  FIRST: SET DYNAMICS PARAMETERS
%%-------------------------------------------------------------------------
%Calculates species weight -> so you know how many life stages it needs
%"meta", "TrophLevel" & "T1", "IsFish" and "Z"
    [TrophLevel,T1_old,T2_old]= TrophicLevels(nichewebsize,nicheweb,basalsp);
    [Z,Mvec_old,isfish]= MassCalc(nichewebsize,basalsp,TrophLevel);
    % Use Linear regression to estimate slope of mass-niche relationship:
    [R_squared,Adj_Rsq,lin_regr]=Linear_Regression(Mvec_old,n_new,isfish,nicheweb);

%%-------------------------------------------------------------------------
%%  LIFE HISTORY
%%-------------------------------------------------------------------------
    nicheweb_old=nicheweb;%Save the old nicheweb just incase.
    isfish_old=isfish;% Uses this in webdriver, so might as well keep it now rather than recalculate later
    Z_old=Z;%Need to keep this, because recalculating it introduces error
    [nicheweb_new,lifehistory_table,Mass,orig_nodes,species,N_stages]= LifeHistories(nicheweb,nichewebsize,Mvec_old,isfish,n_new,c_new,r_new);
    %Update all the output to reflect new web
    nicheweb=nicheweb_new;%Update nicheweb.  This looks really messy, but I'll clean it up later(also not sure if this line is required)
    nichewebsize = length(nicheweb);%Steph: Find number of species (not sure why, already have S_0)
    isfish=repelem(isfish,N_stages);
    meta_N_stages=repelem(N_stages,N_stages);
    lifestage=[];
    for i=1:S_0
        lifestage=[lifestage 1:N_stages(i)];
    end
    Mvec=Mass;
    basalsp = find(sum(nicheweb,2)==0);%List the autotrophs (So whatever doesn't have prey)  Hidden assumption - can't assign negative prey values (but why would you?)
    %Convert Nicheweb into an adjacency list "two-column format, in which the first column lists the number of a consumer, and the second column lists the number of one of the resource species of that consumer." - Dunne 2006
    [adj_row,adj_col]=find(nicheweb);
    adj_list=[adj_row, adj_col];%indexed from 1 and up, so if you want first node to be 0, you need to subtract 1.
    

%%-------------------------------------------------------------------------
%%  SET DYNAMICS PARAMETERS
%%-------------------------------------------------------------------------

%"meta", "TrophLevel" & "T1", "IsFish" and "Z"
%---------------------------------------------
%1) set manually
    %meta = [0; .15; .02];    
%2) Can be scaled with body size
    [TrophLevel,T1,T2]= TrophicLevels(nichewebsize,nicheweb,basalsp);%Recalculate trophic levels for new nicheweb
    %YES BUT NOW I DON'T KNOW IF I SHOULD USE OLD TROPHIC LEVEL OR NEW TROPHIC LEVELS IN METABOLIC SCALING
    [meta,Z]=metabolic_scaling(nichewebsize,basalsp,isfish,TrophLevel,Mass,Z_old,orig_nodes);
    

%Intrinsic growth parameter "r" for basal species only
%-----------------------------------------------------
    int_growth = zeros(nichewebsize,1);
    r_i_mean=1.1; r_i_std=.18; r_i_min=0.6; r_i_max=1.6;%set the r of basal within 0.6 and 1.6 (Boit et al, in prep). Original file called for 0.6-1.2 range, but methods doc says otherwise. 
    r_i_mean=0.9; r_i_std=.2; r_i_min=0.6; r_i_max=1.2;%Other Perrine code has these parameters, which make more sense because at least it's symmetrical.
    int_growth(basalsp)=r_i_mean+r_i_std*randn(length(basalsp),1);
    while max((int_growth~=0 & int_growth<r_i_min) | int_growth>r_i_max)>0%Changed to while loop so that the distribution isn't truncated and sharp at edges (original compressed the tails into little lumps at either side of the range.)
        to_replace=((int_growth~=0 & int_growth<r_i_min) | int_growth>r_i_max);
        int_growth(to_replace)=r_i_mean+r_i_std*randn(sum(to_replace),1); 
    end

%Other dynamic parameters
%------------------------

    K_param=540;%carrying capacity
    K = ones(nichewebsize,1) .*K_param;

    max_assim = 10*ones(nichewebsize);% max rate i assimilates j per unit metabolic rate of i

    effic = .85*ones(nichewebsize);%assimilation efficiency of i for j
    effic(:,basalsp) = .45;
    
    f_a = 0.4;% fraction of assimilated carbon used for production of consumers biomass under activity
    f_m = 0.1;% fraction of assimilated carbon respired by maintenance of basic bodily functions
    
    q =.2;%.2;% q>0 gives type III response (set to a scalar here) [according to Fernanda Valdovinos, this one parameter makes a huge difference to stability]
    %biomasses to power q+1, which regulates shape of Holling-curve (h=1+q) Fernanda says h=1.2 is stable for normal webs.
    
%Half saturation density "Bsd" and predator interference "c"  
%-----------------------------------------------------------
    %Bsd = 1.5*ones(nichewebsize);
    %c = ones(nichewebsize,nichewebsize)*0.5;
    [Bsd, c]=func_resp_scaling(nicheweb,nichewebsize,isfish,Z,basalsp);

%set initial and final integration times
%---------------------------------------
    t_init = 0;
    t_final= 700;%5000;

%set the extinction threshold
%----------------------------
    ext_thresh = 10^-6; %set to zero to work without extinction threshold  (=reality check --> biomass set to zero if it goes under this value)
    
    
    
    
%%-------------------------------------------------------------------------
%%  HARVESTING
%%-------------------------------------------------------------------------

%set parameters for harvesting
%-----------------------------
%  base-case set from Conrad(1999)
%  set mu to 0 to fix the harvest
    mu=0; % stiffness parameter
    ca=0.01; % catchability coefficient
    co=1; % cost per unit effort

%price parameters
%----------------
%1) linear inverse demand curve
    p_a=0;
    p_b=0; % set to zero to fix the price
%2) isoelastic inverse demand curve
    %p_a=10;
    %p_b=2; % set to zero to fix the price
%3) non linear and non isoelastic inverse demand curve
    %p_a=1000;
    %p_b=10; % set to zero to fix the price
 
%assign harvesting link to a top species
%---------------------------------------
%1) randomly among top or nonbasal species
    %possib_harv=logical(sum(nicheweb,2)~=0); %nonbasal species
    %possib_harv=logical(sum(nicheweb,1)==0)'; %top species = no predator
    %roll=rand(nichewebsize,1).*possib_harv; %random number assigned to all of them (basals get a zero)
    %harv=logical(roll==max(roll));          %one with the highest number gets harvested
%2) or set manually
    %harv=[0;0;1];
    harv=zeros(nichewebsize,1);
%3) randomly among species with high torphic level and high biomass
    %possib_harv=zeros(nichewebsize,1);
    %nonbasalsp=find(sum(nicheweb,2)~=0);
    %possib_harv(nonbasalsp)=TrophLevel(nonbasalsp)./meta(nonbasalsp);  %calculate trophic level / metabolic rate
    %threshold=sort(possib_harv);
    %threshold=threshold(end-2);
    %possib_harv=logical(possib_harv>=threshold); %select the 3 species with highest TL/x_i
    %clear threshold;
    %roll=rand(nichewebsize,1).*possib_harv; %random number assigned to all of them
    %harv=logical(roll==max(roll)); 

    
    
    
    
%%-------------------------------------------------------------------------
%%  Set initial conditions
%%-------------------------------------------------------------------------

%initial Biomass
%---------------
%1) randomly set between 0.02 and 20, from a uniform distb:
     B0 = (999*rand(nichewebsize,1)+1)*.01;
     %B0(find(isfish))=B0(find(isfish))/60;% Maybe try to tweak original fish densities
%2) from uniform distribution in the ranges 5-500, 2-200 and 1-100 
    %B0 = (99*rand(nichewebsize,1)+1).*[5; 2; 1];
%3) set manually, example on 2 species
    %B0= [250 50 1]';

%initial Effort
%--------------
%1) randomly set initial effort
     %E_init=99*rand(nichewebsize,1)+1; %number between 1 and 100.
     %E0=harv.*E_init;
%2) set manually
     %E0=[0 0 2]';
%3) no effort
     E0=zeros(nichewebsize,1);
    