%--------------------------------------------------------------------------
% Program by: Perrine Tonin and Coralie Picoche
% Ref: Dunne et al., PLOS Biology, 2008.
%      Williams and Martinez, Journal of Animal Ecology, 2008.
%      Williams and Martinez, Nature, 2000.
%--------------------------------------------------------------------------
% This function takes a niche web matrix in input
% (rows eat columns) and calculates the 17 properties
% of a niche web:
% Top      Int     Bas     Herb    Can     Omn
% Loop     ChLen   ChSD    ChNum   TL
% MaxSim   VulSD   GenSD   LinkSD
% Path     Clust
%--------------------------------------------------------------------------

function [nicheproperties]= web_properties(nicheweb,T1,T)

nichewebsize = length(nicheweb);  % number of species
numberlinks  = length(find(nicheweb==1)); % L: number of links in the foodweb


% Top, Bas, Int and Can coefficients
%--------------------------------------------------------------------------
    nichewithoutcann=nicheweb; %removes cannibalism
    for i=1:nichewebsize
        nichewithoucann(i,i)=0;
    end
    topsp = find(sum(nichewithoutcann,1)==0);   % indices of top species (no pred besides themselves)

    basalsp = find(sum(nicheweb,2)==0); % indices of basal species
    cansp = find(diag(nicheweb)==1);    % indices of top species

    Bas=length(basalsp)/nichewebsize;   % percentage of basal species
    Top=length(topsp)/nichewebsize;     % percentage of top species
    Int=1-Top-Bas;         % percentage of intermediate species
    Can=length(cansp)/nichewebsize;     % percentage of cannibal species


% Herb coefficient
% = species eating only at basal level
%--------------------------------------------------------------------------
    eatingbasalsp=find(sum(nicheweb(:,basalsp),2)>0);    % indices of all species eating basal
    nonbasalsp=find(sum(nicheweb,2)>0);                  % indices of non basal
    nonbasalpreys=nicheweb(eatingbasalsp,nonbasalsp);    % matrix rows=eating basal species / col=non basal species
    herbsp=eatingbasalsp(find(sum(nonbasalpreys,2)==0)); % indicies of herbivore species
    Herb=length(herbsp)/nichewebsize;


% MaxSim coefficient
% mean of the maximum similarity between species
%--------------------------------------------------------------------------
    Sij=zeros(nichewebsize); % matrix of the trophic similarities
    for i=1:nichewebsize
        for j=1:nichewebsize % or j=1:i-1 ???
            if i~=j
                compred=find(nicheweb(:,i)==1 & nicheweb(:,j)==1); % predators in common
                comprey=find(nicheweb(i,:)==1 & nicheweb(j,:)==1); % preys in common
                totpred=find(nicheweb(:,i)==1 | nicheweb(:,j)==1); % total of predators
                totprey=find(nicheweb(i,:)==1 | nicheweb(j,:)==1); % total of preys
                Sij(i,j)=(length(compred)+length(comprey))/(length(totpred)+length(totprey));
            end
        end
    end
    MaxSim=sum(max(Sij,[],2))/nichewebsize;


% VulSD GenSD and LinkSD coefficients
% variability of the vulnerability (ie number of predators),
% the generality (ie number of preys) and connectivity (total)
%--------------------------------------------------------------------------
    Vul=nichewebsize/numberlinks.*sum(nicheweb);
    Gen=nichewebsize/numberlinks.*sum(nicheweb,2)';
    VulSD=std(Vul);
    GenSD=std(Gen);
    LinkSD=std(Vul+Gen);


% Clust coefficient
%--------------------------------------------------------------------------
    Clustvec=zeros(1,nichewebsize);
    nichewithoutcan=max(nicheweb-eye(nichewebsize),zeros(nichewebsize)); % to prevent counting cannibal species as their own neighbour --> should we do that?
    for v=1:nichewebsize
        neighbours=find(nichewithoutcan(v,:)'==1 | nichewithoutcan(:,v)==1);   % indices of species v neighbours (prey & pred)
        kv=length(neighbours);                                  % number of neighbours of v's species
        betweenneighbours=nicheweb(neighbours,neighbours);      % submatrix of only v's species neighbours
        Clustvec(v)=length(find(betweenneighbours==1))/kv^2;    % Clustering coeff for species v
    end
    Clust=mean(Clustvec);


% Path
% mean shortest path between two species
% Floyd-Warshall algorithm
%--------------------------------------------------------------------------
    niche_nonoriented=max(nicheweb,nicheweb');                  % symetrization of the nicheweb
    pathmat=-10^6.*(niche_nonoriented-1)+niche_nonoriented;    % assign high values where there is no link
    for k=1:nichewebsize
        for i=1:nichewebsize
            for j=1:nichewebsize
                pathmat(i,j)=min(pathmat(i,j),pathmat(i,k)+pathmat(k,j));
            end
        end
    end
    pathmat=triu(pathmat); % to keap only pairs of species (clust(i,j)=clust(j,i))
    Path=mean(pathmat(pathmat~=0));


% Omn --> fraction of species which consum at least two species and have
% food chains of different lengths
%--------------------------------------------------------------------------
    Tb=repmat(T1,nichewebsize,1).*nicheweb; %on each row, shortest trophic level of the consumed species
    Omniv=0;
    for j=nonbasalsp
        if length(unique((Tb(nonbasalsp,:))))>1 %different shortest trophic levels on the same row : omniv
            Omniv=Omniv+1;
        end
    end
    Omniv=Omniv/nichewebsize;


% Loop  --> fraction of species involved in loops (longer than 1 species
%           loops = cannibalism)
% ChLen --> Mean Length of a food chain (that is, links from any species
%           to a basal species), averaged for all species
% ChNum --> Log of number of food chains (without loops)
%--------------------------------------------------------------------------
    Loop=[]; %list of species involved in loops
    tmp=nichewithoutcan;
    m=zeros(length(nonbasalsp),length(nonbasalsp));
    chLen=0;
    chNum=0;
    nichewithoutloop=nichewithoutcan;
    for i=1:length(nonbasalsp) %path of length i
        loop_here=[];
        for j=1:length(nonbasalsp) %only the non basal species can eat other species
            if tmp(nonbasalsp(j),nonbasalsp(j))>0 %there's a loop of length i involving j
                Loop=[Loop nonbasalsp(j)];
                loop_here=[loop_here nonbasalsp(j)];
            end
        end
        nichewithoutloop(loop_here,loop_here)=0;
        tmp=tmp*nichewithoutcan;
    end
    tmp=nichewithoutloop;
    for i=1:length(nonbasalsp) %path of length i
        for j=1:length(nonbasalsp) %only the non basal species can eat other species
            s=sum(tmp(nonbasalsp(j),basalsp)); %number of chains of length i involving j
            m(j,i)=m(j,i)+s;
            chLen=chLen+s*i;
            chNum=chNum+s;
        end
        tmp=tmp*nichewithoutloop;
    end

    Loop=length(unique(Loop))/nichewebsize;
    chLen=chLen/chNum;
    chNum=log(chNum);


% ChSD --> Standard Deviation of ChLen
%--------------------------------------------------------------------------
    chSD=0;
    for k=1:length(nonbasalsp) %for each non basal species
        p=0; %chain length
        num=0; %number of chains
        for l=1:length(nonbasalsp)
            p=p+l*m(k,l);
            num=num+m(k,l);
        end
        if num==0
            chSD=chSD+chLen^2;
        else
            chSD=chSD+(p/num-chLen)^2;
        end
    end
    chSD=sqrt(chSD/(nichewebsize-1));


% TL --> mean Trophic Level
%--------------------------------------------------------------------------
    TL=mean(T); %should be from metabolic scaling


% Save all the properties
%--------------------------------------------------------------------------
nicheproperties=[Top,Int,Bas,Can,Herb,MaxSim,VulSD,GenSD,LinkSD,Clust,Path,Omniv,Loop,chLen,chNum,chSD,TL];

