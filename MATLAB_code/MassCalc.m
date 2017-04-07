%--------------------------------------------------------------------------
% Rosalyn Rael
%  Modified Apr 2011 Barbara Bauer, changed metabolic rates of basals
%  to zero (Brose et al. 2006) and rewrote some comments
%  Modified March 2012 Perrine Tonin, added distinction bewteen
%  invertebrates and fishes, stochasticity in the consumer-resource
%  body size constants Z and rewrote some comments
%--------------------------------------------------------------------------
%  Computes metabolic rates allometrically
%  Reference: Brose et al. PNAS 2009
%  Uses the following parameters:
%  nichewebsize, basalsp, isfish, T
%--------------------------------------------------------------------------

% uncomment if to use as a function
function [Z,Mvec,isfish,W_scaled,W_scalar]= MassCalc(masscalc,nichewebsize,nicheweb,basalsp,T)
attach(masscalc);
%--------------------------------------------------------------------------
%Fish or invertebrate
%--------------------------------------------------------------------------
    isfish=zeros(nichewebsize,1);
    % distinction between invertebrates and fishes
    if isnan(num_orig_fish)
        possibfish=find(T>=3);                % species with TL<3 are always invertebrates
        bernoulli=rand(length(possibfish),1);
        bernoulli=logical(bernoulli<=.6);     % for species with TL>=3, probability of 60% of being a fish
        isfish(possibfish)=bernoulli; %That's clever...
    else
        %Alternatively, just choose top three "most fish-like" species to be fish
        [~, fishiness]=sort(T);%Rank species by how fish like they are.  This only chooses top 3, but some could have trophic levles < 3 still.
        isfish(fishiness(end-num_orig_fish+1:end))=1;%Choose top three species to be fish
    end
        
%--------------------------------------------------------------------------
%Constant consumer-resource body size
%--------------------------------------------------------------------------
    % Follows a lognormal distribution with different means and standard
    % deviation for invertebrates and fishes (Brose et al, 2006)
    
    % mean and standard deviation of the associated normal distributions
    mu_fish=log(m_fish^2/sqrt(v_fish+m_fish^2));
    mu_invert=log(m_invert^2/sqrt(v_invert+m_invert^2));
    sigma_fish=sqrt(log(v_fish/m_fish^2+1));
    sigma_invert=sqrt(log(v_invert/m_invert^2+1));
    
    %Consumer-resource body-size
    Z=lognrnd(mu_invert,sigma_invert,nichewebsize,1);
    Z(find(isfish))=lognrnd(mu_fish,sigma_fish,length(find(isfish)),1);
    Z(basalsp)=1;

%--------------------------------------------------------------------------
%Set body size based on trophic level
%--------------------------------------------------------------------------
    %% Calculate Mass according to T1 (Shortest Distance)
    % * MATLAB PUBLISH FEATURE MAKES THIS SECTION READABLE.
    % * This section is split into two parts. 
    % * Start with a weighted graph $A$, where $a_{ij}$ indicates the allometric ratio of the edge from node $i$ to $j$. (so the allometric relationship between species i and j. 
    A=nicheweb.*Z;              %Setup weighted nicheweb matrix - this is like the standard matrix used for Dijkstra algorithm, except weights represent allometric scaling instead of edge length (so multiplicative instead of additive)

    Mass1=NaN(nichewebsize,1);	% Set up vector
    old_Mass1=Mass1;            % Set up a vector to track changes in mass - we will run the loop until mass is constant
    A(basalsp,basalsp)=exp(0);	% Set up a loop between the source and itself of distance 0, so that the source gets it's energy from themselves.
    Mass1(basalsp)=Z(basalsp);	% Basal species defined to have mass equivalent to Z (1 if nothing changes)

    
    %% The While Loop: Assign Mass for Non Basal Species
    % * YES, *of course* you can use same method with Z=[1 1 ...1] for calculating Trophic levels T1, and it's prob cleaner, but both methods work. 
    % * "distance" here is mass, s=source=basal species... I wrote this
    % trying to generalize to standard shortest distance models... for more
    % info find file "Shortest_Path.m" on branch
    % "Prepare-to-Merge-(shortest-path)" in the git repository for this
    % code. In short, this method is an amalgamation of Dijkstra's and
    % Floyd-Marshall, it's not as powerful or fast as either, but it's
    % easiest (for me) to understand. The steps below are as follows:
    % * This loops until distance is constant. This method guarantees that we
    % will find the shortest distance $d_{i}$. Proof by induction: If there is
    % a shorter path between node $i$ and $s$, it will need to go through node 
    % $j$ first, so the shortest distance for node $j$ would need to change in 
    % the previous loop.
    % * Update the vector to keep track of changes in distance. We will
    % continue to loop until distance is constant.
    % * Find a matrix 
    %
    % $C=A\times  \pmatrix{e^{d_1} &&&  \cr
    %                       & e^{d_2} && \cr
    %                       && \ddots  & \cr
    %                       &&& e^{d_n} \cr}$
    % 
    % Of course for the first few rounds, $e^{d_i}=0$ for almost all $i$. Each
    % round we will add more known values to this. So the log of element 
    % $c_{ij}$ is the shortest known distance between nodes $i$ and $s$ that 
    % goes through node $i$'s neighbour, $j$. This is because $b_{ij}$ is the
    % log of the distance between node $i$ and it's neighbour, $j$, and
    % $e^{d_j}$ is the shortest known distance between $j$ and s. So
    % $c_{ij}=b_{ij}e^{d_j}=e^{a_{ij}}e^{d_j}=e^{a_{ij}+d_j}$. So the log of
    % $c_{ij}$ is: $\log c_{ij}=\log e^{a_{ij}+d_j}=a_{ij}+d_j$, which is the
    % shortest distance between $i$ and $s$, calculated with the shortest known
    % value for $d_j$. Every time you run this loop you will update the
    % distance for the neighbouring nodes, so eventually it will optimize,
    % provided:
    %
    % all distances are positive OR there are no loops. 
    %%
    % * Correct for 0 values: $c_{ij}=0$ for distances you have not calculated
    % yet, so we will set them NaN for now so we don't mistake them for the
    % shortest distance. 
    % * We need to find the shortest distance, so we need to find the smallest
    % known distance between node i and the source. So updated the distance
    % vector with $e^{d_i}=\min_{j}c_{ij}$.
    while sum(old_Mass1~=Mass1)~=0  % Iterate the loop until distance no longer changes
        old_Mass1=Mass1;            % Keep track of changes in distance. We loop until this is constant, meaning we found the shortest distance. 
        C=A*diag(Mass1);            % Find shortest paths - so log(c_ij) is the distance between the source and node i, if we take the shortest route through i's neighbour (j). 
        C(C==0)=NaN;                % Don't mistake 0s for shortest path. (since log(0) is -infinity, it doesn't make sense to use them)
        Mass1=min(C,[],2);          % Find shortest path (We excluded 0s, so it's the second smallest element in each row of matrix C)
    end
    
    %% Plot the Matrix: If you want to see that the equations are working. 
    % Don't worry about the code here; it just gives you a visualization of
    % what was calculated just uncomment this section.
%     d=string(Mass1);
%     ids=strcat('i=',string(1:nichewebsize),', d= ',d');
%     ids=cellstr(ids);
%     bg2 = biograph(A,ids,'ShowWeights','on');
%     view(bg2);

    %% Calculate Mass according to T2 (Prey-Averaged Trophic Position)
    prey=sum(nicheweb,2); %sum of each row
    Q=nicheweb./prey;  % Create unweighted Q matrix. (Proportion of predator diet that each species gives).
    Q(isnan(Q))=0; 
    I=eye(nichewebsize);
    K=ones(nichewebsize,1);
    
    Mass2=(K*Z').^(inv(I-Q));
    Mass2=prod(Mass2,2);
    
    %% Combine the two calculations of Mass Z^T, where T=(T1+T2)/2.  {side note: previous calculations use Z^(T-1). That's not appropriate here, because autotrophs have mass=1, and this system takes weight of all items in it's food chain into account. The previous system assumed they all have weight of the predator in question, so the autotroph would have the same size as whatever it's being eaten by - clearly not great!}
    Mvec=sqrt(Mass1.*Mass2);
    
%--------------------------------------------------------------------------
%Scale mass so that von-bert function works
%--------------------------------------------------------------------------
switch maxweight
    case false %Don't scale the weight if maxweight is set to false.
        W_scaled=Mvec;
    otherwise
        %Calculate Life history mass for all fish species
        W_scalar=max(Mvec)/maxweight;%Factor by which you can scale all the weights, so that the maximum fish weight is *exactly* the denominator.  So every ecosystem will always have top predator that weighs exactly that amount (unless it goes extinct)
        %May want to consider adding some stochasticity to this scalar.
        W_scaled=Mvec/W_scalar;%Scale the weight of all species
end
    
    end
