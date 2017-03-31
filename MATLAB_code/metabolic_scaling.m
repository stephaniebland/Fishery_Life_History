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
function [meta,Z]= metabolic_scaling(meta_scale,nichewebsize,basalsp,isfish,Mass,orig.nodes,orig.Z)
attach(meta_scale);
%--------------------------------------------------------------------------
% Find remaining consumer-resource body size ratios (for new life stages)
% and calculate metabolic rates
%--------------------------------------------------------------------------
    
    %% Start by Re-Calculating Consumer-resource body-size, because we don't have Z for new lifestages
    %  In this section we will solve for Z using MATLABs solve function.
    %  So we start by defining Z as symbols, then define the general
    %  equations, and then we can solve it.
    Z=sym('Z_%d', [1 nichewebsize]);%We want to solve for Z2, which would correspond to the prey averaged trophic position (T2)
    assume(Z,'real')
    %Make it just a bit faster by filling in the first two trophic levels
    Z(find(orig.nodes))=orig.Z;
    Z(basalsp)=1;
    
    %% Find General Equation for Mass according to T1 (Shortest Distance)
    Mass1=sym('M_%d', [nichewebsize 1]);  % Set up vector
    Mass1(basalsp)=1; % Basal species defined to have mass of 1
    ind=basalsp;    % Set up index to basal species
    bookmark=NaN(nichewebsize,1);%Just keep track of what hasn't been assigned a value yet.

    % Assign other trophic levels.
    for j=2:nichewebsize
        last_level=ind;%Preserve previous trophic levels
        [r,~]=find(nicheweb(:,ind)~=0);%Find all species that eat previous trophic level
        ind = unique(r);%Unique Index of species that consume previous trophic level.
        for i=ind'
            if isnan(bookmark(i)) % Don't give new values to species that already have weights.
                prey_opts=intersect(last_level,find(nicheweb(i,:)));%find all options - all prey that were in the previous trophic level. IT MUST ALSO HAVE SHORTEST PATH(because otherwise it could take a "shortcut" through a chain with smaller masses, but a longer overall path)
                smallest_prey=mean(Mass1(prey_opts));% Find mass of the smallest prey item in consumer i's diet
                Mass1(i)=Z(i)*smallest_prey; %Allometrically scale the weight of the prey to find the consumer's weight
                bookmark(i)=1;
            end
        end 
    end
    % Just find all possible options and get the minimum after you solve for Z. M
    % Mean is also a lazy solution that would work instead of min.
    % I don't even think anyone cares about Z, really...  Does it matter?
    
    %% Find General Equation for Mass according to T2 (Prey-Averaged Trophic Position)
    prey=sum(nicheweb,2); %sum of each row
    Q=nicheweb./prey;  % Create unweighted Q matrix. (Proportion of predator diet that each species gives).
    Q(isnan(Q))=0; 
    I=eye(nichewebsize);
    K=ones(nichewebsize,1);
    
    Mass2=prod((K*Z).^(inv(I-Q)),2);%Equation for 
    %% Solve for Z Consumer-resource body-size):
    eqn = Mass==sqrt(Mass1.*Mass2);%The equation that calculated mass will allow you to recalculate Z now
    %Z=vpasolve(eqn); %Solve the system of equations - always can solve because basal species are defined as Z=1
    new_nodes=find(1-orig.nodes);
    solution=vpasolve(eqn(new_nodes),[-Inf,Inf]); %Solve the system of equations - always can solve because basal species are defined as Z=1
    solution=fsolve(eqn(new_nodes),[0,Inf])
    Z(new_nodes)=table2array(struct2table(solution))'; % Convert the structure into a vector.
    

%     %%Metabolic scaling constants  %%%No longer used
%     a_r = 1;
%     a_x= 0.314; %Berlow et al. 2009
%     a_y = 8*a_x;  %% note 8 is the y_ij

    %% Metabolic and mass assimilation rates
    meta=zeros(nichewebsize,1);
    for i=1:nichewebsize
        if ismember(i,basalsp)
            meta(i)=0;% Brose et al 2006 , was set to .138 before;  %metabolic rate for producers
        elseif isfish(i)
            meta(i) = .88*(1./(Mass(i)) ).^A_fish;%metabolic rate for etcotherm vertebrates
        else
            meta(i) = .314*(1./(Mass(i)) ).^A_invert; %metabolic rate for invertebrates
        end
    end
