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
global fish_gain;
%--------------------------------------------------------------------------
% Protocol parameters
%--------------------------------------------------------------------------
setup;% creation of a new food web
B_orig=B0;


N_years=5;%Total number of years to run simulation for
L_year=100;% Number of (days?) in a year (check units!!!)

full_sim=nan(N_years*L_year,nichewebsize);
full_t=nan(N_years*L_year,1);
year_index=nan(N_years*L_year,1);
B_year_end=nan(N_years,nichewebsize);
%Run one year at a time
for i=1:N_years
    fish_gain=[];
    [x, t] =  dynamic_fn(K,int_growth,meta,max_assim,effic,Bsd,q,c,f_a,f_m, ...
        ca,co,mu,p_a,p_b,nicheweb,B0,E0,t_init,L_year,ext_thresh);
    B_end=x(L_year,1:nichewebsize)'; % use the final biomasses as the initial conditions
    B0=B_end;
    %% Change Biomass as Kuparinen et al. for Lake Constance.
    [lifehistory_table,aging_table,fecund_table]= LeslieMatrix(S_0,nichewebsize,N_stages,i,isfish_old,species);
    %% Move biomass from one life history to the next
    fish_gain_tot=sum(fish_gain,2);
    fish_gain_tot(find(1-isfish))=1;
    B0=aging_table*B_end+fecund_table*B_end.*fish_gain_tot; %Split lifehistory_table into two parts.
    %% Concatenate Data for all years
    full_sim((1:L_year)+(i-1)*L_year,1:nichewebsize)=x(1:L_year,1:nichewebsize);
    t=t+L_year*(i-1);
    full_t((1:L_year)+(i-1)*L_year)=t(1:L_year);
    year_index((1:L_year)+(i-1)*L_year)=repelem(i,L_year);
    B_year_end(i,1:nichewebsize)=B_end;
end
    

B=full_sim(:,1:nichewebsize);
E=full_sim(:,nichewebsize+1:end);

find(isnan(B)==1) % Check for errors that might occur
nan_error=min(find(isnan(B)==1))

%fish_props;% Remember to change function so nothing is brought back [~]=fish_props;

%--------------------------------------------------------------------------
% plot the dynamics
%--------------------------------------------------------------------------
%% Fish vs Invertebrates

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

%% Plot Fish Species by colour (invertebrates are all same colour), and lifestage by line type

figure(1); hold on;
p=plot(full_t,log10(B));
[~,~,ind_species]=unique(isfish.*species');
[~,~,ind_lifestage]=unique(lifestage);
colours=get(gca,'colororder');
colours=parula(sum(isfish_old)+1);
%mark={'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'}
line_lifestage={'-','--',':','-.','-.','-.'};
for i=1:nichewebsize
    p(i).Color=colours(ind_species(i),1:3);
    %p(i).Marker=char(mark(ind(i)))
    p(i).LineStyle=char(line_lifestage(lifestage(i)));%Youngest lifestage is given same line type as non-fish species
end
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
plot(full_t,log10(B_species));%Including Inverts & Plants
plot(full_t,log10(fish_only));%Only Fish
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
plot(1:N_years,log10(B_year_mean));%Annual Means for all nodes
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
plot(1:N_years,log10(B_ann_species));%Including Inverts & Plants
%plot(1:N_years,log10(fish_ann_only));%Only Fish
xlabel('time'); ylabel('log10 biomass')
grid on;

%% Plot Year ends
%PLOT IT
figure(1); hold on;
plot(1:N_years,log10(B_year_end));%Including Inverts & Plants
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
plot(1:N_years,log10(B_end_species));%Including Inverts & Plants
plot(1:N_years,log10(fish_end_only));%Only Fish
xlabel('time'); ylabel('log10 biomass')
grid on;


