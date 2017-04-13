%--------------------------------------------------------------------------
% Rosalyn Rael
%  Modified Apr 2011 Barbara Bauer, changed metabolic rates of basals
%  to zero (Brose et al. 2006) and rewrote some comments
%  Modified March 2012 Perrine Tonin, added distinction bewteen
%  invertebrates and fishes, stochasticity in the consumer-resource
%  body size constants Z and rewrote some comments
%--------------------------------------------------------------------------
%  Computes Trophic Position
%  Reference: Brose et al. PNAS 2009
%  Uses the following parameters:
%  nichewebsize, nicheweb, basalsp
%--------------------------------------------------------------------------

function [T,T1,T2]= TrophicLevels(nichewebsize,nicheweb,basalsp)
    %% Shortest Path Trophic Position (T1)
    % Compute shortest path to basal species for each species.
    % Note: the matrix 'nicheweb' is oriented rows eat columns. 
    
    % Set up vector for storing values
    T1=NaN(1,nichewebsize);

    % Find all species with T1=1 -> Basal species (autotrophs)
    T1(basalsp)=1;  % Assign level 1 to basal species.
    ind=basalsp;    % Set up index to basal species

    % Assign other trophic levels.
    for j=2:nichewebsize
        [r,~]=find(nicheweb(:,ind)~=0);%Find all species that eat previous trophic level
        ind = unique(r);%Unique Index of species that consume previous trophic level.
        for i=ind'
            if isnan(T1(i)) % Don't give new values to species that already have trophic levels.
                T1(i)=j;
            end
        end 
    end

    %% Prey Averaged Trophic Position (T2)
    % Compute path-based trophic levels. (Levine 1980) 
    % C=I+Q+Q^2+Q^3+.... is a geometric series & converges -> C=(I-Q)^(-1)
    
    % Add up how many prey items each species has:
    prey=sum(nicheweb,2); %sum of each row

    % Create unweighted Q matrix. So a matrix that gives proportion of the
    % diet given by each prey species.
    Q=nicheweb./prey;  % Create unweighted Q matrix. (Proportion of predator diet that each species gives).
    Q(isnan(Q))=0;      % Set NaN values to 0. 
    
    %Calculate trophic levels as T2=(I-Q)^-1 * 1  %Levine 1980 geometric series 
    T2=(inv(eye(nichewebsize)-Q))*ones(nichewebsize,1); % Or sum over the rows "sum(A,2)"

    %% Short Weighted Trophic Position
    % Better estimate of Trophic position than T1 or T2 on their own:
    % Carscallen et al. Estimating trophic position in marine and estuarine food webs (2012)
    T=((T1+T2')/2)';

end
