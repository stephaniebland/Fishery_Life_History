%--------------------------------------------------------------------------
% Program by Rosalyn Rael
% modified by Barbara Bauer to include the economic nodes Apr, 2011
% modified by Perrine Tonin to include the extinction threshold March, 2012
%
%--------------------------------------------------------------------------
%  Dynamic food webs model
%  integrates bioenergetic model
%--------------------------------------------------------------------------
% calls biomass.m,  called by: webdriver.m
%--------------------------------------------------------------------------

function [xout, tout] =  dynamic_fn(K,int_growth,meta,max_assim,effic,Bsd,q,c,f_a,f_m, ...
                   ca,co,mu,p_a,p_b,nicheweb,B0,E0,t_init,t_final,reprod,cont_reprod,Effort,fishing_scenario,ext_thresh)

b_size=length(B0);
x0=[B0;zeros(b_size*2,1);E0];%Initial Biomass, initial Effort

%--------------------------------------------------------------------------
% Uncomment to run without stopping for extinction threshold
%   options = odeset('NonNegative',1:2*b_size);
%
%   [t,x] = ode45(@biomass,t_init:t_final,x0,options,b_size,K,int_growth,meta, ...
%           max_assim,effic,Bsd,nicheweb,q,c,f_a,f_m,ca,co,mu,p_a,p_b);
%   
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Takes into account the extinction threshold

    refine  = 4;
    options = odeset('Events',@events,'NonNegative',1:4*b_size,'Refine',refine);%StephHWK:  Figure out what @events does.
    tout  = t_init;
    xout  = x0';

    while t_init<t_final-1 %integration stops at t_final
    
        [t,x,~,xe,~] = ode45(@biomass,t_init:t_final,x0,options,b_size,K,int_growth,meta, ...
                    max_assim,effic,Bsd,nicheweb,q,c,f_a,f_m,ca,co,mu,p_a,p_b,reprod,cont_reprod,Effort,fishing_scenario,ext_thresh);
 
        % Accumulate output
        tout = [tout; t(2:end)];
        xout = [xout; x(2:end,:)];
    
        % Set the new initial conditions
        if ~isempty(xe)
            dead = logical(xe(1:b_size)<=ext_thresh);
            x0 = xe;
            x0(dead) = 0;
        end
    
        t_init = t(end); %to continue the integration where it was stopped
    
    end
%--------------------------------------------------------------------------

    
%--------------------------------------------------------------------------
%Events
%----------------------------------------------------------------------
%This function is set to stop the integration when any species drops below the 
%extinction threshold.
function [lookfor, stop, direction] = events(~,y,~,~,~,~, ...
          ~,~,~,~,~,~,~,~,~,~,~,~,~,ext_thresh)

    lookfor   = y(1:30) - ext_thresh;       % look for any biomass to reach the threshold
    stop      = ones(length(lookfor),1);    % =1 to stop the code when detection of the event
    direction = zeros(length(lookfor),1);   % detection if B are increasing or decreasing

