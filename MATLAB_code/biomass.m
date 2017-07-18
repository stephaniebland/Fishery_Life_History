%--------------------------------------------------------------------------
% Program by:R Rael
% modified by Barbara Bauer to include the economic equation
% modified by Perrine Tonin to include  the three price scenarios
% last modification March 2011
%--------------------------------------------------------------------------
%============called by dynamic_fn; calls Gr_func.m
% this script calculates the derivatives dB/dt and dE/dt
%--------------------------------------------------------------------------

function [dxdt] = biomass(t,x,b_size,K,int_growth,meta,max_assim,...
    effic,Bsd,nicheweb,q,c,f_a,f_m,ca,co,mu,p_a,p_b,~)
global reprod;
%x=real(x);
x=max(0,x);

B=x(1:b_size);
E=x((1:b_size)+3*b_size);     

%--------------------------------------------------------------------------
% price model
% select the type of the inverse demand curve
%--------------------------------------------------------------------------
% 1) linear    
    p=p_a*(1-p_b.*ca.*E.*B);
% 2) isoelastic
     %p=p_a.*(ca.*E.*B).^-p_b;
% 3) non linear, non isoelatic
     %p=p_a./(1+p_b.*ca.*E.*B);
%p=max(zeros(size(p)),p);

%--------------------------------------------------------------------------
% growth vectors
%--------------------------------------------------------------------------

[growth_vec] = gr_func(x,b_size,K,int_growth,meta,max_assim,...
    effic,Bsd,nicheweb,q,c,f_a,f_m,ca); %calculates the growth vector for B

dBdt = growth_vec(1:b_size).* B;
% Track the biomass shifted for reproductive effort. This looks for all
% the positive "growth spurts" in biomass.
net_growth=max(dBdt-B,0);
% This growth spurt can be dedicated to somatic growth or reproductive
% effort. the reprod vector says how much will go towards reproduction.
dReprod_dt=reprod.*net_growth;
% Subtract the biomass lost from the growth vector
dBdt=dBdt-dReprod_dt;
bleh5 = growth_vec((1:b_size)+b_size).* B;

if max(abs(dReprod_dt-bleh5))>0
    [dReprod_dt bleh5]
    xk=5;
end


fish_catch = growth_vec((1:b_size)+2*b_size).* B;
dEdt = mu.*(p.*ca.*B-co).*E;

dxdt=[dBdt;dReprod_dt;fish_catch;dEdt];

