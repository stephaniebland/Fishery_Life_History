%% Calculate Prob of Maturity and invest

function [reprod]=prob_of_maturity(prob_mat,nichewebsize,is_split,N_stages,species,year)
attach(prob_mat);
global reprod;

reprod=zeros(nichewebsize,1);
for j=find(is_split')
    stages=N_stages(j);
    %% Probability of Maturity (P)
    a50 = starta50*(1- 0.005)^year;% a50 is age at which 50 reach maturity
    sumL = 1 + exp(-3*((2:stages)-a50));
    P =[0, 1./sumL];
    mature_reprod=1-invest(1:stages);%percent invested in reproduction
    reprod(find(species==j))=P.*mature_reprod;
end

end