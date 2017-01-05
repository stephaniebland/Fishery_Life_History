%--------------------------------------------------------------------------
% Program by: Stephanie Bland
% November 14, 2016
%--------------------------------------------------------------------------
% ATN Model with life histories linked.
%--------------------------------------------------------------------------

clearvars -except abort_sim; clear global;
beep off
warning off MATLAB:divideByZero;
global reprod cont_reprod Effort;
%--------------------------------------------------------------------------
% Protocol parameters
%--------------------------------------------------------------------------
Parameters;
setup;% creation of a new food web

full_sim=nan(N_years*L_year,4*nichewebsize);
full_t=nan(N_years*L_year,1);
year_index=nan(N_years*L_year,1);
B_year_end=nan(N_years,nichewebsize);
AllCatch=nan(nichewebsize,N_years*L_year);
B0=B_orig;
t_days=0;
t_year=1;
abort_sim=false;
%Run one time phase at a time, each phase has different conditions
for phase=1:4
    switch phase
        case 1 % before lifehistory starts
            n_years_in_phase=num_years.prelifehist;
            evolve=false;%initialize the evolution setting, needs to be done every time you run the loop
            nicheweb=extended_web;%Set nicheweb to the original web before fishing induced dietary shifts
            Effort=0;
        case 2 %{insert lifehistory}
            n_years_in_phase=num_years.pre_fish;
            evolve=false;
            Effort=0;
        case 3 %{insert fishing}
            n_years_in_phase=num_years.fishing;
            evolve=true; % Fecundity evolves (fish reach maturity at a younger age)
            %% Shift fish diet according to evolution
            if exist('extended_n','var')==1
                reorder_by_size=extended_n;
            else
                reorder_by_size=1:nichewebsize;%eh, just don't bother reordering if you dont use an extended web that starts with new niche values.
            end
            [shifted_web]=Dietary_evolution(nicheweb,isfish,evolv_diet,reorder_by_size);
            nicheweb=shifted_web;
            Effort=catchrate*isfish'*hmax./(1+exp(-2*((lifestage-1)-F50)));
        case 4 %{quit fishing}
            n_years_in_phase=num_years.post_fish;
            evolve=false;
            Effort=0;
    end
    for i=1:n_years_in_phase
        if (evolve==true || t_days==0)%For years after evolution starts
            [reprod]=prob_of_maturity(prob_mat,nichewebsize,is_split,N_stages,species,i);
        end
        %% ODE
        [x, t] =  dynamic_fn(K,int_growth,meta,max_assim,effic,Bsd,q,c,f_a,f_m, ...
            ca,co,mu,p_a,p_b,nicheweb,B0,E0,t_init,L_year+1,ext_thresh);
        B_end=x(L_year+1,1:nichewebsize)'; % use the final biomasses as the initial conditions
        B0=B_end;
        if lstages_linked==true
            %% Move biomass from one life history to the next
            fish_gain_tot=sum(x(1:L_year,(1:nichewebsize)+nichewebsize),1)';
            if cont_reprod==false
                fish_gain_tot=1;
            end
            %DOUBLE CHECK THAT YOU TAKE B OUT OF FOLLOWING LINE
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            B0=aging_table*B_end+fecund_table*(reprod.*fish_gain_tot.*B_end); %Last step is adding contribution from all lifestages, so put the rest in brackets! %Split lifehistory_table into two parts.
        end
        %% Concatenate Data for all years
        full_sim((1:L_year)+t_days,:)=x(1:L_year,:);
        full_t((1:L_year)+t_days)=t(1:L_year)+t_days;%full_t does not have timesteps that are *exactly* 1, so numbers don't look to nice.  keep anyhow.
        year_index((1:L_year)+t_days)=repelem(t_year,L_year);%Pointless really, just the year of each time step. good for checking data
        B_year_end(t_year,:)=B_end;%For matlab graphs- just year end biomasses
        t_days=t_days+L_year;%Index Number of days that passed, because loop repeated for cases
        t_year=t_year+1;%Index Number of years that passed, because loop repeated for cases
        %% Aborts simulation early if there aren't enough fish for it to continue
        surv_sp=find(B0>ext_thresh);%Index of all surviving nodes (indexed by newwebsize)
        surv_fish_stages=intersect(find(isfish),surv_sp);%Surviving fish lifestages (indexed by new newwebsize)
        surv_fish=unique(species(surv_fish_stages));%The original species number of each surviving fish (indexed as one of S_0)
        if (length(surv_fish)<3 && phase<3)%Cancel simulation if there aren't enough surviving fish species (not nodes) before fishing even starts
            abort_sim=true;
            break
        end
    end
    if abort_sim==true
        break
    end
end

B=full_sim(:,1:nichewebsize);
day=0:size(full_sim,1)-1;%Use this for graphs instead of full_t because full_t has gaps and is not perfect
AllCatch=full_sim(:,2*nichewebsize+(1:nichewebsize));
E=full_sim(:,3*nichewebsize+(1:nichewebsize));

find(isnan(B)==1) % Check for errors that might occur
nan_error=min(find(isnan(B)==1))
isConnected(nicheweb)%Error with TrophicLevels.m may be because it's not connected? As a matrix that is, it was already connected before in orig web, so lifehistories connections keep it alright.
sum(is_split)-lifehis.lstages_maxfish
sum(B_orig)-sum(B_end)

%Plot Total Biomass 
delta_biomass=sum(B,2)-sum(B_orig);
find(delta_biomass==max(delta_biomass));
find(delta_biomass==min(delta_biomass));
plot(day,delta_biomass);

%fish_props;% Remember to change function so nothing is brought back [~]=fish_props;

%--------------------------------------------------------------------------
% Export Data
%--------------------------------------------------------------------------
if abort_sim==false %If the food web is stable enough & has enough fish species before fishing starts, can export it for analysis in R
    %Export Data
end

%--------------------------------------------------------------------------
% plot the dynamics
%--------------------------------------------------------------------------
%% Fish vs Invertebrates

% figure(1); hold on;
% 
% %subplot(2,1,1); hold on;
% plot_fish=B(:,[find(isfish')]);
% plot_invert=B(:,[find(1-isfish')]);
% plot(day,log10(plot_fish),'r','LineWidth',1);
% plot(day,log10(plot_invert),'b','LineWidth',1);
% %plot(day,log10(B));
% xlabel('time'); ylabel('log10 biomass')
% %legend('Autotroph','Herbivore','Carnivore')
% grid on;

%% Plot Fish Species by colour (invertebrates are all same colour), and lifestage by line type

figure(1); hold on;
p=plot(day,log10(B),'LineWidth',1);
[~,~,ind_species]=unique(isfish.*species');
[~,~,ind_lifestage]=unique(lifestage);
%colours=get(gca,'colororder');
colours=parula(sum(orig.isfish)+1);
%mark={'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'}
line_lifestage={'-','--',':','-.','-.','-.'};
for i=1:nichewebsize
    p(i).Color=colours(ind_species(i),1:3);
    %p(i).Marker=char(mark(ind(i)))
    p(i).LineStyle=char(line_lifestage(lifestage(i)));%Youngest lifestage is given same line type as non-fish species
end
xlabel('time (1/100 years)'); ylabel('log10 biomass')
title('Fish Species by colour (invertebrates are all same colour), and lifestage by line type')
grid on;
    
%% Individual Fish Species, by total biomass
[a,~,ic]=unique(species.*isfish');
%species_index=1:length(a);% might be useful for plotting colours later, but I doubt it.
nCols=size(B,1);
B_as_vector=reshape(B',nichewebsize*nCols,1);
%for each time step, sum the biomass by species.  
labels = [repmat(ic(:),nCols,1) ...             %# Replicate the row indices
          kron(1:nCols,ones(1,numel(ic))).'];  %'# Create column indices
B_species = accumarray(labels,B_as_vector(:));  %# I used "totals" instead of "means"
B_species=B_species';

%PLOT IT

figure(1); hold on;
fish_only=B_species(:,2:end);
plot(day,log10(B_species),'LineWidth',1.5);%Including Inverts & Plants
%plot(day,log10(fish_only),'LineWidth',1.5);%Only Fish
xlabel('time'); ylabel('log10 biomass')
grid on;

%% Annual means for every node
[a,~,ic]=unique(year_index);
nCols=nichewebsize;
nRows=length(B);
B_as_vector=reshape(B,nichewebsize*nRows,1);
%for each time step, sum the biomass by species.  
labels = [repmat(ic(:),nCols,1) ...             %# Replicate the row indices
          kron(1:nCols,ones(1,numel(ic))).'];  %'# Create column indices
B_year_mean = accumarray(labels,B_as_vector(:),[],@mean);  %# I used "totals" instead of "means"

%PLOT IT

figure(1); hold on;
plot(1:N_years,log10(B_year_mean),'LineWidth',1.5);%Annual Means for all nodes
xlabel('time'); ylabel('log10 biomass')
grid on;


%% Annual Means for every species
[a,~,ic]=unique(species.*isfish');
%species_index=1:length(a);% might be useful for plotting colours later, but I doubt it.
nCols=size(B_year_mean,1);
B_as_vector=reshape(B_year_mean',nichewebsize*nCols,1);
%for each time step, sum the biomass by species.  
labels = [repmat(ic(:),nCols,1) ...             %# Replicate the row indices
          kron(1:nCols,ones(1,numel(ic))).'];  %'# Create column indices
B_ann_species = accumarray(labels,B_as_vector(:));  %# I used "totals" instead of "means"
B_ann_species=B_ann_species';


%PLOT IT
figure(1); hold on;
fish_ann_only=B_ann_species(:,2:end);
plot(1:N_years,log10(B_ann_species),'LineWidth',2);%Including Inverts & Plants
%plot(1:N_years,log10(fish_ann_only),'LineWidth',2);%Only Fish
xlabel('time'); ylabel('log10 biomass')
grid on;

%% Plot Year ends
%PLOT IT
figure(1); hold on;
plot(1:N_years,log10(B_year_end),'LineWidth',1.5);%Including Inverts & Plants
xlabel('time'); ylabel('log10 biomass')
grid on;

%% Year ends for every species
[a,~,ic]=unique(species.*isfish');
%species_index=1:length(a);% might be useful for plotting colours later, but I doubt it.
nCols=size(B_year_end,1);
B_as_vector=reshape(B_year_end',nichewebsize*nCols,1);
%for each time step, sum the biomass by species.  
labels = [repmat(ic(:),nCols,1) ...             %# Replicate the row indices
          kron(1:nCols,ones(1,numel(ic))).'];  %'# Create column indices
B_end_species = accumarray(labels,B_as_vector(:));  %# I used "totals" instead of "means"
B_end_species=B_end_species';

%PLOT IT
figure(1); hold on;
fish_end_only=B_end_species(:,2:end);
plot(1:N_years,log10(B_end_species),'LineWidth',1.5);%Including Inverts & Plants
plot(1:N_years,log10(fish_end_only),'LineWidth',1.5);%Only Fish
xlabel('time'); ylabel('log10 biomass')
grid on;


