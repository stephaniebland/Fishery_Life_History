function testing(seed_0,simnum_0,simnum_f)
    %% Convert Bash script characters into plain numbers
    seed_0=str2num(seed_0);
    simnum_0=str2num(simnum_0);
    simnum_f=str2num(simnum_f);
    savethis=sprintf('seed=%d, sim_0=%d, sim_f=%d',seed_0,simnum_0,simnum_f)
    name=sprintf('seed%d_sim%d_to_%d.txt',seed_0,simnum_0,simnum_f)
    dlmwrite(name,strcat(savethis),'')
end