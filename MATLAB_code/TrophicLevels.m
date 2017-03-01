%--------------------------------------------------------------------------
% Rosalyn Rael
%  Modified Apr 2011 Barbara Bauer, changed metabolic rates of basals
%  to zero (Brose et al. 2006) and rewrote some comments
%  Modified March 2012 Perrine Tonin, added distinction bewteen
%  invertebrates and fishes, stochasticity in the consumer-resource
%  body size constants Z and rewrote some comments
%--------------------------------------------------------------------------
%  Computes Trophic Levels
%  Reference: Brose et al. PNAS 2009
%  Uses the following parameters:
%  nichewebsize, nicheweb, basalsp
%--------------------------------------------------------------------------

function [T, T1,T2]= TrophicLevels(nichewebsize,nicheweb,basalsp)


%--------------------------------------------------------------------------
%Convert nicheweb to a numeric array and eliminate self-loops. (Eliminating
%Cannibalism within life stages, so cannibalism is allowed between
%different life stages).
%--------------------------------------------------------------------------
    nicheweb1=+nicheweb;  %I really don't know why I'm including this line (except they seemed to like it up there...  does that do something special to matrices, am I missing something....?)  Possibly vestigial line from C++
    nicheweb1=nicheweb1-diag(diag(nicheweb1));%Set the diagonal to 0.


%--------------------------------------------------------------------------
%Compute shortest path to basal species for each species.
%Note: the matrix 'nicheweb' is oriented rows eat columns. 
%--------------------------------------------------------------------------
    T1=NaN(1,nichewebsize);

    %Compute shortest trophic level.
    T1(basalsp)=1;  % Assign level 1 to basal species.
    ind=basalsp;    % Set up index to basal species

    % Assign other trophic levels.
    for j=2:nichewebsize
        [r,~]=find(nicheweb1(:,ind)~=0);%Find all species that eat previous trophic level
        ind = unique(r);%Unique Index of species that consume previous trophic level.
        for i=ind'
            if isnan(T1(i)) % Don't give new values to species that already have trophic levels.
                T1(i)=j;
            end
        end 
    end

%--------------------------------------------------------------------------
%Compute path-based trophic levels. (Levine 1980)
%--------------------------------------------------------------------------

    %Add up how many prey items each species has.
    prey=sum(nicheweb1,2); %sum of each row

    %Create unweighted Q matrix. So a matrix that gives proportion of the
    %diet given by each prey species.
    prey=max(prey,1);   % So that you don't divide by 0.
    Q=nicheweb1./prey;  % Create unweighted Q matrix. (Proportion of predator diet that each species gives).
    
    %Calculate trophic levels as T2=(I-Q)^-1 * 1  %StephHWK: I may need to come back to this one...
    T2=(inv(eye(nichewebsize)-Q))*ones(nichewebsize,1);%"ones(nichewebsize,1)" or could just sum over the rows like you did everywhere else "sum(A,2)"
    
%--------------------------------------------------------------------------
%Average T1 and T2  %And how is using the average even a good idea?  Why
%not just choose favourite instead saying "both are equally valid, so we'll
%take the most moderate approach."
%--------------------------------------------------------------------------
    T=((T1+T2')/2)';%So after looking into this a bit, I think that T2 is the way to go.  It's more consistent with the defn' for trophic level used by fishbase.org It might be useful to calculate the trophic levels again at the end once you know equilibrium densities. 

    end
