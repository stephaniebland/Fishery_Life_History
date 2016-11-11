%--------------------------------------------------------------------------
% Program by: Perrine Tonin
% Jun 7, 2011
%--------------------------------------------------------------------------
% Comparison between fixed effort scenario and 
% no extraction scenario in big web fisheries.
% The script runs the simulations and save the data 
% in a big excel file
% + matrix with all the parameterization
% to be able to re-do all the simulations
%--------------------------------------------------------------------------


clear;
beep off
warning off MATLAB:divideByZero;
% Number of original nodes (species)
S_0=30;


%--------------------------------------------------------------------------
% Protocole parameters
%--------------------------------------------------------------------------
    mu=0;    %security - stiffness parameter
    ca=0.01; %security - catchability coefficient
    
    tot_nwebs = 10;         % number of webs to create
    tot_harv_species = 3;   % number of different species to harvest within each web
    Emax = 50;             % maximum of quota values
    
    meanlast = 400;
    pers_thresh = 0.70; % minimum tolerated number of persistant species for a web
    errorrange = 0.05;  % tolerated error for the biomass when calculating gammaATN

    tot_simu = tot_nwebs*tot_harv_species;
    xmat = zeros(tot_simu,56);% Matrix to save output in at the end. Number of columns comes from total number of output that you want to save. 
    all_webs = zeros(S_0,S_0,tot_nwebs);
    all_param = zeros(66,S_0,tot_nwebs);

%--------------------------------------------------------------------------
% For each food web 
%--------------------------------------------------------------------------

    webindex=0
    k=0
    trash=0
    
    while webindex<tot_nwebs 
        
        % creation of a new food web
        setup;
        
        % simulation without exploitation
        B0=(999*rand(nichewebsize,1)+1)*0.01;%Duplicate of line in setup!
        E0=zeros(nichewebsize,1);%Duplicate of line in setup!
        [x, t] =  dynamic_fn(K,int_growth,meta,max_assim,effic,Bsd,q,c,f_a,f_m, ...
                  ca,co,mu,p_a,p_b,nicheweb,B0,E0,t_init,t_final,ext_thresh);
        B0=x(end,1:nichewebsize)'; % use the final biomasses as the initial conditions
        
        % selection of only the surviving species
        surv_sp=find(B0>ext_thresh);
        newnicheweb=nicheweb(surv_sp,surv_sp);  % nicheweb without the rows and cols of extincted species
        fish_sp=find(isfish(surv_sp));          % we want webs with at least 3 fish species remaining
        
        % keep only webs with more than pers_thresh % of persistant
        % species, still connected and with at least 3 fish species
        if length(surv_sp)>=nichewebsize*pers_thresh && isConnected(newnicheweb)==1 && length(fish_sp)>=3
            
            webindex=webindex+1
            
            % calculate the properties of the new web
            nichewebsize=length(surv_sp);
            Lfinal=sum(sum(newnicheweb));%total number of remaining links
            conn_final=Lfinal/nichewebsize^2;%end connectance
            structproperties=web_properties(newnicheweb,T1(surv_sp),TrophLevel(surv_sp)); %calculates the structural properties of the niche
            
            % remove all the extincted species
            B0=B0(surv_sp);
            B0mean=mean(x(end-meanlast:end,surv_sp));
            B0std=std(x(end-meanlast:end,surv_sp));
            K=K(surv_sp);
            int_growth=int_growth(surv_sp);
            meta=meta(surv_sp);
            max_assim=max_assim(surv_sp,surv_sp);
            effic=effic(surv_sp,surv_sp);
            Bsd=Bsd(surv_sp,surv_sp);
            c=c(surv_sp,surv_sp);
            IsFish=IsFish(surv_sp);
            fish_sp=find(IsFish);
            TrophLevel=TrophLevel(surv_sp);
            T1=T1(surv_sp);
            Z=Z(surv_sp);
            nonbasalsp=find(sum(newnicheweb,2)>0);
            
            % selection of the biggest species to harvest
            if length(fish_sp)==3
                harv_species=fish_sp;    % if there are only 3 fish species, harvest all of them
            else
                possib_harv=zeros(nichewebsize,1);
                possib_harv(fish_sp)=TrophLevel(fish_sp)./meta(fish_sp); % calculate trophic level / metabolic rate
                sortsize=sort(possib_harv);                              % sort the species by TL/x_i
                sizethreshold=sortsize(end-2);
                harv_species=find(possib_harv>=sizethreshold);           %s elect the species with highest TL/x_i
            end
            clear Lfinal possib_harv nonbasalsp sortsize sizethreshold;
            
            % harvesting each of the three selected species
            for i=1:tot_harv_species
                k=k+1;
                harv_index=harv_species(i); % index of the harvested species
                harv=zeros(nichewebsize,1);
                harv(harv_index)=1;	        % array giving the harvested species
                
                % mortality gammaATN=q*E for which the harvested species biomass has been divided by 2
                % uses a dichotomic research algorythm
                gammaATN=0;
                Bhalf=B0mean(harv_index)/2
                E_inf=0;
                E_sup=Emax;
                
                while gammaATN==0
                   Elevel=(E_sup+E_inf)/2
                   E0=harv.*Elevel;
                   [x, t] =  dynamic_fn(K,int_growth,meta,max_assim,effic,Bsd,q,c,f_a,f_m, ...
                                ca,co,mu,p_a,p_b,newnicheweb,B0,E0,t_init,t_final,ext_thresh);
                   Bmean=mean(x(end-meanlast:end,1:nichewebsize));
                   Bf=Bmean(harv_index)
                   Bstd=std(x(end-meanlast:end,1:nichewebsize));
                   
                   if isnan(Bf)==1
                       gammaATN=-99 % sometimes the new web won't allow the ode45 function to work properly
                       
                   elseif Bf<Bhalf*(1+errorrange) && Bf>Bhalf*(1-errorrange) % Bf=B0/2 +-1%
                       gammaATN=Elevel
                       
                   elseif E_sup-E_inf<0.01
                       gammaATN=Elevel
                       
                   elseif Bf>2*Bhalf % Bf>B0 then return -1 (Hydra Effect)
                       gammaATN=-1
                       
                   elseif Bf>Bhalf && Elevel>Emax-.01 % Elevel<gammaATN but to make the algorithm end
		                gammaATN=Emax-.01
                        
                   elseif Bf>Bhalf   % Elevel<gammaATN
                       E_inf=Elevel;
                       
                   elseif Elevel<.01  % Elevel>gammaATN but set 0 to make the algo finish
                       gammaATN=.01
                       
                   else
                       E_sup=Elevel; % Elevel>gammaATN
                   end   
                end
                
                % calculate all the niche properties (local and global) and
                % save the data
                xmat(k,1:3)=[webindex nichewebsize conn_final];
                xmat(k,4:20)=structproperties;
                xmat(k,21:24)=[harv_index IsFish(harv_index) meta(harv_index) TrophLevel(harv_index)];
                xmat(k,25:47)=local_properties(newnicheweb,harv_index,harv_species);
                xmat(k,48:51)=[B0mean(harv_index) B0std(harv_index) sum(B0mean) sum(B0mean(nonbasalsp))];
                xmat(k,52:end)=[gammaATN Bstd(harv_index) sum(Bmean) sum(Bmean(nonbasalsp)) 4.5*meta(harv_index)];

            end

	    all_webs(1:nichewebsize,1:nichewebsize,webindex)=newnicheweb;
	    all_param(1:5,1:nichewebsize,webindex)=[meta'; TrophLevel'; T1; Z'; int_growth']; 
        all_param(6:5+nichewebsize,1:nichewebsize,webindex)=Bsd;
        all_param(36:35+nichewebsize,1:nichewebsize,webindex)=c;
        all_param(66,1:nichewebsize,webindex)=B0';
          
        
        %if the new web has too few persistant species or is not fully
        %connected or has less than 3 fish species ...
        else
            trash=trash+1;
        end
            
    end

%--------------------------------------------------------------------------
% Save data
%--------------------------------------------------------------------------

%filename = 'BigWebs_Results_Efix.xls';
%header{1} = 'Fishing economy in complex marine fodd webs';
%header{2} = 'Fixed effort scenario';
%colnames = {'#web','#sp','connect','Top','Int','Bas','Can','Herb','MaxSim', ...
%           'VulSD','GenSD','LinkSD','Clust','Path','Omniv','Loop','chLen',...
%           'chNum','chSD','TL','harv_index','Is fish','xi','Troph Level', ...
%           'Is top','Is inter','Is can','Is herb','Vul','Gen','Conn','Clust i',...
%           'TrophSim12','TrophSim23','TrophSim13','<Gen>preys','SD(Gen)preys', ...
%           '<Vul>preys','SD(Vul)preys','<Conn>preys','SD(Conn)preys',...
%           '<Gen>preds','SD(Gen)preds','<Vul>preds','SD(Vul)preds','<Conn>preds','SD(Conn)preds',...
%           'Bharv(E=0)','SD_Bharv(E=0)','Btot(E=0)','Bnonbasal(E=0)', ...
%           'Gamma ATN','SD_Bharv(E(50)','Btot(E50)','Bnonbasal(E50)','Gamma logist'};
%xlswrite(xmat,header,colnames,filename)

save('results_for_Efix');

%% all_webs(:,:,i)  <=> ith web
%% all_param(1,:,i) <=> metabolic rates of the ith web
%% all_param(2,:,i) <=> TrophLevel 	of the ith web
%% all_param(3,:,i) <=> T1		of the ith web
%% all_param(4,:,i) <=> Z		of the ith web
%% all_param(5,:,i) <=> int_growth	of the ith web
%% all_param(6:35,:,i)  <=> Bsd	matrix	of the ith web
%% all_param(36:65,:,i) <=> c matrix	of the ith web
%% all_param(66,:,i) <=> intitial biomasses of the ith web


