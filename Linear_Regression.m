%--------------------------------------------------------------------------
%  Program by: Rosalyn Rael
%  Modified Apr 2011 Barbara Bauer, changed metabolic rates of basals
%  to zero (Brose et al. 2006) and rewrote some comments
%  Modified March 2012 Perrine Tonin, added distinction bewteen
%  invertebrates and fishes, stochasticity in the consumer-resource
%  body size constants Z and rewrote some comments
%  Modified May 2016 Stephanie Bland, added life history stages and rewrote
%  some comments
%--------------------------------------------------------------------------
%  Linear Regression to find correlation between niche value and individual
%  body mass.
%  Reference: 
%  Uses the following parameters:
%  Mvec, n_new
%--------------------------------------------------------------------------
% Estimates line of best fit for mass-niche value relationship using linear
% regression.

%function [output]= LifeHistories(input)
function[R_squared,Adj_Rsq,lin_regr]=Linear_Regression(Mvec,n_new,isfish,nicheweb)

    %Exclude plants and fish from model
    no_plants = find(sum(nicheweb,2)~=0);
    no_fish=find(1-isfish);
    just_inve=intersect(no_plants,no_fish);
    %Restrict data set
    good_M=Mvec(just_inve);
    good_n=n_new(just_inve);
    %Get x and y
    x=good_n;%niche value is x axis
    y=log10(good_M);%Mass is y axis
    
    
    %% Use MATLAB linear regression
    mdl = fitlm(x,y);
    lin_regr=mdl.Coefficients.Estimate;
    R_squared=mdl.Rsquared.Ordinary;
    Adj_Rsq=mdl.Rsquared.Adjusted;

    %% Try including Fish - It doesn't work very well
%     good_M=Mvec(no_plants);
%     good_n=n_new(no_plants);
%     x=good_n;%niche value is x axis
%     y=log10(good_M);%Mass is y axis
%     mdl = fitlm(x,y);
%     lin_regr=mdl.Coefficients.Estimate;
%     R_squared=mdl.Rsquared.Ordinary;
%     Adj_Rsq=mdl.Rsquared.Adjusted;
    
    
    %% Fit linear regression by hand
%         X=[ones(length(x),1), x];
%         lin_regr=X\y;
%         fitted_curve=X*lin_regr;
%         R_squared=1-sum((y - fitted_curve).^2)/sum((y - mean(y)).^2);
%     %Adjusted R-squared
%         yresid = y - fitted_curve;
%         SSresid = sum(yresid.^2);
%         SStotal = (length(y)-1) * var(y);
%         Adj_Rsq=1 - SSresid/SStotal * (length(y)-1)/(length(y)-2);
    
    %% Plot things
    %hold on;
    %plot(x,y,'o');
    %plot(x,fitted_curve);
    
end
    
    