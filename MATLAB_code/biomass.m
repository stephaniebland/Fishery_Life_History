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

%x=real(x);
x=max(0,x);

B=x(1:b_size);
E=x((1:b_size)+4*b_size);     

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
fish_revenue = growth_vec((1:b_size)+b_size).* B;
fish_catch = growth_vec((1:b_size)+2*b_size).* B;
calvin=growth_vec((1:b_size)+3*b_size);
hobbes=calvin-fish_revenue;
%[fish_revenue, calvin]
%[fish_revenue, calvin, hobbes]
if max(abs(hobbes))>1e-16
    max(abs(hobbes))
end
dEdt = mu.*(p.*ca.*B-co).*E;

dxdt=[dBdt;fish_revenue;fish_catch;calvin;dEdt];

