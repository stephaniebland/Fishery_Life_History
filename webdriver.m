%--------------------------------------------------------------------------
% Program by: Rosalyn Rael
% July 13, 2008
% modified by Barbara Bauer Apr, 2011
% modified by Perrine Tonin March, 2012
% modified by Stephanie Bland 2015-2017
% Version 1.0
%--------------------------------------------------------------------------
% This script runs setup.m to set model parameters, then 
% dynamic_fn.m to integrate the bioenergetic model.
% Generates a figure and plots dynamics
% Need to chose the price model
%--------------------------------------------------------------------------
%----- calls setup.m and dynamic_fn.m
%--------------------------------------------------------------------------

clear;
beep off
warning off MATLAB:divideByZero;


setup; % to set all the parameters and simulate a nicheweb

[x, t] =  dynamic_fn(K,int_growth,meta,max_assim,effic,Bsd,q,c,f_a,f_m, ...
    ca,co,mu,p_a,p_b,nicheweb,B0,E0,t_init,t_final,ext_thresh);

harv_index = find(harv~=0); %index of the harvested species
%[nicheproperties]=web_properties(nicheweb,T1,TrophLevel); % to calculate the 17 structural properties of the nicheweb
%dlmwrite('exniche.txt',nicheweb,',') % export the nicheweb (to plot with network3d)

B=x(:,1:nichewebsize);
E=x(:,nichewebsize+1:end);

%-----------------------------------------
% calculate the means
%-----------------------------------------

    Beq=mean(B(end-400:end,:));
    Beq(find(isfish'))
    %Eeq=mean(E(end-400:end,nichewebsize));
    
    %Bheq=mean(B(end-400:end,harv_index));
    %Eheq=mean(E(end-400:end,harv_index));

%-----------------------------------------
% plot the dynamics
%-----------------------------------------

    figure(1); hold on;

    %subplot(2,1,1); hold on;
    plot_fish=B(:,[find(isfish')]);
    plot_invert=B(:,[find(1-isfish')]);
    plot(t,log10(plot_fish),'r'); 
    plot(t,log10(plot_invert),'b'); 
    %plot(t,log10(B)); 
    xlabel('time'); ylabel('log10 biomass')
    %legend('Autotroph','Herbivore','Carnivore')
    grid on;

    %subplot(2,1,2); hold on;
    %plot(t,log10(E));
    %xlabel('time'); ylabel('log10 effort')
    %grid on;
