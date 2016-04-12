function [localproperties]= local_properties(web,hindex,hlist)

nichewebsize=size(web,1);
C=sum(sum(web))/nichewebsize^2;

predsp=find(web(:,hindex)==1); %predators of the harvested species
preysp=find(web(hindex,:)==1); %preys of the harvested species
basalsp = find(sum(web,2)==0 & sum(web)'>0); %basal species (at least one predator)
nichewithoutcan=max(web-eye(nichewebsize),zeros(nichewebsize)); %
neighbours=find(nichewithoutcan(hindex,:)'==1 | nichewithoutcan(:,hindex)==1); %preds & preys

if length(predsp)==1 & predsp(1)==hindex
    Top=1;
elseif isempty(predsp)
    Top=1;
else
    Top=0;
end


Int=logical(length(predsp)~=0 && length(preysp)~=0);
Can=web(hindex,hindex);

Herb=logical(sum(web(hindex,:))==sum(web(hindex,basalsp))); %=1 if eats only basalsp

Vi=length(predsp); %Vulnerability
Gi=length(preysp); %Generality
Ci=Gi+Vi;          %Connectivity

betweenneighbours=web(neighbours,neighbours);              % submatrix of only hindex's species neighbours
Clusti=length(find(betweenneighbours==1))/length(neighbours)^2; % Clustering coeff

%Trophic similarity between the three species to harvest
    
    compred=find(web(:,hlist(1))==1 & web(:,hlist(2))==1); % predators in common
    comprey=find(web(hlist(1),:)==1 & web(hlist(2),:)==1); % preys in common
    totpred=find(web(:,hlist(1))==1 | web(:,hlist(2))==1); % total of predators
    totprey=find(web(hlist(1),:)==1 | web(hlist(2),:)==1); % total of preys
    TrophSim12=(length(compred)+length(comprey))/(length(totpred)+length(totprey));

    compred=find(web(:,hlist(3))==1 & web(:,hlist(2))==1); % predators in common
    comprey=find(web(hlist(3),:)==1 & web(hlist(2),:)==1); % preys in common
    totpred=find(web(:,hlist(3))==1 | web(:,hlist(2))==1); % total of predators
    totprey=find(web(hlist(3),:)==1 | web(hlist(2),:)==1); % total of preys
    TrophSim23=(length(compred)+length(comprey))/(length(totpred)+length(totprey));

    compred=find(web(:,hlist(1))==1 & web(:,hlist(3))==1); % predators in common
    comprey=find(web(hlist(1),:)==1 & web(hlist(3),:)==1); % preys in common
    totpred=find(web(:,hlist(1))==1 | web(:,hlist(3))==1); % total of predators
    totprey=find(web(hlist(1),:)==1 | web(hlist(3),:)==1); % total of preys
    TrophSim13=(length(compred)+length(comprey))/(length(totpred)+length(totprey));

    clear compred comprey totpred totprey;

%Generality, vulnerability and connectivity of the preys
    GenPrey=[];
    VulPrey=[];
    ConPrey=[];
    for i=1:length(preysp)
        Vpi=length(find(web(:,preysp(i))==1));
        Gpi=length(find(web(preysp(i),:)==1));
        VulPrey=[VulPrey Vpi];
        GenPrey=[GenPrey Gpi];
        ConPrey=[ConPrey Vpi+Gpi];
    end
    GenMeanPrey=mean(GenPrey);
    GenSTDPrey=std(GenPrey);
    VulMeanPrey=mean(VulPrey);
    VulSTDPrey=std(VulPrey);
    ConMeanPrey=mean(ConPrey);
    ConSTDPrey=std(ConPrey);
    
%Generality, vulnerability and connectivity of the predators
    if isempty(predsp)
        GenMeanPred=0;
        GenSTDPred=0;
        VulMeanPred=0;
        VulSTDPred=0;
        ConMeanPred=0;
        ConSTDPred=0;
    else
        GenPred=[];
        VulPred=[];
        ConPred=[];
        for i=1:length(predsp)
            Vpi=length(find(web(:,predsp(i))==1));
            Gpi=length(find(web(predsp(i),:)==1));
            VulPred=[VulPred Vpi];
            GenPred=[GenPred Gpi];
            ConPred=[ConPred Vpi+Gpi];
        end
        GenMeanPred=mean(GenPred);
        GenSTDPred=std(GenPred);
        VulMeanPred=mean(VulPred);
        VulSTDPred=std(VulPred);
        ConMeanPred=mean(ConPred);
        ConSTDPred=std(ConPred);
    end
    
localproperties=[Top Int Can Herb Vi Gi Ci Clusti TrophSim12 TrophSim23 TrophSim13 ...
    GenMeanPrey GenSTDPrey VulMeanPrey VulSTDPrey ConMeanPrey ConSTDPrey ...
    GenMeanPred GenSTDPred VulMeanPred VulSTDPred ConMeanPred ConSTDPred];
        
        