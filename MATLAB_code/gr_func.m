%--------------------------------------------------------------------------
% Program by: R Rael
% Growth function
% Modified by Barbara Bauer (simplification of equations)
% Mofified by Perrine Tonin (f_a, f_m and functional response)
% Last modification in March 2012
%--------------------------------------------------------------------------
%=========called by biomass.m; 
% Takes parameters, Bvec, returns growth rate vector for all species
%--------------------------------------------------------------------------

function [growth_vec]= gr_func(x,b_size,K,int_growth,meta,max_assim,...
    effic,Bsd,nicheweb,q,c,f_a,f_m,ca,reprod,cont_reprod,Effort,fishing_scenario)

B=x(1:b_size);
E=x((1:b_size)+3*b_size);

basalsp = find(int_growth ~= 0); %% indices of basal species
N_s = length(nicheweb);

B1mx = B*ones(1,N_s); %% B-s in columns (one row=one species, columns are identical)
B2mx = B1mx';         %% B in rows (one column=one species, rows are identical)


%--------------------------------------------------------------------------
%  Functional Response Matrix
%--------------------------------------------------------------------------

    % biomasses to power q+1, which regulates shape of Holling-curve
    h=1+q;
    Bpow = B.^h;
    B0h = Bsd.^h;
    %---------------------------
    
    % omega (preferences) matrix
    nr_resources=sum(nicheweb,2); 
    tmp=1./nr_resources;
    tmp(basalsp)=zeros(size(basalsp));
    w=tmp * ones(1,N_s); 
    w=nicheweb.*w;
    %---------------------------
    
    % resource species shared (pik) matrix
    Niche=double(nicheweb);
    pik=nr_resources*ones(1,N_s);
    pik(basalsp,:)=1; % to prevent dividing by 0
    pik=(Niche*Niche')./pik;
    %---------------------------
    
    % competition due to other predators
    cBiB0h=zeros(N_s);
    for i=1:N_s
        for j=1:N_s
            pred=find(nicheweb(:,j)==1);
            val=0;
            k=0;
            while k<length(pred)
               k=k+1;
               val=val+c(pred(k),j)*pik(i,pred(k))*B(pred(k))*Bsd(pred(k),j)^h;
            end
            cBiB0h(i,j)=val;
        end
    end
    clear pred;
    clear val;
    %---------------------------
    
    wBh = w.*(ones(N_s,1)*Bpow');
    sumwBkh = w*Bpow*ones(1,N_s); 

    % Final functional response
    F = wBh ./ (B0h + cBiB0h + sumwBkh); % because B0h nonzero, division is ok for non consumed species
    %---------------------------

    

%--------------------------------------------------------------------------
%  Fishing Loss
%--------------------------------------------------------------------------
switch fishing_scenario
    case 0
        fishery=Effort'.*B;% Constant effort scenario
    case 1
        fishery=Effort'.*(B.^2./(B+50000));% Negative-density dependent scenario
end

%--------------------------------------------------------------------------
%  Set the equations
%--------------------------------------------------------------------------

    % Gross primary production.
    GPP = int_growth.*(1-(sum(B(basalsp))./K));  

    % Metabolic loss
    MetabLoss = f_m.* meta;
    
    % Harvesting vector
    Loss_H=ca.* E; 

    % This is to prevent a divide by 0 when B_i= 0.
    loss = zeros(1,N_s);
    [deadpreds_i deadpreds_j] = find(B2mx ==0);
    B2mx(deadpreds_i,deadpreds_j) = -1; %anything not 0

    % Consumption
    gain = f_a.* meta.* sum(max_assim.*F,2);
    loss = sum((meta*(ones(1,N_s))).*max_assim.*F.*(B1mx./(B2mx.*effic)),1);
    %metab*max.rate*functional resp.(including pref)/efficiency
    %have to divide by prey biomass because the functional response already contains
    %it, but we want to multiply by it only in biomass.m
    loss(deadpreds_j) = 0;  % results of previous row cleared for dead
    NRG = gain - loss' - fishery;     % consumption - being consumed
    
    net_growth=max(NRG,0);%biomass increase if positive, 0 if negative.
    fish_gain_timestep=net_growth;%./B;
    fish_gain_timestep(find(B==0))=0;%Set inf values to 0.
    
    spent_reprod=reprod.*net_growth;%Fish Biomass Lost due to reproduction
    if cont_reprod==false
        spent_reprod=0;
    end
    
    % Total growth
    growth_vec = [GPP - MetabLoss - Loss_H + NRG - spent_reprod;fish_gain_timestep;fishery];


