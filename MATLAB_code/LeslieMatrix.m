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

function [aging_table,fecund_table]= LeslieMatrix(leslie,newwebsize,N_stages,is_split,species)
attach(leslie); 

%%-------------------------------------------------------------------------
%%  LIFE HISTORY MATRIX - LESLIE MATRIX
%%-------------------------------------------------------------------------
%Suppose you have a fish with 4 life stages.  Then you can create a
%lifehistory matrix for it.  Find correlations from Hutchings, J. A., Myers, R. A., García, V. B., Lucifora, L. O., & Kuparinen, A. (2012). Life-history correlates of extinction risk and recovery potential. Ecological Applications, 22(4), 1061–1067. Retrieved from http://www.esajournals.org/doi/abs/10.1890/11-1313.1
%This relates age at maturity, max litter size, and weight to growth rate.
%But since both weight and age are fixed, well, you could either adjust age
%accordingly (you just calculated age). Are you sure you want to use this,
%or is there something better?


%% Fish life history tables:  Creates a Leslie matrix where aij is the contribution of life stage j to life stage i.
aging_table=eye(newwebsize);%Identity Matrix for aging table, so non-fish are untransformed by matrix
fecund_table=zeros(newwebsize);
for i=find(is_split')%Only change values for fish with life histories.
    stages=N_stages(i);%Number of fish life history stages
    if stages~=1
        aging=1*ones(1,stages-1);%length of stages-1, some sort of distribution
        non_mature=[zeros(1,stages-1), 1-forced];%Keeps last life history stage alive.
        fish_index=find(species==i);
        %% Split lifehistory_table into two matrices, where aging_table+fecund_table=lifehistory_table. This way you can multiply fecund_table by additional factors.
        %NOTE!  The order of the following lines IS important!!!
        fecund_table(fish_index(1),fish_index)=1;%First row is just ones, because will calculate reproductive investment later separately
        %aging_table(fish_index,fish_index)=diag(aging,-1)+diag(non_mature);%Set the subdiagonal to the probability of maturing to the next stage %Set the diagonal to the probability of not maturing to the next stage, but staying the same age.
        %aging_table(fish_index(1),fish_index(end))=forced;%forced are the adults that reproduce in their final year.
        aging_table(fish_index,fish_index)=diag(0.1*ones(1,stages))+diag(0.9*ones(1,stages-1),-1);
        aging_table(fish_index(1),fish_index(end))=0.9;
    end
end

end
