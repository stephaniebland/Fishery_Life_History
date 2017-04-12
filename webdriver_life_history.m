%--------------------------------------------------------------------------
% Program by: Stephanie Bland
% November 14, 2016
%--------------------------------------------------------------------------
% ATN Model with life histories linked.
%--------------------------------------------------------------------------
simnum=1;
while simnum<=1
clearvars -except simnum; clear global;
beep off
warning off MATLAB:divideByZero;
global reprod cont_reprod Effort;

%--------------------------------------------------------------------------
% Protocol parameters
%--------------------------------------------------------------------------
Parameters;

setup;% creation of a new food web
%% Save Deterministic Data For Replicates
save(strcat('setup_',num2str(simnum)))%Save the results up to now

%% 1st Simulation: Extended_nicheweb + Lifehistory: B_orig & linked
lifestages_linked=true;
B0=B_orig;
simulations;
save(strcat('complete_',num2str(simnum)))

%% 2nd Simulation: Extended_nicheweb: B_orig & NOT linked
lifestages_linked=false;
B0=B_orig;
simulations;
save(strcat('extended_unlinked_',num2str(simnum)))

%% 3rd Simulation: Nicheweb: B_orig=B_orig.*orig.nodes';%(Start with adults only) & NOT linked
lifestages_linked=false;
B_orig=B_orig.*orig.nodes';%Start with adults only. %CAUTION - changes total biomass, consider normalizing so all experiments have same total biomass. Or maybe sum juvenile stages to adult instead.
simulations;
save(strcat('origweb_',num2str(simnum)))

%% Increase simnum by 1
simnum=simnum+1;

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
[~,~,ic]=unique(species.*isfish');
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
[~,~,ic]=unique(year_index);
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
[~,~,ic]=unique(species.*isfish');
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
[~,~,ic]=unique(species.*isfish');
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


