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



%% Webdriver
    S_0=30;% Number of original nodes (species)
    N_years=5;%Total number of years to run simulation for
    L_year=100;% Number of (days?) in a year (check units!!!)

%% setup
    connectance=0.15;

%% MassCalc
    masscalc.num_orig_fish=NaN; %Max number of fish species allowed in original model.  If NaN is used, you choose 60% of species with species with TL>=3 (trophic level)
    masscalc.m_fish   =5000;  % mean for fishes
    masscalc.v_fish   =100;   % standart deviation for fishes
    masscalc.m_invert =100;   % mean for invertebrates
    masscalc.v_invert =100;   % standart deviation for invertebrates
    
%% metabolic_scaling
    % Allometric scaling exponent (Boit et al. in prep.)
    meta_scale.A_fish=0.11;
    meta_scale.A_invert=0.15;
    
    