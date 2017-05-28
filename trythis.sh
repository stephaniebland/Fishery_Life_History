#!/bin/bash
# The looping script to run on ACENET clusters.
# https://www.ace-net.ca/wiki/MATLAB_Runtime
###############################################
# ACENET (www.ace-net.ca) provides cluster computing resources for researchers at Dal (and elsewhere).
# Your thesis supervisor will have to get an account before you can, but both are free.
# The process is described in more detail at https://www.ace-net.ca/wiki/Get_an_Account.
#
# If you have never used a cluster before you will want some training.
# There are several classroom and web training sessions scheduled for early May;
# see http://www.ace-net.ca/training/workshops-seminars/ for details.
###############################################
# USEFUL ACENET COMMANDS:
# Check the queue of jobs:
# qstat 
# qsum
# showq
# Check memory requirements:
# qacct -j 6793085 | grep maxvmem
###############################################
# Variable Names:
version=0 # Version
declare -i seed_0=0
simsize=5
sims_per_cluster=10

###############################################
# Setup
script_name=testing # Name of the file we will be compressing
myLinux=selenium@129.173.34.107
declare -a avail_clusters=("fundy")
DATE=`date +%Y%b%d`
JobID=`date +%m%d`$version
run_name=$DATE\_$version # Name of the Run, where we store the ACENET file
# Options to run it locally instead
# MCR=/Applications/MATLAB/MATLAB_Runtime/v91 # Run on my Mac
# MCR=/usr/local/MATLAB/MATLAB_Runtime/v92 # Run on linux (Selenium)
MCR=/usr/local/matlab-runtime/r2017a/v92 # Run on ACENET


###############################################
# Compile MATLAB On Selenium to get a Linux Executable:
#ssh -T $myLinux << END
#	/usr/local/MATLAB/R2017a/bin/matlab -nodisplay -r "mcc -m $script_name.m;quit"
#END
# To compile it on my mac instead to get a mac executable use:
# /Applications/MATLAB_R2016b.app/bin/matlab -nodisplay -r "cd('~/GIT/MastersProject');mcc -m RunCluster.m;quit"

###############################################
########### LOOP THROUGH CLUSTERS #############
###############################################
for cluster_num in 0; do
	cluster_name=fundy
	URL=titanium@$cluster_name.ace-net.ca
	dtnURL="$URL"
	# Drop the compiled files in the cluster
#	ssh $myLinux << END
#		#cd ~/masters
#		sftp -i ~/.ssh/id_rsa$cluster_name $dtnURL << END
#			mkdir /home/titanium/$run_name
#			cd $run_name
#			put $script_name
#			put run_$script_name.sh
#		END
#	END

	#Find the total number of jobs to do in each cluster
	declare -i jobs_per_cluster=$sims_per_cluster/$simsize
	declare -i job_0=$cluster_num*$jobs_per_cluster
	declare -i job_f=$job_0+$jobs_per_cluster-1


	###############################################
	######### LOOP THROUGH JOB SCRIPTS ############
	###############################################
	# These loops happen within the cluster loops
ssh -T -i ~/.ssh/id_rsa$cluster_name $URL << END
	cd $run_name
	chmod +x $script_name run_$script_name.sh
	###############################################
	# Loop through job scripts
	###############################################
	for simnum in \`seq $job_0 $job_f\`; do
		declare -i simnum_0=$simsize*\$simnum+1
		declare -i simnum_f=$simsize+\$simnum_0-1
		echo \$simnum_0 \$simnum_f >> ls_$JobID.sh
		echo ./run_$script_name.sh $MCR $seed_0  \$simnum_0 \$simnum_f >> ls_$JobID.sh
		echo touch hello\$simnum_0.txt >> ls_$JobID.sh # Make a simple file
	# Finish job script loop
	done
	###############################################
	# The contents of the job script
#######################################################
cat > r$JobID.job << \EOF
#$ -cwd
#$ -j yes
#$ -l test=true
#$ -l h_rt=0:01:0
#$ -l h_vmem=1G
#$ -t 1-8
SEEDFILE=~/$run_name/ls_$JobID.sh
SEED=\$(awk "NR==\$SGE_TASK_ID" \$SEEDFILE)
\$SEED
echo ./run_$script_name.sh $MCR $seed_0 \$SEED >> whatev.txt
./run_$script_name.sh $MCR $seed_0 \$SEED
EOF
#######################################################
# And finally Run ACENET Cluster
qsub r$JobID.job
# Save the Job-ID associated with this run (for maxvmem)
#######################################################
echo \$(qstat | grep $JobID) > qstat_$JobID.txt
# And just the list of jobs
echo \$( (qstat | grep $JobID) | cut -d' ' -f1 ) > joblist_$JobID.txt
#######################################################
END

done # FINISH LOOPING THROUGH CLUSTERS


## Manual setup
## Set up keygen on Selenium
# ssh-keygen -t rsa #Hit enter three times
# chmod go-w ~/
# chmod 700 ~/.ssh
# cd ~/.ssh && chmod 600 authorized_keys id_rsa id_rsa.pub known_hosts 
# cat ~/.ssh/id_rsa.pub | ssh titanium@fundy.ace-net.ca "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys && chmod go-w ~/ && chmod 700 ~/.ssh && cd ~/.ssh && chmod 600 authorized_keys"

###############################################
############ USEFUL EXTRA STUFF ###############
###############################################
# To find memory requirements for a list of jobs, use this:
#joblist=$( ( (ls *.o* | grep '.job.o') | cut -d'.' -f3 ) | cut -d'o' -f2)
#for job in $joblist; do (qstat -j $job | grep maxvmem) | cut -d'=' -f6; done
# And once the job is done running:
#for job in $joblist; do (qacct -j $job | grep maxvmem); done










