%% IT'S TOO COMPLICATED TO RECALCULATE THIS STUFF BECAUSE WHAT IF YOU CALL NICHEWEBSIZE OR A SIMPLE VARIABLE IN THE NEXT EXPERIMENT
%% SOLUTION: SEE IF YOU CAN WRITE A FUNCTION THAT DOESNT RETURN ANY NUMBERS: WILL IT RESET VALUES THEN???
%% Re-calculate Food Web Properties
% caluculate all extant nodes including fish life stages that might not be
% alive all the time!! Of course this method has its own fair share of
% problems: For experiment 2 it will pretend that all life stages still
% exist, even if only one continues to live. But experiment 2 isn't the
% main experiment in the final output. I use this method in case one life
% stage "goes extinct" in the linked experiment but is really just in the
% wrong year
extant_sp=unique(species(B0>0))'; % List all extant species (ignoring extinct life stages)
extant_logical=ismember(species',extant_sp); % Logical indexing of extant species
% Now for the rest of the properties:
nichewebsize=sum(extant_logical)
basal_ls=basal_ls(extant_logical);
basalsp=find(basal_ls);
nicheweb=nicheweb(extant_logical,extant_logical);
% Run new calculations
[TrophLevel,T1,T2]= TrophicLevels(nichewebsize,nicheweb,basalsp);
% Calculate Percentage herbivory

%% Convert output into regular format

%% Export Re-calculated Food Web Properties
import_vars={'nichewebsize','TrophLevel','T1','T2'};

for i=import_vars
    dlmwrite(strcat('final_',name,'_',char(i),'.txt'),eval(char(i)));
end