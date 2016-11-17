%--------------------------------------------------------------------------
% Program by:  Rosalyn Rael
% Modified by Barbara Bauer & Perrine Tonin & Stephanie Bland
% Last modifications November 2016
%--------------------------------------------------------------------------
% This file records simulation and food web properties.
%--------------------------------------------------------------------------

%% Vectors of length S_0 (number of species)
% n_new,c_new,r_new don't change
% T1_old',T2_old Trophic levels change with a new foodweb
% Z_old should be saved because I don't know if I will change Z for new nodes yet.
% Mvec_old Save old mass because you scale it before applying lifehistory
l10_Mvec=log10(Mvec_old);%Calculate now because it's more accurate this way
ln_Mvec=log(Mvec_old);
orig_vec=[n_new,c_new,r_new,T1_old',T2_old,Z_old,Mvec_old,l10_Mvec,ln_Mvec,N_stages];

%% Vectors of length nichewebsize (number of nodes)
% B_orig I don't know how much it will change in the first time step of ODE
% T1,T2 Changes for new nicheweb
% meta,Z,Mass Obvious
l10_Mass=log10(Mass');%Calculate now because it's more accurate this way
ln_Mass=log(Mass');
% orig_nodes',species',N_stages Probably not necessary to have all of these, but I don't care
new_vec=[B_orig,T1',T2,meta,Z',Mass',l10_Mass,ln_Mass,orig_nodes',species',isfish,lifestage];

%% Variables
variables=[S_0,connectance,nan_error,];

%% Other things to store
% nicheweb
% nicheweb_old %because it's way too complicated to figure out original fish diet, since I don't know how I'm going to split it yet.  Might as well guarantee accuracy for something as important as this.
sim_run=[year_index,full_t,full_sim];
% adj_list

%% Things you can calculate later, and computationally inexpensive
% basalsp
% Top species (species without predators - but if you split into life histories more species will have predators!)
% TrophLevel=(T1'+T2)/2
% isfish_old=isfish(find(orig_nodes))
% Cannibals, Herbivores, Omnivores


%% Remember to store
% Parameters for lifehistory_table (deterministic)



