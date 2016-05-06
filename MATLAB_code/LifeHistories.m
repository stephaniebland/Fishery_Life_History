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
%  Assigns Lif History Stages
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
function [nicheweb_new,lifehistory_table,Mvec,IsFish]= LifeHistories(nicheweb,nichewebsize,connectance,basalsp)

%%-------------------------------------------------------------------------
%%  FIRST: SET DYNAMICS PARAMETERS
%%-------------------------------------------------------------------------
%Calculates species weight -> so you know how many life stages it needs
%"meta", "TrophLevel" & "T1", "IsFish" and "Z"
    [TrophLevel,T1]= TrophicLevels(nichewebsize,nicheweb,basalsp);
    [Z,Mvec,IsFish]= metabolic_scaling(nichewebsize,basalsp,TrophLevel);

%%-------------------------------------------------------------------------
%%  NUMBER OF LIFESTAGES
%%-------------------------------------------------------------------------
%Calculate Life history mass for all fish species
%Assume all fish start as eggs, which are no bigger than Max_egg_size
%Can change Max_egg_size later to random variable or set fixed number of
%fish stages instead...
Max_egg_size=100;%I don't have any justification for this number yet.
% Max_egg_length=10;%I don't have any justification for this number yet.
lifestage_mass=Mvec.*isfish;% You only want to add lifestages to fish
% lifestage_length=lifestage_mass;
% length8=1.5*lifestage_length;%Asymptotic length (8 is mnemonic for infinty symbol)
%Create a matrix lifestage_Mass that describes the weight of each life stage j
%for each fish i (so fish species are in rows, and lifestages are in
%columns.
for i=1:nichewebsize
    j=1;
    while lifestage_mass(i,j)>Max_egg_size
        lifestage_mass(i,j+1)=lifestage_mass(i,j)/16;%INSERT VON-BERT HERE!!!
        j=j+1;
    end
    lifestage_N(i,1)=j;%Number of lifestages for each species
end

randm_var=1;
q=1;%q is the conversion factor from length to weight.  so W=q*L^3
mass_asympt=10^(3*0.044).*10.^(3.*randm_var).*q^(1-0.9841).*lifestage_mass.^0.9841;%Adapted from Froese, R. and C. Binohlan. 2000.  (Equation 5)

%Current problem:  Linf is in units of cm, mass_asympt is in units of who
%knows what..

log10(mass_asympt)
for i=1:nichewebsize
    j=1;
    while mass_history(i,j)<lifestage_mass(i,1)
        %K=10^(-0.289754018 -0.003208122*mass_asympt(i)+normrnd(0,1));
        Linf=(mass_asympt(i)/q)^(1/3);%ERROR  NOT SURE ABOUT UNITS!  I'm pretty sure it's grams to cm.  what units is mass_asympt in?
        K=10^(0.5182928-0.6579250*log10(Linf)+normrnd(0,0.224824));
        mass_history(i,j+1)=mass_asympt(i)*(1-exp(-K(t-t0)))^3;%INSERT VON-BERT HERE!!!
        j=j+1;
    end
    lifestage_N(i,1)=j;%Number of lifestages for each species
end






for i=1:nichewebsize
    j=1;
    k=0.1;%units [per year], fake trial coefficient
    L0=5;%units [cm], fake trial coefficient
    while lifestage_mass(i,j)>Max_egg_size
        lifestage_mass(i,j+1)=lifestage_mass(i,j)/16;%INSERT VON-BERT HERE!!!
        %lifestage_length(i,j+1)=
        j=j+1;
    end
    lifestage_N(i,1)=j;%Number of lifestages for each species
end



%Suppose you have a fish with 4 life stages.  Then you can create a
%lifehistory matrix for it.  Find correlations from Hutchings, J. A., Myers, R. A., García, V. B., Lucifora, L. O., & Kuparinen, A. (2012). Life-history correlates of extinction risk and recovery potential. Ecological Applications, 22(4), 1061–1067. Retrieved from http://www.esajournals.org/doi/abs/10.1890/11-1313.1
%This relates age at maturity, max litter size, and weight to growth rate.
%But since both weight and age are fixed, well, you could either adjust age
%accordingly (you just calculated age). Are you sure you want to use this,
%or is there something better?

%Fish life history tables:  Creates a Leslie matrix where aij is the contribution of life stage j to life stage i.
lifehistory_table=eye(sum(lifestage_N));%Identity Matrix for life history table, so non-fish are untransformed by matrix
temp_index=nichewebsize;
for i=1:nichewebsize
    stages=lifestage_N(i);%Number of fish life history stages
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
        lifehistory_table([i,temp_index+(1:stages-1)],[i,temp_index+(1:stages-1)])=lifehis_breed;
        temp_index=temp_index+stages-1;
    end
end

[nicheweb_new] = NicheModel(sum(lifestage_N), connectance);
%ERROR!!!!  Need to make sure NicheModel knows what to work with!  You
%would like it to use the fish mass indirectly to determine food chain!
nicheweb_new(1:nichewebsize,1:nichewebsize)=nicheweb;

end




