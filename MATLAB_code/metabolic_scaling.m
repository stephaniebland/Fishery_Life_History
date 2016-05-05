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
%  nichewebsize, nicheweb, basalsp
%--------------------------------------------------------------------------

% uncomment if to use as a function
function [meta, T, T1, isfish, Z]= metabolic_scaling(nichewebsize,nicheweb,basalsp)


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
    T1=zeros(1,nichewebsize);

    %Compute shortest trophic level.
    %Assign level 1 to basal species.
    T1(basalsp)=1;
    ind=basalsp;

    % Assign other trophic levels.
    r = 0;
    for j=2:nichewebsize
        clear col r;
        [r,col]=find(nicheweb1(:,ind)~=0);
        clear ind;
        ind = unique(r);
        for i=1:length(ind)
            if T1(ind(i))==0
                T1(ind(i))=j;
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
    a=nicheweb1';
    Q = zeros(nichewebsize);
    for i=1:nichewebsize
        for j=1:nichewebsize
        if prey(j) ~= 0
            Q(i,j) = a(i,j)/prey(j); 
            end
        end
    end
    
    %Calculate trophic levels as T2=(I-Q)^-1 * 1  %StephHWK: I may need to come back to this one...
    T2=(inv(eye(nichewebsize)-Q'))*ones(nichewebsize,1);%"ones(nichewebsize,1)" or could just sum over the rows like you did everywhere else "sum(A,2)"
    
%--------------------------------------------------------------------------
%Average T1 and T2  %And how is using the average even a good idea?  Why
%not just choose favourite instead saying "both are equally valid, so we'll
%take the most moderate approach."
%--------------------------------------------------------------------------
    T=((T1+T2')/2)';%So after looking into this a bit, I think that T2 is the way to go.  It's more consistent with the defn' for trophic level used by fishbase.org It might be useful to calculate the trophic levels again at the end once you know equilibrium densities. 

%--------------------------------------------------------------------------
%Fish or invertebrate
%--------------------------------------------------------------------------
    % distinction between invertebrates and fishes
    isfish=zeros(nichewebsize,1);
    possibfish=find(T>=3);                % species with TL<3 are always invertebrates
    bernoulli=rand(length(possibfish),1);
    bernoulli=logical(bernoulli<=.6);     % for species with TL>=3, probability of 60% of being a fish
    isfish(possibfish)=bernoulli; %That's clever...
    
%--------------------------------------------------------------------------
%Constant consumer-resource body size
%--------------------------------------------------------------------------
    % Follows a lognormal distribution with different means and standart
    % deviation for invertebrates and fishes (Brose et al, 2006)
    
    m_fish   =5000;  % mean for fishes
    v_fish   =100;   % standart deviation for fishes
    
    m_invert =100;   % mean for invertebrates
    v_invert =100;   % standart deviation for invertebrates
    
    % mean and standard deviation of the associated normal distributions
    mu_fish=log(m_fish^2/sqrt(v_fish+m_fish^2));
    mu_invert=log(m_invert^2/sqrt(v_invert+m_invert^2));
    sigma_fish=sqrt(log(v_fish/m_fish^2+1));
    sigma_invert=sqrt(log(v_invert/m_invert^2+1));
    
    %Consumer-resource body-size
    Z=lognrnd(mu_invert,sigma_invert,nichewebsize,1);
    Z(find(isfish==1))=lognrnd(mu_fish,sigma_fish,length(find(isfish==1)),1);

%--------------------------------------------------------------------------
%Set body size based on trophic level and calculate metabolic rates
%--------------------------------------------------------------------------
    Mvec = zeros(nichewebsize,1); %mass per individual
    Mvec=Z.^(T-1);  %T-1 used since basal level is 1.

%     %%Metabolic scaling constants  %%%No longer used
%     a_r = 1;
%     a_x= 0.314; %Berlow et al. 2009
%     a_y = 8*a_x;  %% note 8 is the y_ij

    % Allometric scaling exponent (Boit et al. in prep.)
    A_fish=0.11;
    A_invert=0.15;

    %Metabolic and mass assimilation rates
    meta=zeros(nichewebsize,1);
    for i=1:nichewebsize
        if ismember(i,basalsp)
            meta(i)=0;% Brose et al 2006 , was set to .138 before;  %metabolic rate for producers
        elseif isfish(i)
            meta(i) = .88*(1./(Mvec(i)) ).^A_fish;%metabolic rate for etcotherm vertebrates
        else
            meta(i) = .314*(1./(Mvec(i)) ).^A_invert; %metabolic rate for invertebrates
        end
    end
