%--------------------------------------------------------------------------
% Program by: Rosalyn Rael
% Barbara Bauer added a part removing species not connected to a basal
% and changed the output to a 'row eats column' type matrix
% Coralie Picoche and Perrine Tonin changed the 'removing part' in 
% order not to change the connectance
% Ref: Williams and Martinez, Nature, 2000.
% Last modification : June 2011
%--------------------------------------------------------------------------
% This function produces a niche model food web.
% Input: number of species, connectance
% Output: adjacency matrix called 'nicheweb' 
% A(i,j) = 1 if i eats j.(row eats column)
%--------------------------------------------------------------------------

function [web_mx,n_new,r_new,c_new]=CreateWeb(num_nodes,connectance,n,n_old,r_old,c_old,orig_index,givediet)
%% Parameters for beta distribution:
alpha = 1;
beta = (1-2*connectance)/(2*connectance); %Coralie : ???

%% Designate range for each species
r = betarnd(alpha,beta,num_nodes,1);    %vector of ranges
r = r.*n;%second run of this will give new life stages new ranges; I think we can give it that freedom, but we could also constrain it more (as if a species doesn't change level of specialism as it ages).

%% set center of range, uniformly distributed in [r_i/2,n_i];
c=rand(num_nodes,1).*(min(n,1-r./2)-r./2)+r./2; %Corrected distribution so the probability is uniform

%% If you're running the loop for the second time, to get an extended food web, save the old niche values.
if exist('n_old')==1
    n(orig_index)=n_old;
    r(orig_index)=r_old;
    c(orig_index)=c_old;
end

%% Sort everything
[n_new, Indx] = sort(n);
%n_new: niche values in ascending order
%Indx: indexes of species in descending order
%(-> 1 is the index of the smallest niche range, 10 is the index of
%the largest)
r_new = r(Indx); %the smallest r to highest index species
c_new = c(Indx);
r_new(1) = 0; %change the r of lowest index species to 0
%so we have a basal species in every web

%--------------------------------------------------------------------------
%% Construct the web adjacency matrix
%--------------------------------------------------------------------------
preymins = c_new - r_new/2; %lower border of niche range for every prey
preymaxs = c_new + r_new/2; %upper border of niche range for every predator

%% Set up matrices to find which species are eaten
n_mx = ones(num_nodes,1)*n_new'; %fills the empty matrix with niche ranges
preymins_mx = preymins*ones(1,num_nodes); %matrix with the lowest points of ranges in every column
preymaxs_mx = preymaxs*ones(1,num_nodes); %same, with highest

%% Species are prey if their niche value is in the predator's niche range
web_mx=(n_mx>=preymins_mx)&(n_mx<=preymaxs_mx);


%% If you're running the loop for the second time:
if exist('n_old','var')==1
    %% Ensure all new lifestages have prey (some fish will accidentally have such a narrow range that they don't have any prey)
    [~, fish_reordered]=intersect(Indx,givediet);%Find the new index of fish nodes, because you reordered them when you sorted by niche index
    reassign=intersect(find(sum(web_mx,2)==0),fish_reordered); %Find all fish nodes that have no prey species, need to give them food
    for i=reassign'
        n_selec=n_new;
        n_selec(i)=NaN;%Prevent fish nodes without prey from selecting themselves as prey species (cannibalism), because that would just be a simple loop, and isn't very realistic
        [~,pickyfishfood]=min(abs(n_selec-c_new(i)));%Find prey species that's the closest to the center of the new lifestage's diet. 
        web_mx(i,pickyfishfood)=1;
    end
    
    %% If you're running the loop for the second time, to get an extended food web, preserve the order of the nodes.
    keepindex(Indx)=1:num_nodes;
    web_mx=web_mx(keepindex,keepindex);
end

end