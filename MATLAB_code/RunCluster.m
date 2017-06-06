%--------------------------------------------------------------------------
% Program by: Stephanie Bland
% April 12, 2017
%--------------------------------------------------------------------------
% Cluster Simulation
%--------------------------------------------------------------------------
% The looping script to run on ACENET clusters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACENET (www.ace-net.ca) provides cluster computing resources for researchers at Dal (and elsewhere).
% Your thesis supervisor will have to get an account before you can, but both are free.
% The process is described in more detail at https://www.ace-net.ca/wiki/Get_an_Account.
%
% If you have never used a cluster before you will want some training.
% There are several classroom and web training sessions scheduled for early May;
% see http://www.ace-net.ca/training/workshops-seminars/ for details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RunCluster(seed_0,simnum_0,simnum_f,var_fishpred,var_splitdiet)
    %% Convert Bash script characters into plain numbers
    seed_0=str2num(seed_0);
    simnum_0=str2num(simnum_0);
    simnum_f=str2num(simnum_f);
    sprintf('seed=%d, sim_0=%d, sim_f=%d',seed_0,simnum_0,simnum_f)
    DateVersion; % Import the Date And Version number so we can label output accordingly.

    for simnum=simnum_0:simnum_f
        %% Set Seed
        rng(seed_0+simnum)
        
        %% Initial Setup
        beep off
        warning off MATLAB:divideByZero;
        global reprod cont_reprod Effort;

        %% Protocol Parameters
        Parameters;
        lifehis.fishpred=str2num(var_fishpred);%Choose how to assign fish predators. 0 means only adults eaten, 1 means all stages are eaten, and 2 reassigns them according to nichevalues
        lifehis.splitdiet=str2num(var_splitdiet);%Choose how to split fish diet. true=split orignal diet, false=assign new diet based on new niche values

        %% Setup
        setup;% creation of a new food web
        
        %% Experimental Parameters
        for Exper=1:3
            switch Exper
                case 1
                    %% 1st Simulation: Extended_nicheweb + Lifehistory: B_orig & linked
                    lifestages_linked=true;
                    B0=B_orig;
                    Adults_only=0;
                case 2
                    %% 2nd Simulation: Extended_nicheweb: B_orig & NOT linked
                    lifestages_linked=false;
                    B0=B_orig;
                    Adults_only=0;
                case 3 
                    %% 3rd Simulation: Nicheweb: B_orig=B_orig.*orig.nodes';%(Start with adults only) & NOT linked
                    lifestages_linked=false;
                    B0=B_orig.*orig.nodes';%Start with adults only. %CAUTION - changes total biomass, consider normalizing so all experiments have same total biomass. Or maybe sum juvenile stages to adult instead.
                    Adults_only=1;
            end

            %% Name for Exporting Data
            name=sprintf('%s_seed%d_sim%d_Exper%d_pred%d_prey%d',run_name,seed_0,simnum,Exper,lifehis.fishpred,lifehis.splitdiet)

            %% Time Series Simulation (& Export TS dependent Properties)
            simulations;

            %% Extra Web Properties
            web_properties(nicheweb,T1,TrophLevel);
            numyears=cell2mat(struct2cell(num_years));
            basal_ls=sum(nicheweb,2)==0;
            web_connected=isConnected(nicheweb);
            %Convert Nicheweb into an adjacency list "two-column format, in which the first column lists the number of a consumer, and the second column lists the number of one of the resource species of that consumer." - Dunne 2006
            [adj_row,adj_col]=find(nicheweb);
            adj_list=[adj_row, adj_col];%indexed from 1 and up, so if you want first node to be 0, you need to subtract 1.

            %% Export Web Properties
            import_vars={'isfish','basalsp','basal_ls','species','numyears','nichewebsize','ext_thresh','N_stages','lifestage','L_year','Mass','adj_list','lifehis.fishpred','lifehis.splitdiet'};
            
            for i=import_vars
                dlmwrite(strcat(name,'_',char(i),'.txt'),eval(char(i)));
            end

            %% Close the windows so simulation ends
            close all;
        end
    end
end






