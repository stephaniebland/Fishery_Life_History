full_sim=nan(N_years*L_year,4*nichewebsize);
full_t=nan(N_years*L_year,1);
year_index=nan(N_years*L_year,1);
B_year_end=nan(N_years,nichewebsize);
AllCatch=nan(nichewebsize,N_years*L_year);
B0=B_orig;
t_days=0;
t_year=1;
abort_sim=false;
%Run one time phase at a time, each phase has different conditions
for phase=1:4
    switch phase
        case 1 %{Stabilize Data before you record anything}
             n_years_in_phase=num_years.stabilize;
             evolve=false;
             lstages_linked=lifestages_linked;
             Effort=0;
        case 2 %{insert lifehistory}
            n_years_in_phase=num_years.pre_fish;
            evolve=false;
            lstages_linked=lifestages_linked;
            Effort=0;
        case 3 %{insert fishing}
            %% Save Deterministic Data For Replicates
            B_repeat_sim=B0;%
            %% Basic settings
            n_years_in_phase=num_years.fishing;
            evolve=true; % Fecundity evolves (fish reach maturity at a younger age)
            %% Shift fish diet according to evolution
            if (lifehis.fishpred==true | lifehis.splitdiet==false)
                reorder_by_size=extended_n;
            else
                reorder_by_size=1:nichewebsize;%eh, just don't bother reordering if you dont use an extended web that starts with new niche values.
            end
            [shifted_web]=Dietary_evolution(nicheweb,isfish,evolv_diet,reorder_by_size);
            nicheweb=shifted_web;
            Effort=catchrate*isfish'*hmax./(1+exp(-2*((lifestage-1)-F50)));
        case 4 %{quit fishing}
            n_years_in_phase=num_years.post_fish;
            evolve=false;
            Effort=0;
    end
    for i=1:n_years_in_phase
        if (evolve==true || t_days==0)%For years after evolution starts
            [reprod]=prob_of_maturity(prob_mat,nichewebsize,is_split,N_stages,species,i);
        end
        %% ODE
        [x, t] =  dynamic_fn(K,int_growth,meta,max_assim,effic,Bsd,q,c,f_a,f_m, ...
            ca,co,mu,p_a,p_b,nicheweb,B0,E0,t_init,L_year+1,ext_thresh);
        B_end=x(L_year+1,1:nichewebsize)'; % use the final biomasses as the initial conditions
        B0=B_end;
        if lstages_linked==true
            %% Move biomass from one life history to the next
            fish_gain_tot=sum(x(1:L_year,(1:nichewebsize)+nichewebsize),1)';
            if cont_reprod==false
                fish_gain_tot=1;
            end
            %DOUBLE CHECK THAT YOU TAKE B OUT OF FOLLOWING LINE
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            B0=aging_table*B_end+fecund_table*(reprod.*fish_gain_tot);%.*B_end); %Last step is adding contribution from all lifestages, so put the rest in brackets! %Split lifehistory_table into two parts.
        end
        %% Concatenate Data for all years
        full_sim((1:L_year)+t_days,:)=x(1:L_year,:);
        full_t((1:L_year)+t_days)=t(1:L_year)+t_days;%full_t does not have timesteps that are *exactly* 1, so numbers don't look to nice.  keep anyhow.
        year_index((1:L_year)+t_days)=repelem(t_year,L_year);%Pointless really, just the year of each time step. good for checking data
        B_year_end(t_year,:)=B_end;%For matlab graphs- just year end biomasses
        t_days=t_days+L_year;%Index Number of days that passed, because loop repeated for cases
        t_year=t_year+1;%Index Number of years that passed, because loop repeated for cases
        %% Aborts simulation early if there aren't enough fish for it to continue
        surv_sp=find(B0>ext_thresh);%Index of all surviving nodes (indexed by newwebsize)
        surv_fish_stages=intersect(find(isfish),surv_sp);%Surviving fish lifestages (indexed by new newwebsize)
        surv_fish=unique(species(surv_fish_stages));%The original species number of each surviving fish (indexed as one of S_0)
        if (length(surv_fish)<3 && phase<3 && first_run==true)%Cancel simulation if there aren't enough surviving fish species (not nodes) before fishing even starts
            abort_sim=true;
            break
        end
    end
    if abort_sim==true
        break
    end
end