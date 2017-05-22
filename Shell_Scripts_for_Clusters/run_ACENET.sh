#!/bin/bash
# Variable Names:
version=_0 # Version
declare -i seed_0=0
simsize=5
sims_per_cluster=100

# Setup
script_name=RunCluster # Name of the file we will be compressing
myLinux=selenium@129.173.34.107
declare -a avail_clusters=("fundy" "glooscap" "placentia")
DATE=`date +%Y%b%d`
run_name=$DATE$version # Name of the Run, where we store the ACENET file
# Options to run it locally instead
# MCR=/Applications/MATLAB/MATLAB_Runtime/v91 # Run on my Mac
# MCR=/usr/local/MATLAB/MATLAB_Runtime/v92 # Run on linux (Selenium)
MCR=/usr/local/matlab-runtime/r2017a/v92 # Run on ACENET

# On my Mac Run:
rm DateVersion.m
echo "run_name='$run_name';" >> DateVersion.m
git commit -m "$run_name" DateVersion.m
git push origin master ACENET-RUNS # Push MATLAB code to Selenium Server 
ssh-agent sh -c 'ssh-add ~/.ssh/id_rsaPterodactyl; git push backup --all -u' # Push all MATLAB code to Shadow Server
git bundle create ~/Documents/master\'s\ Backup/backup_$DATE.bundle master ACENET-RUNS # Save a local backup of your work
# git bundle create ~/Documents/master\'s\ Backup/backup_$DATE_all.bundle --all #Stores all branches

# Compile MATLAB On Selenium to get a Linux Executable:
ssh -T $myLinux <<END
	rm -rf masters/
	git clone -b ACENET-RUNS ~/GIT/masters.git/
	/usr/local/MATLAB/R2017a/bin/matlab -nodisplay -r "cd('~/masters/');mcc -m $script_name.m;quit"
END

###############################################
########### LOOP THROUGH CLUSTERS #############
###############################################
for cluster_num in `seq 0 2`; do
	cluster_name=${avail_clusters[$cluster_num]}
	URL=titanium@$cluster_name.ace-net.ca
	dtnURL="$URL"
	if [ "$cluster_name" = "glooscap" ]; then
		dtnURL=titanium@dtn.$cluster_name.ace-net.ca
	fi
	echo $cluster_name
	echo $URL
	echo $dtnURL
# Drop the compiled files in the cluster
ssh $myLinux <<END
	cd ~/masters
	sftp -i ~/.ssh/id_rsa$cluster_name $dtnURL <<END
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
for simnum in `seq $job_0 $job_f`; do
	# Create Job Scripts Locally
	declare -i simnum_0=$simsize*$simnum+1
	declare -i simnum_f=$simsize+$simnum_0-1
	job_name=run_$simnum_0\_to_$simnum_f.job
	touch $job_name 
# The contents of the job script
cat > $job_name<<EOF
#$ -cwd
#$ -j yes
#$ -l h_rt=48:0:0
#$ -l h_vmem=10G
./run_$script_name.sh $MCR $seed_0 $simnum_0 $simnum_f
EOF

# Drop the job script on the cluster
sftp -i ~/.ssh/id_rsa$cluster_name $dtnURL <<END
	cd $run_name
	put $job_name
END
rm $job_name
# And finally Run ACENET Cluster
ssh -T -i ~/.ssh/id_rsa$cluster_name $URL <<END
	cd $run_name
	chmod +x $script_name run_$script_name.sh
	qsub $job_name
END
done # FINISH LOOPING THROUGH JOB SCRIPTS

done # FINISH LOOPING THROUGH CLUSTERS

###############################################
############# DONE NOW CLEAN UP ###############
###############################################
rm DateVersion.m 
echo "run_name='BLAND';" >> DateVersion.m # 

## Manual setup
## Set up keygen on Selenium
# ssh-keygen -t rsa #Hit enter three times
# chmod go-w ~/
# chmod 700 ~/.ssh
# cd ~/.ssh && chmod 600 authorized_keys id_rsa id_rsa.pub known_hosts 
# cat ~/.ssh/id_rsa.pub | ssh titanium@fundy.ace-net.ca "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys && chmod go-w ~/ && chmod 700 ~/.ssh && cd ~/.ssh && chmod 600 authorized_keys"










