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
function [meta,Z,Mvec]= metabolic_scaling(nichewebsize,basalsp,isfish,T)
    
%--------------------------------------------------------------------------
%Constant consumer-resource body size
%--------------------------------------------------------------------------
    % Follows a lognormal distribution with different means and standart
    % deviation for invertebrates and fishes (Brose et al, 2006)
    
    m_fish   =5000;  % mean for fishes
    v_fish   =100;   % standart deviation for fishes
    
    m_invert =100;   % mean for invertebrates
    v_invert =100;   % standart deviation for invertebrates
    
    % mean and standard deviation of the associated normal distributions
    mu_fish=log(m_fish^2/sqrt(v_fish+m_fish^2));
    mu_invert=log(m_invert^2/sqrt(v_invert+m_invert^2));
    sigma_fish=sqrt(log(v_fish/m_fish^2+1));
    sigma_invert=sqrt(log(v_invert/m_invert^2+1));
    
    %Consumer-resource body-size
    Z=lognrnd(mu_invert,sigma_invert,nichewebsize,1);
    Z(find(isfish==1))=lognrnd(mu_fish,sigma_fish,length(find(isfish==1)),1);

%--------------------------------------------------------------------------
%Set body size based on trophic level and calculate metabolic rates
%--------------------------------------------------------------------------
    Mvec = zeros(nichewebsize,1); %mass per individual
    Mvec=Z.^(T-1);  %T-1 used since basal level is 1.

    %%Metabolic scaling constants
    a_r = 1;
    a_x= 0.314; %Berlow et al. 2009
    a_y = 8*a_x;  %% note 8 is the y_ij

    % Allometric scaling exponent (Boit et al. in prep.)
    A_fish=0.11;
    A_invert=0.15;

    %Metabolic and mass assimilation rates
    meta=zeros(nichewebsize,1);
    for i=1:nichewebsize
        if ismember(i,basalsp)
            meta(i)=0;% Brose et al 2006 , was set to .138 before;  %metabolic rate for producers
        elseif isfish(i)
            meta(i) = .88*(1./(Mvec(i)) ).^A_fish;%metabolic rate for etcotherm vertebrates
        else
            meta(i) = .314*(1./(Mvec(i)) ).^A_invert; %metabolic rate for invertebrates
        end
    end
