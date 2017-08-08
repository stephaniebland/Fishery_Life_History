%--------------------------------------------------------------------------
% Program by:  Rosalyn Rael
% Modified by Barbara Bauer & Perrine Tonin
% Last modifications March, 2012
%--------------------------------------------------------------------------
% This file runs the niche model to generate a web then runs dynamics
% (or you can enter a custom web and its parameters)
% All dynamics parameters are set here.
%--------------------------------------------------------------------------

N_years=sum(cell2mat(struct2cell(num_years)));%Total number of years to run simulation for
orig.isfish=0;
while sum(orig.isfish)==0%Guarantee that the food web has at least one fish
%%-------------------------------------------------------------------------
%%  NICHE MODEL
%%-------------------------------------------------------------------------
    [orig] = NicheModel(cannibal_invert,S_0,connectance);%Create a connected (no infinite degrees of separation) foodweb with realistic species (eg. no predators without prey), and no isolated species.
    nichewebsize = length(orig.nicheweb);%Steph: Find number of species (not sure why, already have S_0)
    basalsp = find(sum(orig.nicheweb,2)==0);%List the autotrophs (So whatever doesn't have prey)  Hidden assumption - can't assign negative prey values (but why would you?)

%%-------------------------------------------------------------------------
%%  SET DYNAMICS PARAMETERS
%%-------------------------------------------------------------------------
%Calculates species weight -> so you know how many life stages it needs
    [TrophLevel,orig.T1,orig.T2]= TrophicLevels(nichewebsize,orig.nicheweb,basalsp);
    [orig.Z,orig.Mvec,orig.isfish]= MassCalc(masscalc,nichewebsize,orig.nicheweb,basalsp,TrophLevel);
end

%%-------------------------------------------------------------------------
%%  LIFE HISTORY
%%-------------------------------------------------------------------------
    [nicheweb,Mass,orig.nodes,species,N_stages,is_split,aging_table,fecund_table,extended_n,clumped_web]= LifeHistories(lifehis,leslie,orig,nichewebsize,connectance);
    %Update all the output to reflect new web
    nichewebsize = length(nicheweb);
    extended_web=nicheweb;%Save backup of extended web before dietary shift
    isfish=repelem(orig.isfish,N_stages);
    meta_N_stages=repelem(N_stages,N_stages);
    lifestage=[];
    for i=1:S_0
        lifestage=[lifestage 1:N_stages(i)];
    end
    Mvec=Mass;
    basalsp = find(sum(nicheweb,2)==0);%List the autotrophs (So whatever doesn't have prey)  Hidden assumption - can't assign negative prey values (but why would you?) also important because something that used to be basal may no longer be basal
    basal_ls=sum(nicheweb,2)==0;
    
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
    [meta,Z]=metabolic_scaling(meta_scale,basalsp,isfish,Mass,orig,species);
    

%Intrinsic growth parameter "r" for basal species only
%-----------------------------------------------------
    int_growth = zeros(nichewebsize,1);
    int_growth(basalsp)=r_i_mean+r_i_std*randn(length(basalsp),1);
    while max((basal_ls & int_growth<r_i_min) | int_growth>r_i_max)>0%Changed to while loop so that the distribution isn't truncated and sharp at edges (original compressed the tails into little lumps at either side of the range.)
        to_replace=((basal_ls & int_growth<r_i_min) | int_growth>r_i_max);
        int_growth(to_replace)=r_i_mean+r_i_std*randn(sum(to_replace),1); 
    end

%Other dynamic parameters
%------------------------
    K = ones(nichewebsize,1) .*K_param;

    max_assim=assim.max_rate*ones(nichewebsize);% max rate i assimilates j per unit metabolic rate of i

    effic=assim.effic_nonplants*ones(nichewebsize);%assimilation efficiency of i for j
    effic(:,basalsp) = assim.effic_basal;

%Half saturation density "Bsd" and predator interference "c"  
%-----------------------------------------------------------
    %Bsd = 1.5*ones(nichewebsize);
    %c = ones(nichewebsize,nichewebsize)*0.5;
    [Bsd, c]=func_resp_scaling(func_resp,nicheweb,nichewebsize,isfish,Mass,basalsp);

%set initial and final integration times
%---------------------------------------
    t_init = 0;
    t_final= L_year*N_years;%5000;
    
    
    
%%-------------------------------------------------------------------------
%%  HARVESTING
%%-------------------------------------------------------------------------

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

%DOESNT EVEN MAKE SENSE TO DO THIS BEFORE YOU KNOW WHICH SPECIES SURVIVE!!!
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
%1) Random uniform distribution in interval (0.01,10)
    B_orig = (999*rand(nichewebsize,1)+1)*.01;
    if lstages_B0ratedR==true
        B_orig=B_orig.*orig.nodes';%Start with adults only.
    elseif lstages_B0ratedR~=false
        clear B_orig;%Make sure there's an error if you misspell setting
    end
%2) from uniform distribution in the ranges 5-500, 2-200 and 1-100 
    %B_orig = (99*rand(nichewebsize,1)+1).*[5; 2; 1];
%3) set manually, example on 2 species
    %B_orig= [250 50 1]';

%initial Effort
%--------------
%1) randomly set initial effort
     %E_init=99*rand(nichewebsize,1)+1; %number between 1 and 100.
     %E0=harv.*E_init;
%2) set manually
     %E0=[0 0 2]';
%3) no effort
     E0=zeros(nichewebsize,1);
    