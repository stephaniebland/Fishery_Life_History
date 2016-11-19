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
%  Assigns Life History Stages
%  Reference: 
%  Uses the following parameters:
%  nicheweb,nichewebsize,connectance,basalsp,IsFish
%--------------------------------------------------------------------------
%This function is dependent on the weight of each fish, since weight is
%proportional to life history structure and number of stages (lifespan)...
%That's why it comes after you already created the nicheweb.
%I will build a new nicheweb for this (to determine feeding structure,
%unless Anna has a better idea), and then replace the known ones with the
%old nicheweb, so as to not mess up the entire model.  (So you are
%basically just adding rows and columns for your new life stages).

function [nicheweb_new,lifehistory_table,Mass,orig_nodes,species,N_stages,is_split]= LifeHistories(lifehis,leslie,orig,nichewebsize,n_new,c_new,r_new)
attach(orig); attach(lifehis);
%%-------------------------------------------------------------------------
%%  SELECT FISH SPECIES TO BE SPLIT
%%-------------------------------------------------------------------------
is_split=isfish;
fish2div=find(is_split');
if isnan(lstages_maxfish)==0  
    can_split=min(lstages_maxfish,sum(isfish));%limit to total number of fish.
    split_fish_i=randsample(sum(isfish),can_split);%Choose which fish species to split, indexed by fish species
    is_split=zeros(nichewebsize,1);
    is_split(fish2div(split_fish_i))=1;%fish that will be split are 1s, species that aren't are 0.
    fish2div=find(is_split');
end

%%-------------------------------------------------------------------------
%%  NUMBER OF LIFESTAGES & WEIGHTS
%%-------------------------------------------------------------------------
%Calculate Life history mass for all fish species
W_scalar=max(Mvec)/maxweight;%Factor by which you can scale all the weights, so that the maximum fish weight is *exactly* the denominator.  So every ecosystem will always have top predator that weighs exactly that amount (unless it goes extinct)
%May want to consider adding some stochasticity to this scalar.
W_scaled=Mvec/W_scalar;%Scale the weight of all species
W_max=W_scaled.*is_split;%You only want to add lifestages to fish. This is their adult weight.
t_max=ones(nichewebsize,1);%set to ones because dividing by zero is a pain.
t_max(fish2div)=randi(agerange,sum(is_split),1);%BE CAREFUL - THIS IS LIKE NUMBER OF ADDITIONAL LIFE STAGES (you may want N_stages instead)
%Jeff said most fish are within 2-6 [1 5] years for age at maturity (and t_max excludes the first year, so it's fine.)

L_max=(W_max/q).^(1/growth_exp);%(Sangun et al. 2007)
L_inf=(10^0.044)*(L_max.^0.9841);
K=3./t_max;% Set according to W_inf
t_0=t_max+((1./K).*log(1-(L_max./L_inf)));%For small adult weights (ex: W_max=88.7630), this breaks down and starts giving positive t_0
%Temporary solution to K being too large.  I'll just force it to be small enough to get a negative t_0
for i=find(t_0>0)'
    K(i)=-log(1-(L_max(i)/L_inf(i)))/t_max(i);
    K(i)=0.9*K(i);%I had no justification for choosing 90%
end
t_0=t_max+((1./K).*log(1-(L_max./L_inf)));%Recalculate t_0 now that K is corrected.

%Create a matrix lifestage_Mass/Mass_matrix that describes the weight of each life stage j
%for each fish i (so fish species are in rows, and lifestages are in
%columns.
newwebsize=nichewebsize+sum(is_split.*t_max);%Size of new web, including new lifestages
Mass_matrix=nan(nichewebsize,1+max(t_max));%Just want NAN matrix of correct dimensions.
Mass_matrix(:,1)=W_scaled;%First column is just the weight of all species (fish rows will be overwritten with weight of youngest lifestage)
for i=find(is_split')%only does the loop for fish species that you split
    for t=0:t_max(i)
        L_t=L_inf(i)*(1-exp(-K(i)*(t-t_0(i))));%von-Bertalanffy growth model
        W_t=q*(L_t^growth_exp);%(Sangun et al. 2007)
        Mass_matrix(i,t+1)=W_t;
    end
end
%Now convert to a vector.
Mass=reshape(Mass_matrix',numel(Mass_matrix),1);
Mass(isnan(Mass))=[];%Alternate identical method: Mass=Mass(find(isnan(Mass)==0));
%Get a vector that says what species each lifestage is part of
N_stages=is_split+t_max;%Number of lifestages for each species. Necessary because fish with t_max=1 means it has 2 lifestages, and didn't want to use 0 for other species because K=3/t_max doesn't like it.
species=[];%Vector saying what species each new node is part of.
orig_nodes=[];%Vector that says which nodes are original nodes (so new lifestages are 0, and species that were in the original model are 1.
for i=1:nichewebsize
    j=N_stages(i);
    species=[species, repelem(i,j)];
    orig_nodes=[orig_nodes, repelem(0,j-1),1];
end
orig_species=orig_nodes.*species;%Enumerates the original species
orig_index=find(orig_nodes');%index of original species

%%-------------------------------------------------------------------------
%%  LIFE HISTORY MATRIX - LESLIE MATRIX
%%-------------------------------------------------------------------------
year=1;%Because leslie matrix will soon be time dependent, I want to preserve functionality in original file
[lifehistory_table,~,~]= LeslieMatrix(leslie,newwebsize,N_stages,year,is_split,species);

%%-------------------------------------------------------------------------
%%  NEW NICHEWEB - NEO'S METHOD - SPLIT OLD DIET
%%-------------------------------------------------------------------------
%Two ways of doing this, either can split old diet, as recommended by Neo,
%or we can run the model again and just give new lifestages new diets.
N_prey=sum(nicheweb,2);%Vector saying how many prey species each species has.
Nprey_per_stage=ceil(N_prey./N_stages);%Minimum number of prey each lifestage needs to eat to cover entire diet
%Create new nicheweb
nicheweb_new=zeros(newwebsize);
nonsplit=1-is_split;
nicheweb_new(orig_index,orig_index)=nicheweb.*nonsplit;%Rows for invertebrate species that you wish to preserve
%PROBLEM:  INVERTEBRATES CURRENTLY DONT PREY ON ANY FISH SPECIES
for i=fish2div%This loop will give a broader overlap
    selec=find(nicheweb(i,:));
    selec=find(ismember(orig_species, selec));%convert old species index into the new species index
    k=(Nprey_per_stage(i)*N_stages(i))-N_prey(i);%How many prey will need to be assigned to two lifestages.
    n=N_stages(i)-1;%number of neighbouring lifestages.
    y=randsample(n,k);%Which pairs of lifestages will share a prey species.  with or without replacement. Currently without replacement
    prey_split=zeros(N_stages(i),newwebsize);
    u=1;
    for j=1:N_stages(i)
        v=u+Nprey_per_stage(i)-1;
        choose=selec(u:v);
        prey_split(j,choose)=1;
        u=v+1-sum(y==j);
    end
    nicheweb_new(find(species==i),:)=prey_split;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%PROBLEM: NOTHING PREYS ON THE JUVENILES
%Currently the fish prey is split correctly, but the only fish lifestage
%that is predated are the adults.

%[n_new, c_new, r_new]





% %Species that eat fish
% indexfish_new=find(ismember(species, fish2div));%Index of fish species for new web
% nicheweb_new(:,indexfish_new);
% nicheweb(:,fish2div);

%First approximation is just that if something preys on a species, it will prey on all of the lifestages
%newnodes=1-orig_nodes;
% for i=fish2div
%     fishpred=nicheweb_new(:,find(species==i));
%     fishpred(:,1:end-1)=fishpred(:,1:end-1)+fishpred(:,end);
%     nicheweb_new(:,find(species==i))=fishpred;
% end

end




