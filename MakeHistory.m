%%-------------------------------------------------------------------------
%%  LIFE HISTORY
%%-------------------------------------------------------------------------
    [nicheweb,lifehistory_table,Mass,orig.nodes,species,N_stages,is_split]= LifeHistories(lifehis,leslie,orig,nichewebsize,n_new,c_new,r_new);
    %Update all the output to reflect new web
    nichewebsize = length(nicheweb);
    isfish=repelem(orig.isfish,N_stages);
    meta_N_stages=repelem(N_stages,N_stages);
    lifestage=[];
    for i=1:S_0
        lifestage=[lifestage 1:N_stages(i)];
    end
    Mvec=Mass;
    basalsp = find(sum(nicheweb,2)==0);%List the autotrophs (So whatever doesn't have prey)  Hidden assumption - can't assign negative prey values (but why would you?)

%%-------------------------------------------------------------------------
%%  SET DYNAMICS PARAMETERS
%%-------------------------------------------------------------------------

%"meta", "TrophLevel" & "T1", "IsFish" and "Z"
%---------------------------------------------
%1) set manually
    %meta = [0; .15; .02];    
%2) Can be scaled with body size
    [TrophLevel,T1,T2]= TrophicLevels(nichewebsize,nicheweb,basalsp);%Recalculate trophic levels for new nicheweb
    %YES BUT NOW I DON'T KNOW IF I SHOULD USE OLD TROPHIC LEVEL OR NEW TROPHIC LEVELS IN METABOLIC SCALING
    [meta,Z]=metabolic_scaling(meta_scale,nichewebsize,basalsp,isfish,TrophLevel,Mass,orig.Z,orig.nodes);
    
    
%Other dynamic parameters
%------------------------
    K = ones(nichewebsize,1) .*K_param;

    max_assim=assim.max_rate*ones(nichewebsize);% max rate i assimilates j per unit metabolic rate of i

    effic=assim.effic_nonplants*ones(nichewebsize);%assimilation efficiency of i for j
    effic(:,basalsp) = assim.effic_basal;

%Half saturation density "Bsd" and predator interference "c"  
%-----------------------------------------------------------
    %Bsd = 1.5*ones(nichewebsize);
    %c = ones(nichewebsize,nichewebsize)*0.5;
    [Bsd, c]=func_resp_scaling(func_resp,nicheweb,nichewebsize,isfish,Z,basalsp);
    
    

    