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
function [meta,Z]= metabolic_scaling(meta_scale,nichewebsize,basalsp,isfish,T,Mass,orig_Z,orig_nodes)
attach(meta_scale);
%--------------------------------------------------------------------------
% Find remaining consumer-resource body size ratios (for new life stages)
% and calculate metabolic rates
%--------------------------------------------------------------------------
    Z=Mass'.^(1/(T-1)); %Consumer-resource body-size
    %IMPORTANT, FILL IN OLD Z, IN CASE YOU LOSE ACCURACY FOR NEW THINGS
    %(ALTERNATIVELY GET FUNCTION TO ONLY CALCULATE FOR J>NICHEWEBSIZE)
    Z(find(orig_nodes))=orig_Z;% Fill in original Z elements for higher accuracy
    %Nevermind, Z is probably not that important outside of the model anyhow. No need to stress about it.

%     %%Metabolic scaling constants  %%%No longer used
%     a_r = 1;
%     a_x= 0.314; %Berlow et al. 2009
%     a_y = 8*a_x;  %% note 8 is the y_ij

    %Metabolic and mass assimilation rates
    meta=zeros(nichewebsize,1);
    for i=1:nichewebsize
        if ismember(i,basalsp)
            meta(i)=0;% Brose et al 2006 , was set to .138 before;  %metabolic rate for producers
        elseif isfish(i)
            meta(i) = .88*(1./(Mass(i)) ).^A_fish;%metabolic rate for etcotherm vertebrates
        else
            meta(i) = .314*(1./(Mass(i)) ).^A_invert; %metabolic rate for invertebrates
        end
    end
