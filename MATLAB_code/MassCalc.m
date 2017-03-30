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
function [Z,Mvec,isfish,W_scaled,W_scalar]= MassCalc(masscalc,nichewebsize,basalsp,T)
attach(masscalc);
%--------------------------------------------------------------------------
%Fish or invertebrate
%--------------------------------------------------------------------------
    isfish=zeros(nichewebsize,1);
    % distinction between invertebrates and fishes
    if isnan(num_orig_fish)
        possibfish=find(T>=3);                % species with TL<3 are always invertebrates
        bernoulli=rand(length(possibfish),1);
        bernoulli=logical(bernoulli<=.6);     % for species with TL>=3, probability of 60% of being a fish
        isfish(possibfish)=bernoulli; %That's clever...
    else
        %Alternatively, just choose top three "most fish-like" species to be fish
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

%--------------------------------------------------------------------------
%Set body size based on trophic level
%--------------------------------------------------------------------------
    Mvec = zeros(nichewebsize,1); %mass per individual
    Mvec=Z.^(T-1);  %T-1 used since basal level is 1.

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
