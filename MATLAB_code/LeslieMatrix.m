%--------------------------------------------------------------------------
%  Program by: Rosalyn Rael
%  Modified Apr 2011 Barbara Bauer, changed metabolic rates of basals
%  to zero (Brose et al. 2006) and rewrote some comments
%  Modified March 2012 Perrine Tonin, added distinction bewteen
%  invertebrates and fishes, stochasticity in the consumer-resource
%  body size constants Z and rewrote some comments
%  Modified November 2016 Stephanie Bland, added life history stages and rewrote
%  some comments
%--------------------------------------------------------------------------
%  Links Life Stages Using Leslie Matrix
%  Reference: 
%  Uses the following parameters:
%  nicheweb,nichewebsize,connectance,basalsp,IsFish
%--------------------------------------------------------------------------
%Leslie Matrix can change every year

%function [output]= LifeHistories(input)
function [lifehistory_table]= LeslieMatrix(S_0,newwebsize,N_stages,year)

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
for i=1:S_0
    stages=N_stages(i);%Number of fish life history stages
    if stages~=1
        aging=1*ones(1,stages-1);%length of stages-1, some sort of distribution
        fert=.5*ones(1,stages);%length of stages, some sort of distribution
        non_mature=zeros(1,stages);%Default for fish that don't mature is 0, they either mature or die.
        %NOTE!  The order of the following lines IS important!!!
        %lifehis_breed=zeros(stages);%Reset matrix from last run.
        lifehis_breed=diag(aging,-1);%Set the subdiagonal to the probability of maturing to the next stage
        lifehis_breed(1,:)=fert;%Set the first row to the fertility rate;
        lifehis_breed=lifehis_breed+diag(non_mature);%Set the diagonal to the probability of not maturing to the next stage, but staying the same age.
        %So now, incorporate it into life history table
        lifehistory_table(i:(i+stages-1),i:(i+stages-1))=lifehis_breed;
    end
end
