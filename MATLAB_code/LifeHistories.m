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
%% SELECT FISH SPECIES TO BE SPLIT
% We might want to limit the number of fish with life histories.
%%-------------------------------------------------------------------------

% The default is just to split (add life history to) every fish species:
is_split=isfish;
fish2div=find(is_split');
% But suppose we want to limit the number of fish species to split, so if
% we have 5 fish species, but only want to endow life history to 3 of them.
if isnan(lstages_maxfish)==0
    % First, we limit the number of species to split by the total number
    % of fish species. We can_split at least this number of fish.
    can_split=min(lstages_maxfish,sum(isfish));
    % Then, choose without replacement from the list of fish species. This
    % gives an indexed list of fish species to split.
    fish2div=randsample(fish2div,can_split);
    % And finally we can set a logical vector of fish2div, where 1=split.
    is_split=false(nichewebsize,1);
    is_split(fish2div)=true;
end

%%-------------------------------------------------------------------------
%% LIFE HISTORY CHARACTERISTICS
% Now that we know which stages should be split, we want to find out what
% they look like. We want to define characteristics - how long do they
% live? How large is each age class?
%%-------------------------------------------------------------------------

%% Number of Life Stages
% Now we can define the number of lifestages each species has.

% Every species has at least one life stage, while the split species are
% given any number within the range of lifehis.agerange.
N_stages=ones(nichewebsize,1);
N_stages(fish2div)=randi(agerange,sum(is_split),1);
% Now I can define t_max to number of additional lifestages.
t_max=N_stages-1;

%% Life Stage Individual Body Size
% We will use Von-Bertallanfy to find the mass of new lifestages.

% Start by finding the adult weights for the fish species you will split.
W_max=W_scaled.*is_split;
% It turns out to be way easier to deal with fish length rather than mass,
% so we will convert mass to length
L_max=(W_max/q).^(1/growth_exp); % (Sangun et al. 2007)
% Then we can approximate the asymptotic fish length - if fish were
% immortal they would eventually max out at this size.
L_inf=(10^0.044)*(L_max.^0.9841);
% K is the curvature of the von-bert, and we use this simple approximation.
% It works for most cases, we only modify it when it yields a postive t_0
K=3./t_max;
% Next, we find t_0, which is the x-intercept of a weight vs. age plot.
% This is the age at which fish have a weight of 0, which would happen
% before the egg is formed (at meiosis for gametes)
% Requirement: t_0 must be negative. This is so a) the math works out, and
% b) it's biologically realistic.
% For small adult weights (ex: W_max=88.7630), this breaks down and starts
% giving positive t_0. I force it to be negative in those cases.
t_0=t_max+((1./K).*log(1-(L_max./L_inf)));
% Temporary solution to K being too large.  I'll just force it to be small
% enough to get a negative t_0
for i=find(t_0>=0)'
    % So first find K such that t_0=0
    K(i)=-log(1-(L_max(i)/L_inf(i)))/t_max(i);
    % Then we reduce K by an arbitrary amount to force t_0 to be negative.
    K(i)=0.9*K(i); % I have no justification for choosing 90%
end
% Recalculate t_0 now that K is corrected.
t_0=t_max+((1./K).*log(1-(L_max./L_inf)));

% Create a matrix lifestage_Mass/Mass_matrix that describes the weight of
% each life stage j for each fish i (so species are in rows, and lifestages
% are in columns.
% Create NaN mass matrix with correct dimensions.
Mass_matrix=nan(nichewebsize,max(N_stages));
% First column is the weight of all species (fish rows will be overwritten
% with weight of youngest lifestage, for correct order when reshaped)
Mass_matrix(:,1)=W_scaled;
% Loop through split species:
for i=find(is_split')
    for t=0:t_max(i)
        % Von-Bertalanffy growth model
        L_t=L_inf(i)*(1-exp(-K(i)*(t-t_0(i))));
        % Length to weight conversion (Sangun et al. 2007)
        W_t=q*(L_t^growth_exp);
        Mass_matrix(i,t+1)=W_t;
    end
end
% Now convert to a vector.
Mass=reshape(Mass_matrix',numel(Mass_matrix),1);
% Clear all NaN values
Mass(isnan(Mass))=[];

%% Organize
% Keep track of species, original nodes, and total number of nodes

% Size of the new web, including new life stages
newwebsize=nichewebsize+sum(is_split.*t_max);
% Initiate vectors
species=[];
orig_nodes=[];
for i=1:nichewebsize
    j=N_stages(i);
    % Species will track which species each new life stage belongs to
    species=[species, repelem(i,j)];
    % Original nodes will say which nodes were original nodes. New life
    % stages are 0, while original nodes are 1
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
% Create new nicheweb & Fill in what we already know
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
    % Standardize niche values and mass here,then you can use intercept of -4.744e-17, and slope of 2.338e-01 to calculate new niche values for new nodes,then you transform it back to reg.
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
clumped_web=zeros(nichewebsize);
% First, find a 30x30 (orig nichewebsize) matrix where each row & column is
% a unique species, and a_ij is whether any lifestage of i eats any
% lifestage of j.
for i=1:nichewebsize
    % First clump the rows together. Like folding paper in a z pattern, we
    % can't fold horizontally and vertically simultaneously, and dimensions
    % work out better if you take all horizontal folds first, and then go
    % on to vertical folds. This is why we need two nearly identical loops.
    clump_rows(i,:)=sum(nicheweb_new(species==i,:),1);
end
for i=1:nichewebsize
    % In a separate loop, clump the columns.
    clumped_web(:,i)=sum(clump_rows(:,species==i),2);
end
% Now, we can expand the small matrix back into a 39x39 matrix, with
% redundant rows and columns. It's just easier to stick to one size of web
% to use in the simulations - we won't need to alter the size of any other
% variables.
clumped_web=repelem(clumped_web,N_stages,N_stages);
clumped_web=logical(clumped_web); % Logical to clear sums >1.

end




