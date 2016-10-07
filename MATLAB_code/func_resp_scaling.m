%--------------------------------------------------------------------------
% Code by Perrine Tonin
% March 2012
%--------------------------------------------------------------------------
% This function calculates the half saturation densities
% "Bsd" matrix and the predator interference "c" matrix
% using nicheweb, IsFish array (=1 if fish and =0 if invertebrate)
% and the predator-prey body-masses ratios Z
%--------------------------------------------------------------------------

function [Bsd, c] = func_resp_scaling(nicheweb,nichewebsize,IsFish,Z,basalsp)

Bsd = ones(nichewebsize); % non zero value to prevent division by 0 in gr_func  (Default half-sat constants)
c   = zeros(nichewebsize);%Predator Interference

for i=1:nichewebsize
    for j=1:nichewebsize
        if nicheweb(i,j)==1 %% assign a non zero value only if i eats j
           
            %--------------------------------------------------------------
            % if i is an invertebrate
            %--------------------------------------------------------------
            if IsFish(i)==0   
                Bsd(i,j) = 1.5;            % low half saturation density
                c(i,j)=min(exprnd(.2),.5); % competition  coefficient is exponential distribution with mu=0.2 (i.e. lambda=5), limited to 0.5
                
            %--------------------------------------------------------------
            % if i is a fish 
            %--------------------------------------------------------------
            else 
               
                %----------------------------------------------------------
                % if a fish (i) eats another fish (j)
                %----------------------------------------------------------
                if IsFish(j)==1
                    Bsd(i,j) = 15; %Half-saturation density
                    c(i,j)   = 3*10^-4; %Low competition coefficient 
                  
                %----------------------------------------------------------
                % if a fish (i) eats an invertebrate (j)
                %----------------------------------------------------------
                else
                    rate = sum(nicheweb(j,basalsp))/sum(nicheweb(j,:));%Percentage of the prey (invertebrate)'s diet that are basal species
                    
                    %------------------------------------------------------
                    % if the invertebrate prey j is omnivore
                    %------------------------------------------------------
                    if rate<0.7
                        Bsd(i,j) = 50;
                        c(i,j)   = 10^-4;
                        
                    %------------------------------------------------------
                    % if the invertebrate prey j is mostly herbivore
                    %------------------------------------------------------
                    else
                        ratio = Z(i)/Z(j);%I *think* Z is predator-prey body-mass ratio. StephHWK: Find out why you take the ratios of Z's then?
                        
                        %--------------------------------------------------
                        % if the invertebrate prey j mostly herbivore is
                        % 50 times smaller than the fish predator
                        % LIKE DAPHNEA !
                        %--------------------------------------------------
                        if ratio>50
                            Bsd(i,j) = 150;
                            c(i,j)   = 1;
                            
                        %--------------------------------------------------
                        % if the invertebrate prey j mostly herbivore is
                        % not very smaller than the fish predator
                        %--------------------------------------------------
                        else
                            Bsd(i,j) = 15;
                            c(i,j)   = 10^-4;
                            
                        end
                    end
                end
            end 
        end
    end
end