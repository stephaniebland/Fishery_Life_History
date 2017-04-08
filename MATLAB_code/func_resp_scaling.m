%--------------------------------------------------------------------------
% Code by Perrine Tonin
% March 2012
%--------------------------------------------------------------------------
% This function calculates the half saturation densities
% "Bsd" matrix and the predator interference "c" matrix
% using nicheweb, isfish array (=1 if fish and =0 if invertebrate)
% and the predator-prey body-masses ratios Z
%--------------------------------------------------------------------------

function [Bsd, c] = func_resp_scaling(func_resp,nicheweb,nichewebsize,isfish,Mass,basalsp)
attach(func_resp);

Bsd = ones(nichewebsize); % non zero value to prevent division by 0 in gr_func  (Default half-sat constants)
c   = zeros(nichewebsize);%Predator Interference

for i=1:nichewebsize
    for j=1:nichewebsize
        if nicheweb(i,j)==1 %% assign a non zero value only if i eats j
           
            %--------------------------------------------------------------
            % if i is an invertebrate
            %--------------------------------------------------------------
            if isfish(i)==0   
                attach(invert);
                Bsd(i,j) = K_invert;            % low half saturation density
                c(i,j)=exprnd(c_dist); % competition  coefficient is exponential distribution with mu=0.2 (i.e. lambda=5), limited to 0.5
                while c(i,j)>c_max %Fixed distribution so not truncated to a peak at the end.
                    c(i,j)=exprnd(c_dist);
                end
                
            %--------------------------------------------------------------
            % if i is a fish 
            %--------------------------------------------------------------
            else 
                attach(fish);
               
                %----------------------------------------------------------
                % if a fish (i) eats another fish (j)
                %----------------------------------------------------------
                if isfish(j)==1
                    Bsd(i,j) = fish_K; %Half-saturation density
                    c(i,j)   = fish_c; %Low competition coefficient 
                  
                %----------------------------------------------------------
                % if a fish (i) eats an invertebrate (j)
                %----------------------------------------------------------
                else
                    rate = sum(nicheweb(j,basalsp))/sum(nicheweb(j,:));%Percentage of the prey (invertebrate)'s diet that are basal species
                    
                    %------------------------------------------------------
                    % if the invertebrate prey j is omnivore
                    %------------------------------------------------------
                    if rate<0.7
                        Bsd(i,j) = omni_K;
                        c(i,j)   = omni_c;
                        
                    %------------------------------------------------------
                    % if the invertebrate prey j is mostly herbivore
                    %------------------------------------------------------
                    else
                        attach(herb);
                        ratio = Mass(i)/Mass(j);%Predator-prey body mass ratio. 
                        
                        %--------------------------------------------------
                        % if the invertebrate prey j mostly herbivore is
                        % 50 times smaller than the fish predator
                        % LIKE DAPHNIA !
                        %--------------------------------------------------
                        if ratio>50
                            Bsd(i,j) = smallZ_K;
                            c(i,j)   = smallZ_c;
                            
                        %--------------------------------------------------
                        % if the invertebrate prey j mostly herbivore is
                        % not very much smaller than the fish predator
                        %--------------------------------------------------
                        else
                            Bsd(i,j) = largeZ_K;
                            c(i,j)   = largeZ_c;
                            
                        end
                    end
                end
            end 
        end
    end
end