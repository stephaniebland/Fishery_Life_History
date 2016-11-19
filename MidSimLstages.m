%Suppose you create life histories mid-simulation

%%-------------------------------------------------------------------------
%%  LIFE HISTORY
%%-------------------------------------------------------------------------
    [nicheweb,lifehistory_table,Mass,orig.nodes,species,N_stages,is_split]= LifeHistories(lifehis,leslie,orig,nichewebsize,n_new,c_new,r_new);
    %Update all the output to reflect new web
    nichewebsize = length(nicheweb);
    %[x]=adjust_vars_lstages(N_stages,int_growth)
    
    isfish=repelem(orig.isfish,N_stages);
    K=repelem(K,N_stages);
    
    
    A = [1 2; 3 4]


B = repelem(A,[1,2],[1,2])

    effic=repelem(effic,N_stages,N_stages);
    max_assim=repelem(max_assim,N_stages);
    int_growth=repelem(int_growth,N_stages);%Basal species only
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
    [TrophLevel,T1,T2]= TrophicLevels(nichewebsize,nicheweb,basalsp);%Recalculate trophic levels for new nicheweb
    %YES BUT NOW I DON'T KNOW IF I SHOULD USE OLD TROPHIC LEVEL OR NEW TROPHIC LEVELS IN METABOLIC SCALING
    [meta,Z]=metabolic_scaling(meta_scale,nichewebsize,basalsp,isfish,TrophLevel,Mass,orig.Z,orig.nodes);
    

%Half saturation density "Bsd" and predator interference "c"  
%-----------------------------------------------------------
    [Bsd, c]=func_resp_scaling(func_resp,nicheweb,nichewebsize,isfish,Z,basalsp);


   