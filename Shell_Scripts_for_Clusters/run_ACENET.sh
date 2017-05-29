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
version=1 # Version
declare -i seed_0=0
simsize=1
sims_per_cluster=5

###############################################
# Setup
script_name=RunCluster # Name of the file we will be compressing
myLinux=selenium@129.173.34.107
declare -a avail_clusters=("fundy" "glooscap" "placentia")
DATE=`date +%Y%b%d`
JobID=`date +%m%d`$version
run_name=$DATE\_$version # Name of the Run, where we store the ACENET file
# Options to run it locally instead
# MCR=/Applications/MATLAB/MATLAB_Runtime/v91 # Run on my Mac
# MCR=/usr/local/MATLAB/MATLAB_Runtime/v92 # Run on linux (Selenium)
MCR=/usr/local/matlab-runtime/r2017a/v92 # Run on ACENET

###############################################
# Push commits to Linux and Backup Servers (& Bundle Backups):
# This runs on my mac
echo "run_name='$run_name';" > DateVersion.m
git commit -m "$run_name" DateVersion.m
#git push origin master ACENET-Autotransfer-files # Push MATLAB code to Selenium Server 
#ssh-agent sh -c 'ssh-add ~/.ssh/id_rsaPterodactyl; git push backup --all -u' # Push all MATLAB code to Shadow Server
#git bundle create ~/Documents/master\'s\ Backup/backup_$DATE.bundle master ACENET-Autotransfer-files # Save a local backup of your work
# git bundle create ~/Documents/master\'s\ Backup/backup_$DATE_all.bundle --all #Stores all branches

###############################################
# Compile MATLAB On Selenium to get a Linux Executable:
#ssh -T $myLinux << END
#	rm -rf masters/
#	git clone -b ACENET-Autotransfer-files ~/GIT/masters.git/
#	/usr/local/MATLAB/R2017a/bin/matlab -nodisplay -r "cd('~/masters/');mcc -m $script_name.m;quit"
#END
# To compile it on my mac instead to get a mac executable use:
# /Applications/MATLAB_R2016b.app/bin/matlab -nodisplay -r "cd('~/GIT/MastersProject');mcc -m RunCluster.m;quit"

###############################################
########### LOOP THROUGH CLUSTERS #############
###############################################
for cluster_num in 0; do
	cluster_name=${avail_clusters[$cluster_num]}
	URL=titanium@$cluster_name.ace-net.ca
	dtnURL="$URL"
	if [ "$cluster_name" = "glooscap" ]; then
		dtnURL=titanium@dtn.$cluster_name.ace-net.ca
	fi
# Drop the compiled files in the cluster
ssh $myLinux << END
	cd ~/masters
	sftp -i ~/.ssh/id_rsa$cluster_name $dtnURL << END
		mkdir /home/titanium/$run_name
		cd $run_name
		put $script_name
		put run_$script_name.sh
	END
END

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
		job_name=r$JobID\$simnum_0\_run_\$simnum_0\_to_\$simnum_f.job
		###############################################
		# The contents of the job script
#######################################################
cat > \$job_name << EOF
#$ -cwd
#$ -j yes
#$ -l h_rt=48:0:0
#$ -l h_vmem=10G
./run_$script_name.sh $MCR $seed_0 \$simnum_0 \$simnum_f
EOF
#######################################################
		# And finally Run ACENET Cluster
		qsub \$job_name
	# Finish job script loop
	done
	# Save the Job-ID associated with this run (for maxvmem)
	#######################################################
	echo \$(qstat | grep $JobID) > qstat_$JobID.txt
	# And just the list of jobs
	echo \$( (qstat | grep $JobID) | cut -d' ' -f1 ) > joblist_$JobID.txt
#######################################################
# Run script every few minutes to check if the job is done:
#######################################################
crontab -l > tmp_cron.sh
echo \*/10 \* \* \* \* ~/task_$JobID\_done.sh >> tmp_cron.sh
crontab tmp_cron.sh
rm tmp_cron.sh
# Check if job is done:
#######################################################
# Crontab script for linux:
#######################################################
cd ~
cat > ~/task_$JobID\_done.sh << EOF
if \$[ \$(qstat | grep -c $JobID) -eq 0 ]; then
	# If the job is done we can:
	# a) Compress the file in Zip form
	zip -r temp.zip $run_name
	# b) Rename the zip file. (Two steps so it's not transferred until fully compressed.)
	mv temp.zip $JobID$cluster_name.zip
	# c) Delete the crontab task
	crontab -l > tmp_cron2.sh
	sed -i '' "/$JobID/d" tmp_cron2.sh
	crontab tmp_cron2.sh
	rm tmp_cron2.sh
fi
EOF
chmod +x task_$JobID\_done.sh
#######################################################	
END

# And then over on my mac, crontab a script to look for the zip files
crontab -l > tmp_cron.sh
echo \*/10 \* \* \* \* ~/$JobID$cluster_name.sh >> tmp_cron.sh
crontab tmp_cron.sh
rm tmp_cron.sh
#######################################################
# Crontab script for my mac:
#######################################################
cd ~
cat > $JobID$cluster_name.sh << EOF
# Bring them over to my mac
if ssh -i .ssh/id_rsa$cluster_name $URL test -e $JobID$cluster_name.zip; then
	# Retrieve the file:
	sftp -i ~/.ssh/id_rsa$cluster_name $dtnURL <<- END
		get $JobID$cluster_name.zip
	END
	# And uncompress them 
	mv $JobID$cluster_name.zip ~/GIT/Analysis/$JobID$cluster_name.zip
	unzip ~/GIT/Analysis/$JobID$cluster_name.zip
	# When this is done, we can delete the crontab task
	crontab -l > tmp_cron2.sh
	sed -i '' "/$JobID$cluster_name/d" tmp_cron2.sh
	crontab tmp_cron2.sh
	rm tmp_cron2.sh
fi
EOF
chmod +x $JobID$cluster_name.sh

done # FINISH LOOPING THROUGH CLUSTERS

###############################################
############# DONE NOW CLEAN UP ###############
###############################################
echo "run_name='BLAND';" > DateVersion.m 

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










