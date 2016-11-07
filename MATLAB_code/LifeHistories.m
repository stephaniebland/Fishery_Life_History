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

%function [output]= LifeHistories(input)
function [nicheweb_new,lifehistory_table,Mvec,isfish]= LifeHistories(nicheweb,nichewebsize,connectance,basalsp)

%%-------------------------------------------------------------------------
%%  FIRST: SET DYNAMICS PARAMETERS
%%-------------------------------------------------------------------------
%Calculates species weight -> so you know how many life stages it needs
%"meta", "TrophLevel" & "T1", "IsFish" and "Z"
    [TrophLevel,T1]= TrophicLevels(nichewebsize,nicheweb,basalsp);
    [Z,Mvec,isfish]= MassCalc(nichewebsize,basalsp,TrophLevel);

%%-------------------------------------------------------------------------
%%  NUMBER OF LIFESTAGES & WEIGHTS
%%-------------------------------------------------------------------------
%Calculate Life history mass for all fish species
W_scalar=max(Mvec)/100000;%Factor by which you can scale all the weights, so that the maximum fish weight is *exactly* the denominator.  So every ecosystem will always have top predator that weighs exactly that amount (unless it goes extinct)
%May want to consider adding some stochasticity to this scalar.
lifestage_mass=Mvec.*isfish;% You only want to add lifestages to fish
W_max=lifestage_mass/W_scalar;%So adult weight of all the fish species.
t_max=ones(nichewebsize,1);
t_max(find(isfish))=randi([1 4],sum(isfish),1);%BE CAREFUL - THIS IS LIKE NUMBER OF ADDITIONAL LIFE STAGES (you may want N_stages instead)

growth_exp=3;%Growth exponent, 3 is for isometric growth (Sangun et al. 2007)
q=0.0125;%Conversion factor from weight to length
L_max=(W_max/q).^(1/growth_exp);%(Sangun et al. 2007)
L_inf=(10^0.044)*(L_max.^0.9841);
K=3./t_max;% Set according to W_inf
t_0=t_max+((1./K).*log(1-(L_max./L_inf)));%For small adult weights (ex: W_max=88.7630), this breaks down and starts giving positive t_0
%Temporary solution to K being too large.  I'll just force it to be small
%enough to get a negative t_0
for i=find(t_0>0)'
    K(i)=-log(1-(L_max(i)/L_inf(i)))/t_max(i);
    K(i)=0.9*K(i);%I had no justification for choosing 90%
end
t_0=t_max+((1./K).*log(1-(L_max./L_inf)));%Recalculate t_0 now that K is corrected.

%Create a matrix lifestage_Mass/Mass_matrix that describes the weight of each life stage j
%for each fish i (so fish species are in rows, and lifestages are in
%columns.
newwebsize=nichewebsize+sum(isfish.*t_max);%Size of new web, including 
Mass_matrix=zeros(nichewebsize,1+max(t_max))/0;%Just want NAN matrix of correct dimensions.
Mass_matrix(:,1)=Mvec/W_scalar;%First column is just the weight of all species (fish rows will be overwritten with weight of youngest lifestage)
for i=find(isfish')%only does the loop for fish species
    for t=0:t_max(i)
        L_t=L_inf(i)*(1-exp(-K(i)*(t-t_0(i))));%von-Bertalanffy growth model
        W_t=q*(L_t^growth_exp);%(Sangun et al. 2007)
        Mass_matrix(i,t+1)=W_t;
    end
end
%Now convert to a vector.
Mass=reshape(Mass_matrix',1,numel(Mass_matrix));
Mass(isnan(Mass))=[];%Alternate identical method: Mass=Mass(find(isnan(Mass)==0));
%Get a vector that says what species each lifestage is part of
N_stages=isfish+t_max;%Number of lifestages for each species. Necessary because fish with t_max=1 means it has 2 lifestages, and didn't want to use 0 for other species because K=3/t_max doesn't like it.
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
%Suppose you have a fish with 4 life stages.  Then you can create a
%lifehistory matrix for it.  Find correlations from Hutchings, J. A., Myers, R. A., García, V. B., Lucifora, L. O., & Kuparinen, A. (2012). Life-history correlates of extinction risk and recovery potential. Ecological Applications, 22(4), 1061–1067. Retrieved from http://www.esajournals.org/doi/abs/10.1890/11-1313.1
%This relates age at maturity, max litter size, and weight to growth rate.
%But since both weight and age are fixed, well, you could either adjust age
%accordingly (you just calculated age). Are you sure you want to use this,
%or is there something better?

%Fish life history tables:  Creates a Leslie matrix where aij is the contribution of life stage j to life stage i.
lifehistory_table=eye(newwebsize);%Identity Matrix for life history table, so non-fish are untransformed by matrix
for i=1:nichewebsize
    stages=N_stages(i);%Number of fish life history stages
    if stages~=1
        mature=.1*ones(1,stages-1);%length of stages-1, some sort of distribution
        fert=.5*ones(1,stages);%length of stages, some sort of distribution
        non_mature=zeros(1,stages);%Default for fish that don't mature is 0, they either mature or die.
        %NOTE!  The order of the following lines IS important!!!
        %lifehis_breed=zeros(stages);%Reset matrix from last run.
        lifehis_breed=diag(mature,-1);%Set the subdiagonal to the probability of maturing to the next stage
        lifehis_breed(1,:)=fert;%Set the first row to the fertility rate;
        lifehis_breed=lifehis_breed+diag(non_mature);%Set the diagonal to the probability of not maturing to the next stage, but staying the same age.
        %So now, incorporate it into life history table
        lifehistory_table(i:(i+stages-1),i:(i+stages-1))=lifehis_breed;
    end
end

%%-------------------------------------------------------------------------
%%  NEW NICHEWEB - NEO'S METHOD - SPLIT OLD DIET
%%-------------------------------------------------------------------------
%Two ways of doing this, either can split old diet, as recommended by Neo,
%or we can run the model again and just give new lifestages new diets.
N_prey=sum(nicheweb,2);%Vector saying how many prey species each species has.
Nprey_per_stage=ceil(N_prey./N_stages);%Minimum number of prey each lifestage needs to eat to cover entire diet
%        diet_selec(find(isfish'))
%Create new nicheweb
nicheweb_new=zeros(newwebsize);
nicheweb_new(orig_index,orig_index)=nicheweb.*nonfish;%Rows for invertebrate species that you wish to preserve
for i=find(isfish')%This loop will give a broader overlap
    selec=find(nicheweb(i,:));
    k=(Nprey_per_stage(i)*N_stages(i))-N_prey(i);%How many prey will need to be assigned to two lifestages.
    n=N_stages(i)-1;%number of neighbouring lifestages.
    y=randsample(n,k);%Which pairs of lifestages will share a prey species.  with or without replacement
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



[N_stages, (1:30)'];%useful for coding rn. 
N_prey=sum(nicheweb,2);%This is redundant, can delete later
[[string('Species'), string('Number of stages'), string('Number of Prey')];[find(isfish), N_stages(find(isfish')), N_prey(find(isfish'))]]%again, just useful for coding rn.  


for i=find(isfish')%This loop will give a narrower overlap DONT USE IT WHAT IF YOU HAVE 3 PREY AND 4 STAGES, ONE WILL GIVE 0
    find(nicheweb(i,:))
    n=diet_selec(i);
    N_prey(i)-(n*N_stages(i));
end

stages=N_stages(i);
diet=N_prey(i);






%nonfish=1-isfish;
for i in 
i=12;
stages=N_stages(i);
diet=N_prey(i);



find(nicheweb)

A=nicheweb
[a b]=find(A);
M=30
v = A((1-M:0)'+accumarray(a,b,[],@min)*M)


%Assign sigma, the degree of specialization or generalization
maxStages=max(lifestage_N);
N_prey=sum(nicheweb,2);
%The following way is extremely controlled, it will mimic any function in [0,1]:
speci_fun=@(x) x.^2+1;%Important -> speci_fun(0)>0
diet_redundancy=5;%A rough estimate of the amount of overlap in diet between life stages.
if speci_fun(0)<=0
    error('CHANGE THE SPECIALIST FUNCTION SO THAT IT IS ALWAYS GREATER THAN 0')
end
spec_gener=zeros(nichewebsize,maxStages);%pre-allocating variable size for speed.
for i=1:nichewebsize
    N=lifestage_N(i);%Number of lifestages in this species (1 for non-fish)
    spec_i=speci_fun(0:1/(N-1):1); %Assigns the number of prey for each life stage from N different points in the chosen function in [0,1] interval.
    spec_i=(spec_i/sum(spec_i)).*(N_prey(i)+diet_redundancy);%Normalizes the number of prey so that the entire prey selection is covered by the different lifestages.
    spec_gener(i,1:N)=ceil(spec_i);%Throws on a ceiling, so that each life stage has at least 1 prey item.
end
%Honestly, this function has its fair share of problems.  It might just be
%the distribution I'm using, but it's always deterministic, and you might
%end up with long strings of '1's.

%Alternatively just use a random distribution instead:
%Any degree of specialist is equally likely at any stage unless I use a
%sort function
for i=1:nichewebsize
    spec_i=betarnd(1,1,1,lifestage_N(i))*10;%since beta distribution E[X]=a/(a+b)<=1, you'll never get the average high enough.  I mean, you might as well just use any regular distribution
    spec_i=rand(1,lifestage_N(i))*10;%see, at least these values will be kind of normal.
    %Now if I want to normalize it so that I can guarantee it covers the
    %entire prey selection:
    spec_gener(i,1:lifestage_N(i))=(spec_i/sum(spec_i)).*(N_prey(i)+diet_redundancy);%Normalizes the number of prey so that the entire prey selection is covered by the different lifestages.
end
spec_gener=ceil(spec_gener);%Throws on a ceiling, so that each life stage has at least 1 prey item.
%Here is the sort function:
spec_gener=sort(spec_gener,2,'descend'); %I don't know how I feel about using this either. The idea is to make sure that the degree of specialism doesn't jump around, and continually increases.

%%%%%%%%%%%%Rate of increase for niche values according to lifestage%%%%%%%%%%%%
%Choose the rate at which niche values increases with lifestage.  By this I
%mean that the minimum niche values can increase quickly or slowly (so that fish either eat mainly small prey for most of their life, or they eat large prey most of their life - think about it as a curve with prey's niche value on the y axis and lifestage on the x axis.  You're changing the concavity of this function.)
min_niche_prey=zeros(nichewebsize,maxStages);%preallocating variable size for speed.
for i=1:nichewebsize%Counts through all the species
    if max(nicheweb(i,:)==0%So if species i doesn't have any prey
        min_niche_prey(i,:)=%GAH IT WOULD PROB BE WAY SMARTER TO JUST DO FISH SPECIES
    Prey(i,:)=find(nicheweb(i,:));
    
    Juve_prey=min(Prey(i,:));
    N_lifeshifts=1/(lifestage_N(i)-1);%Number of lifestage shifts this fish goes through, so that final sequence will be lifestage_N long (number of elements).
    Adult_prey=max(Prey(i,:))-spec_gener(30,find(spec_gener(30,:),1,'last'));%This is the maximum prey minus the number of prey the last life stage consumes.  This problematic though, because it means that younger lifestages will *always* need to eat prey smaller than the smallest adult prey.  It would be much better to find a way to distribute this where each lifestage can eat anything in [min(Prey):max(Prey)], but since you're listing these by the smallest prey at each lifestage (the min of the range) you should use [min(Prey):(max(Prey)-number of prey that lifestage eats)]
    min_niche_prey(i,:)=round(Juve_prey:N_lifeshifts:Adult_prey); %Ideally you should be able to choose this however you would like to, and right now it doesn't guarantee perfect coverage. It's just a boring old straight line (second derivative =0)
end
%The problem with the above is that all lifestages' prey are limited by (max(Prey)-number of prey that lifestage eats), rather than a more natural range
%Here I fix that by a more natural approach
%But if I use this approach, it would still require a way to distribute the actual prey distribution
for i=1:nichewebsize
    min_niche_prey(i,1:lifestage_N(i))=min(Prey(i,:));
    max_niche_prey(i,:)=max(Prey(i,:))-spec_gener(30,find(spec_gener(30,:),1,'last'));
end

nicheweb_new(1:nichewebsize,1:nichewebsize)=nicheweb;

end




