%--------------------------------------------------------------------------
% Rosalyn Rael
%  Modified Apr 2011 Barbara Bauer, changed metabolic rates of basals
%  to zero (Brose et al. 2006) and rewrote some comments
%  Modified March 2012 Perrine Tonin, added distinction bewteen
%  invertebrates and fishes, stochasticity in the consumer-resource
%  body size constants Z and rewrote some comments
%--------------------------------------------------------------------------
%  Computes metabolic rates allometrically
%  Reference: Brose et al. PNAS 2009
%  Uses the following parameters:
%  nichewebsize, basalsp, isfish, T
%--------------------------------------------------------------------------

% uncomment if to use as a function
function [Z,Mvec,isfish,W_scaled,W_scalar]= MassCalc(masscalc,nichewebsize,nicheweb,basalsp,T)
attach(masscalc);
%--------------------------------------------------------------------------
%Fish or invertebrate
%--------------------------------------------------------------------------
    % distinction between invertebrates and fishes
    if isnan(num_orig_fish)
        isfish=zeros(nichewebsize,1);
        possibfish=find(T>=3);                % species with TL<3 are always invertebrates
        bernoulli=rand(length(possibfish),1);
        bernoulli=logical(bernoulli<=.6);     % for species with TL>=3, probability of 60% of being a fish
        isfish(possibfish)=bernoulli; %That's clever...
    else
        %Alternatively, just choose top three "most fish-like" species to be fish
        isfish=zeros(nichewebsize,1);
        [~, fishiness]=sort(T);%Rank species by how fish like they are.  This only chooses top 3, but some could have trophic levles < 3 still.
        isfish(fishiness(end-num_orig_fish+1:end))=1;%Choose top three species to be fish
    end
        
%--------------------------------------------------------------------------
%Constant consumer-resource body size
%--------------------------------------------------------------------------
    % Follows a lognormal distribution with different means and standard
    % deviation for invertebrates and fishes (Brose et al, 2006)
    
    % mean and standard deviation of the associated normal distributions
    mu_fish=log(m_fish^2/sqrt(v_fish+m_fish^2));
    mu_invert=log(m_invert^2/sqrt(v_invert+m_invert^2));
    sigma_fish=sqrt(log(v_fish/m_fish^2+1));
    sigma_invert=sqrt(log(v_invert/m_invert^2+1));
    
    %Consumer-resource body-size
    Z=lognrnd(mu_invert,sigma_invert,nichewebsize,1);
    Z(find(isfish))=lognrnd(mu_fish,sigma_fish,length(find(isfish)),1);
    Z(basalsp)=1;

%--------------------------------------------------------------------------
%Set body size based on trophic level
%--------------------------------------------------------------------------
    %% Calculate Mass according to T1 (Shortest Distance)
    Mass1=NaN(nichewebsize,1);  % Set up vector
    Mass1(basalsp)=Z(basalsp); % Basal species defined to have mass equivalent to Z
    
    A=nicheweb.*Z;%Setup weighted nicheweb matrix - this is like the standard matrix used for Dijkstra algorithm, except weights represent allometric scaling instead of edge length (so multiplicative instead of additive)
    
    % Assign mass for non basal species
    %YES, *of course* you can use same method with Z=[1 1 ...1] for calculating Trophic levels T1, and it's prob cleaner, but both methods work. 
    for k=0:nichewebsize%We need to iterate the while loop extra times than min req'd to calculate all Masses - because you only just got the right mass for all the prey species of an apex predator. Since Z is positive, it won't change after the longest possible simple path.
        C=A*diag(Mass1);%Find shortest paths - so C_ij is the mass if it were calculated using path going from pred i to prey j.
        C(C==0)=NaN;%Don't mistake 0s for shortest path.  
        Mass1=min(C,[],2);%Find smallest path for each predator now that you excluded 0s
        Mass1(basalsp)=Z(basalsp);%Redefine basal species mass
    end
    
    %% Calculate Mass according to T2 (Prey-Averaged Trophic Position)
    prey=sum(nicheweb,2); %sum of each row
    Q=nicheweb./prey;  % Create unweighted Q matrix. (Proportion of predator diet that each species gives).
    Q(isnan(Q))=0; 
    I=eye(nichewebsize);
    K=ones(nichewebsize,1);
    
    Mass2=(K*Z').^(inv(I-Q));
    Mass2=prod(Mass2,2);
    
    %% Combine the two calculations of Mass Z^T, where T=(T1+T2)/2.  {side note: previous calculations use Z^(T-1). That's not appropriate here, because autotrophs have mass=1, and this system takes weight of all items in it's food chain into account. The previous system assumed they all have weight of the predator in question, so the autotroph would have the same size as whatever it's being eaten by - clearly not great!}
    Mvec=sqrt(Mass1.*Mass2);
    
%--------------------------------------------------------------------------
%Scale mass so that von-bert function works
%--------------------------------------------------------------------------
switch maxweight
    case false %Don't scale the weight if maxweight is set to false.
        W_scaled=Mvec;
    otherwise
        %Calculate Life history mass for all fish species
        W_scalar=max(Mvec)/maxweight;%Factor by which you can scale all the weights, so that the maximum fish weight is *exactly* the denominator.  So every ecosystem will always have top predator that weighs exactly that amount (unless it goes extinct)
        %May want to consider adding some stochasticity to this scalar.
        W_scaled=Mvec/W_scalar;%Scale the weight of all species
end
    
    end
