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
function [meta,Z]= metabolic_scaling(meta_scale,basalsp,isfish,Mass,orig,species)
attach(meta_scale);
% Don't attach orig - don't want to overwrite nichewebsize!

    %% Z Consumer-Resource Body Ratios - Just give everything the same as adults.
    Z=orig.Z(species);
    
    %% Metabolic and mass assimilation rates
    meta=.314*(1./Mass).^A_invert; %metabolic rate for invertebrates
    meta(isfish)=.88*(1./Mass(isfish)).^A_fish;%metabolic rate for etcotherm vertebrates
    meta(basalsp)=0; % Brose et al 2006 , was set to .138 before;  %metabolic rate for producers

end


