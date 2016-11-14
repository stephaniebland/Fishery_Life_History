%--------------------------------------------------------------------------
% Program by: Stephanie Bland
% November 14, 2016
%--------------------------------------------------------------------------
% ATN Model with life histories linked.
%--------------------------------------------------------------------------

clear;
beep off
warning off MATLAB:divideByZero;
S_0=30;% Number of original nodes (species)

%--------------------------------------------------------------------------
% Protocol parameters
%--------------------------------------------------------------------------
N_years=10;%Total number of years to run simulation for
L_year=100;% Number of (days?) in a year (check units!!!)

setup;% creation of a new food web
t_final=L_year; % Number of timesteps in a year

full_sim=zeros(0,1);
full_t=zeros(0,1);
%Run one year at a time
for i=1:N_years
    
    [x, t] =  dynamic_fn(K,int_growth,meta,max_assim,effic,Bsd,q,c,f_a,f_m, ...
        ca,co,mu,p_a,p_b,nicheweb,B0,E0,t_init,t_final,ext_thresh);
    B_end=x(end,1:nichewebsize)'; % use the final biomasses as the initial conditions
    B0=B_end;
    B0(find(isfish))=B_end(find(isfish))+x(1,find(isfish))';%new biomasses for new year
    full_sim=[full_sim;x];
    t=t+L_year*(i-1);
    full_t=[full_t;t];
end
    

B=full_sim(:,1:nichewebsize);
E=full_sim(:,nichewebsize+1:end);

%--------------------------------------------------------------------------
% plot the dynamics
%--------------------------------------------------------------------------

figure(1); hold on;

%subplot(2,1,1); hold on;
plot_fish=B(:,[find(isfish')]);
plot_invert=B(:,[find(1-isfish')]);
plot(full_t,log10(plot_fish),'r');
plot(full_t,log10(plot_invert),'b');
%plot(t,log10(B));
xlabel('time'); ylabel('log10 biomass')
%legend('Autotroph','Herbivore','Carnivore')
grid on;
        
        
 
