%%-------------------------------------------------------------------------
%%  PARAMETERS
%%-------------------------------------------------------------------------
% These are most of the parameters that I would want to tweak.

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



%% Webdriver
    S_0=30;% Number of original nodes (species)
    N_years=5;%Total number of years to run simulation for
    L_year=100;% Number of (days?) in a year (check units!!!)

%% Life History Switches
    lifehis.lstages_maxfish=3;%NaN;%Maximum number of fish species to create new lifestages for. NaN gives every fish new lifestages.
    lstages_linked=true;%Are life histories linked via leslie matrix?
    lstages_B0ratedR=true;%Start simulation with adults only.
    cannibal_invert=true;%Cannibalism for all species
    lifehis.fishpred=true;%Choose how to assign fish predators. 0 means only adults eaten, 1 means all stages are eaten, and true reassigns them according to nichevalues
    lifehis.splitdiet=false;%Choose how to split fish diet. true=split orignal diet, false=assign new diet based on new niche values

    %% DON'T WORK YET:
    lstages_ycreate=0;%Year to create new lifestages, 0 is created at beginning
    cannibal_fish=false;%false=none,true=yes & any stage can cannibalize larger stages, 2=cannibalism on strictly smaller stages,3=cannibalism on own stages and smaller stages
    
%% setup
    connectance=0.15;% initial connectance

%% MassCalc
    masscalc.num_orig_fish=NaN; %Max number of fish species allowed in original model.  If NaN is used, you choose 60% of species with species with TL>=3 (trophic level)
    masscalc.m_fish   =5000;  % mean for fishes
    masscalc.v_fish   =100;   % standard deviation for fishes
    masscalc.m_invert =100;   % mean for invertebrates
    masscalc.v_invert =100;   % standard deviation for invertebrates
    
%% LifeHistories
    lifehis.maxweight=100000;%Factor by which you can scale all the weights, so that the maximum fish weight is *exactly* this number.  So every ecosystem will always have top predator that weighs exactly that amount (unless it goes extinct). Important because Von-Bert growth model doesn't work for species over certain weight.
    lifehis.agerange=[3, 3]; %WARNING!!!: only works right now for [3 3] (fix LeslieMatrix). %Additional lifestages to add to fish.  You can choose any number within that range. %BE CAREFUL - THIS IS LIKE NUMBER OF ADDITIONAL LIFE STAGES (you may want N_stages instead) %Jeff said most fish are within 2-6 [1 5] years for age at maturity (and t_max excludes the first year, so it's fine.)
    lifehis.growth_exp=3;%Growth exponent, 3 is for isometric growth (Sangun et al. 2007)
    lifehis.q=0.0125;%Conversion factor from weight to length
    
%% LeslieMatrix
    leslie.invest=[1,0.9,0.85,0.8]; % allocation to growth for class 1,2 and 3
    leslie.starta50=3;%Age at which 50% of fish reach maturity BEFORE evolution starts.
    
%% metabolic_scaling
    % Allometric scaling exponent (Boit et al. in prep.)
    meta_scale.A_fish=0.11;
    meta_scale.A_invert=0.15;
    
%% setup - Intrinsic growth parameter "r" for basal species only
    %Original code that Anna sent me set the r of basal within min max range of (0.6,1.2), citing (Boit et al, in prep). Attached methods.doc conflicted with original code, claiming range of (0.6,1.6), citing same source. 
    %"Good" Perrine code (from Fernanda) has following parameters, which make more sense because at least it's symmetrical.
    %Caution: can't use structure here that ends with .mean or .max because attaching those would ruin basic functions.
    r_i_mean=0.9;%Original was 1.1
    r_i_std=.2;%Original was .18
    r_i_min=0.6;%Original was 0.6
    r_i_max=1.2;%Original was 1.2

%% setup - Other Dynamic Parameters
    K_param=540;%carrying capacity
    assim.max_rate=10;
    assim.effic_nonplants=.85;%assimilation efficiency of i for j (for fish and inverts)
    assim.effic_basal=.45;%assimilation efficiency of i for j (for plants)
    f_a = 0.4;% fraction of assimilated carbon used for production of consumers biomass under activity
    f_m = 0.1;% fraction of assimilated carbon respired by maintenance of basic bodily functions
    q =.2;%.2;% q>0 gives type III response (set to a scalar here) [according to Fernanda Valdovinos, this one parameter makes a huge difference to stability]
    %q - biomasses to power q+1, which regulates shape of Holling-curve (h=1+q) Fernanda says h=1.2 is stable for normal webs.

%% func_resp_scaling
   %func_resp.pred.prey the functional response of a predator when it eats the listed prey.
   %K and Bsd are Half-saturation density of prey (j) when consumed by predator (i)
   %c is predator interference for predator (i) consuming prey (j)
    func_resp.invert.K_invert    =1.5;% low half saturation density
    func_resp.invert.c_dist      =0.2;% competition  coefficient is exponential distribution with mu=0.2 (i.e. lambda=5)
    func_resp.invert.c_max       =0.5;% competition  coefficient is limited to 0.5
    func_resp.fish.fish_K        =15;%if a fish (i) eats another fish (j)
    func_resp.fish.fish_c        =3*10^-4;%
    func_resp.fish.omni_K        =50;%if the invertebrate prey j is omnivore
    func_resp.fish.omni_c        =10^-4;%
    func_resp.fish.herb.smallZ_K =150;%if the invertebrate prey j mostly herbivore is 50 times smaller than the fish predator
    func_resp.fish.herb.smallZ_c =1;%
    func_resp.fish.herb.largeZ_K =15;%if the invertebrate prey j mostly herbivore is not very much smaller than the fish predator
    func_resp.fish.herb.largeZ_c =10^-4;%
    
    
%% setup - Extinction Threshold
    ext_thresh = 10^-6; %set to zero to work without extinction threshold  (=reality check --> biomass set to zero if it goes under this value)

%% setup - Harvesting
    % Base-case set from Conrad(1999)
    %----------------------------------------------------------------------
    mu=0; % stiffness parameter (set mu to 0 to fix the harvest)
    ca=0.01; % catchability coefficient
    co=1; % cost per unit effort
    

    
    