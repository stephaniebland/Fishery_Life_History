%--------------------------------------------------------------------------
% Program by: R Rael
% Growth function
% Modified by Barbara Bauer (simplification of equations)
% Mofified by Perrine Tonin (f_a, f_m and functional response)
% modified by Stephanie Bland
%--------------------------------------------------------------------------
%=========called by biomass.m; 
% Takes parameters, Bvec, returns growth rate vector for all species
%--------------------------------------------------------------------------

function [growth_vec]= gr_func(x,b_size,K,int_growth,meta,max_assim,...
    effic,Bsd,nicheweb,q,c,f_a,f_m,ca)
global reprod Effort fishing_scenario;

B=x(1:b_size);
E=x((1:b_size)+3*b_size);

basalsp = find(int_growth ~= 0); %% indices of basal species
N_s = length(nicheweb);

B1mx = B*ones(1,N_s); %% B-s in columns (one row=one species, columns are identical)
B2mx = B1mx';         %% B in rows (one column=one species, rows are identical)


%--------------------------------------------------------------------------
%% Functional Response Matrix
% $$F_{ij}=\frac{{wBh}_{ij}} {{B0h}_{ij}+{cBiB0h}_{ij}+{sumwBkh}_{ij}}$$
%
% $${wBh}_{ij}=w_{ij}{Bpow}_j=\frac{a_{ij}}{\sum_{j=1}^S a_{ij}}B_j^h$$
%
% $$B0h_{ij}=Bsd_{ij}^h$$
%
% $$cBiB0h_{ij}=\sum_{k=1}^S \left(a_{kj}c_{kj}pik_{ik}B_k Bsd_{kj}^h \right)$$
%
% $$sumwBkh_{ij}=\sum_{k=1}^S w_{ik}B_k=\sum_{k=1}^S \left(\frac{a_{ik}B_k^h}{\sum_{j=1}^S a_{ij}}\right)$$
%--------------------------------------------------------------------------

    % biomasses to power q+1, which regulates shape of Holling-curve
    h=1+q;
    Bpow = B.^h;
    B0h = Bsd.^h;
    %---------------------------
    
    % omega (preferences) matrix
    nr_resources=sum(nicheweb,2); 
    w=nicheweb./nr_resources;  % Create unweighted w matrix. (Proportion of predator diet that each species gives).
    w(isnan(w))=0;
    %---------------------------
    
    % resource species shared (pik) matrix
    Niche=double(nicheweb);%Useful if nicheweb is logical (probably more efficient way of storing it, but we already have it as a double)
    pik=(Niche*Niche')./nr_resources;%Niche*Niche' is a matrix where element a_ij is the number of prey that both i and j eats.(so they would be competing for same prey)
    pik(isnan(pik))=0;%Dividing by 0 gives NaN so we reassign it to 0.
    %---------------------------
    
    % competition due to other predators
    cBiB0h=zeros(N_s);
    for i=1:N_s
        val=nicheweb.*c.*pik(i,:)'.*B.*B0h;%This line only works because nicheweb is binary!
        cBiB0h(i,:)=sum(val);
    end
    %---------------------------
    
    wBh = w.*(ones(N_s,1)*Bpow');
    sumwBkh = w*Bpow*ones(1,N_s); 

    % Final functional response
    F = wBh ./ (B0h + cBiB0h + sumwBkh); % because B0h nonzero, division is ok for non consumed species
    
%--------------------------------------------------------------------------
%% Fishing Loss
%--------------------------------------------------------------------------

    switch fishing_scenario
        case 0
            fishery=Effort'.*B;% Constant effort scenario
        case 1
            fishery=Effort'.*(B.^2./(B+50000));% Negative-density dependent scenario
    end

%--------------------------------------------------------------------------
%% All Equations
% $$GPP=r_i\left(1-\sum_{j\in{Autotrophs}}\frac{B_j}{K} \right)B_i$$
% 
% $$MetabLoss=f_m x_iB_i$$
% 
% $$LossH=$$
% 
% $$gain=\sum_{j\in{Prey}}f_a x_i y_{ij}F_{ij}B_i$$
% 
% $$loss=\sum_{j\in{Predators}}x_jy_{ji}B_j\frac{F_{ji}}{e_{ji}} $$
%--------------------------------------------------------------------------

    % Gross primary production.
    % Only applies to autotrophs
    GPP = int_growth.*(1-(sum(B(basalsp))./K));  

    % Metabolic loss
    % Is 0 for autotrophs
    MetabLoss = f_m.* meta;
    
    % Harvesting vector
    Loss_H=ca.* E;

    % Consumption
    gain = f_a.* meta.* sum(max_assim.*F,2);
    %metab*max.rate*functional resp.(including pref)/efficiency
    %have to divide by prey biomass because the functional response already contains
    %it, but we want to multiply by it only in biomass.m
    loss = sum((meta*(ones(1,N_s))).*max_assim.*F.*(B1mx./(B2mx.*effic)),1);
    loss(B==0)=0; % results of previous row-cleared for dead species
    NRG = gain - loss';     % consumption - being consumed
    
    %% Biomass Shifted for Reproductive Effort
    % Surplus Energy (assimilated carbon minus respiration)
    % Kuparinen et al 2016 Fishing-induced life-history changes...
    % The positive "growth spurts" in biomass.
    Surplus_energy=max(gain-MetabLoss,0);
    % This growth spurt can be dedicated to somatic growth or reproductive
    % effort. the reprod vector says how much will go towards reproduction.
    % reprod_effort isn't cashed in until the end of year (simulations.m)
    reprod_effort=reprod.*Surplus_energy;
    
    %% Group Equations
    % Total biomass growth vector (need to multiply by B still)
    growth_v=GPP-MetabLoss-Loss_H+NRG-fishery;
    
% Returned Vectors
growth_vec = [growth_v;reprod_effort;fishery];


