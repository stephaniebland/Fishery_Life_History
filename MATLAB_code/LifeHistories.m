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

function [nicheweb_new,Mass,orig_nodes,species,N_stages,is_split,aging_table,fecund_table,n,clumped_web]= LifeHistories(lifehis,leslie,orig,nichewebsize,connectance,W_scaled)
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
[aging_table,fecund_table]= LeslieMatrix(leslie,newwebsize,N_stages,is_split,species);

%%-------------------------------------------------------------------------
%%  EXTENDED NICHEWEB - Several Methods
%%-------------------------------------------------------------------------
%Create new nicheweb & Fill in what we already know
nicheweb_new=zeros(newwebsize);
nonsplit=1-is_split;
nicheweb_new(orig_index,orig_index)=nicheweb.*nonsplit;%Rows for invertebrate species that you wish to preserve

%% IF WE USE NICHE VALUE TO ASSIGN PREY OR PREDATORS
% (If we give the new web a similar structure to original web *per node* -
% then each lifestage will be treated a separate species)
% Result of this Section Will be givediet - a web that says what everything
% will eat if the new niche values are used for the whole web. We will only
% replace the parts of the web that need patching up (rows and columns for
% new lifestages)
if (fishpred==2 || splitdiet==false)
    %Standardize niche values and mass here,then you can use intercept of -4.744e-17, and slope of 2.338e-01 to calculate new niche values for new nodes,then you transform it back to reg.
    fish_n=n_new(isfish);%only use adult fish data (all fish, not just is_split)
    fish_w=log10(W_max(isfish));%log the weight first
    f_mean_n=mean(fish_n);%We will be standardizing the weights and niche values by the mean & std for adult fish, because that's how I calculated the linear regression.
    f_std_n=std(fish_n);
    f_mean_w=mean(fish_w);
    f_std_w=std(fish_w);
    
    stand_w=log10(Mass);%log the weight, because that's how I found the linear regression
    stand_w=(stand_w-f_mean_w)/f_std_w;%standardize all weights by adult fish values
    
    n=zeros(sum(N_stages),1);
    n(orig_index)=n_new;
    stand_n=(n-f_mean_n)/f_std_n;%standardize all niche values by adult fish niche values
    for i=fish2div
        x=stand_w(species==i);
        y=stand_n(species==i);
        alignx=x-x(end);
        find_y_vals=alignx*2.338e-01;
        fixedy=find_y_vals+y(end);
        stand_n(species==i)=fixedy;
    end
    n=stand_n*f_std_n+f_mean_n;%Transform niche values back to original values.
    allfish=find(repelem(is_split,N_stages));
    [web_mx]=CreateWeb(sum(N_stages),connectance,n,n_new,r_new,c_new,orig_index,allfish);%Create a new web with the new niche values
    givediet=find(repelem(is_split,N_stages));%Find all lifestages that were split, and give them a new diet.  This includes adults in both fishpred AND splitdiet, because new lifestages might eat them. Esp. important for splitdiet though, so that adults actually have food.
else
    % We need to set niche values for dietary shifts. If we don't use new
    % niche values for the extended web we default to regular order.
    n=1:newwebsize;
end

%% PREY - Neo's Method: Split Old Diet
if splitdiet==true
    N_prey=sum(nicheweb,2);%Vector saying how many prey species each species has.
    Nprey_per_stage=ceil(N_prey./N_stages);%Minimum number of prey each lifestage needs to eat to cover entire diet
    for i=fish2div%This loop will give a broader overlap
        selec=find(nicheweb(i,:));
        selec=find(ismember(orig_species, selec));%convert old species index into the new species index
        k=(Nprey_per_stage(i)*N_stages(i))-N_prey(i);%How many prey will need to be assigned to two lifestages.
        n_neigh=N_stages(i)-1;%number of neighbouring lifestages. (Fencepost problem).
        y=randsample(n_neigh,k);%Which pairs of lifestages will share a prey species.  with or without replacement. Currently without replacement
        prey_split=zeros(N_stages(i),newwebsize);
        u=1;
        for j=1:N_stages(i)
            v=u+Nprey_per_stage(i)-1;
            choose=selec(u:v);
            prey_split(j,choose)=1;
            u=v+1-sum(y==j);
        end
        nicheweb_new(species==i,:)=prey_split;
    end
end

%% PREDATORS
switch fishpred
    case 1 %First approximation is just that if something preys on a species, it will prey on all of the lifestages
        for i=fish2div
            list_fishpred=nicheweb_new(:,species==i);
            list_fishpred(:,1:end-1)=max(list_fishpred(:,1:end-1),list_fishpred(:,end)); % CAUTION: This roundabout method is important! We need to preserve predatory links that already exist, which wouldn't happen if we just set all columns equal to the last.
            nicheweb_new(:,species==i)=list_fishpred;
        end
    case 2 %reassigns them according to nichevalues
        nicheweb_new(:,givediet)=web_mx(:,givediet);
end

%% PREY - Niche Values
if splitdiet==false%assign new diet based on new niche values
    nicheweb_new(givediet,:)=web_mx(givediet,:);%Also need to reassign diet for adult lifestages,
end

%%-------------------------------------------------------------------------
%%  LIFE HISTORY MATRIX - CANNIBALISM SWITCH FOR FISH
%%-------------------------------------------------------------------------
for i=fish2div %Case Inf=yes & any stage can cannibalize larger stage (so this loop won't change anything for case Inf)
    fishweb=find(species==i);
    %Are fish species partially cannibalistic? The number for cannibal_fish indicates how much younger conspecifics need to be to be cannibalized.  Of note: -1 means strictly younger, 0 means same lifestage or younger. -Inf means absolutely no cannibalism.
    nicheweb_new(fishweb,fishweb)=tril(nicheweb_new(fishweb,fishweb),cannibal_fish);
end

%%-------------------------------------------------------------------------
%%  CLUMPED WEB - Make a web where adults have all the prey and predators
%%-------------------------------------------------------------------------
% Comes after cannibalism because if we want to exclude cannibalism we
% should do that first.
clump_rows=zeros(nichewebsize,newwebsize);
clump_rows2=nicheweb_new;
clumped_web=zeros(nichewebsize);
for i=1:nichewebsize
    clump_rows(i,:)=sum(nicheweb_new(species==i,:),1);
    clump_rows2(species==i,:)=repmat(sum(clump_rows2(species==i,:),1),sum(species==i),1);
    clump_rows2(:,species==i)=repmat(sum(clump_rows2(:,species==i),2),1,sum(species==i));
end
for i=1:nichewebsize
    clumped_web(:,i)=sum(clump_rows(:,species==i),2);
end
clumped_web=repelem(clumped_web,N_stages,N_stages);
clumped_web=logical(clumped_web);
clump_rows2=logical(clump_rows2);

end




