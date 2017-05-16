#!/bin/bash
# Variable Names:
script_name=RunCluster 	# Name of the file we will be compressing
version=_3				# Version
#cluster_name=fundy		&& URL=titanium@fundy.ace-net.ca		&& dtnURL=$URL
cluster_name=glooscap	&& URL=titanium@glooscap.ace-net.ca		&& dtnURL=titanium@dtn.glooscap.ace-net.ca
#cluster_name=placentia	&& URL=titanium@placentia.ace-net.ca	&& dtnURL=$URL
###############################################
declare -i seed_0=0
simsize=5
# Options to run it locally instead
# MCR=/Applications/MATLAB/MATLAB_Runtime/v91 # Run on my Mac
# MCR=/usr/local/MATLAB/MATLAB_Runtime/v92 # Run on linux (Selenium)
MCR=/usr/local/matlab-runtime/r2017a/v92 # Run on ACENET

# Setup
myLinux=selenium@129.173.34.107
DATE=`date +%Y%b%d`
run_name=$DATE$version # Name of the Run, where we store the ACENET file

# On my Mac Run:
git push origin master ACENET-RUNS
git bundle create ~/Documents/master\'s\ Backup/backup_$DATE.bundle master ACENET-RUNS
# git bundle create ~/Documents/master\'s\ Backup/backup_$DATE_all.bundle --all #Stores all branches

# On Selenium Run:
ssh $myLinux <<END
	rm -rf masters/
	git clone -b ACENET-RUNS ~/GIT/masters.git/
	/usr/local/MATLAB/R2017a/bin/matlab -nodisplay -r "cd('~/masters/');mcc -m $script_name.m;quit"
	cd ~/masters
	sftp -i ~/.ssh/id_rsa$cluster_name $dtnURL <<END
		mkdir ~/$run_name
		cd $run_name
		put $script_name
		put run_$script_name.sh
	END
END

# Create Job Scripts Locally
for simnum in `seq 0 4`; do
	declare -i simnum_0=$simsize*$simnum+1
	declare -i simnum_f=$simsize+$simnum_0-1
	job_name=run_simnum_0_to_$simnum_f.job
	touch $job_name
cat > $job_name<<EOF
#$ -cwd
#$ -j yes
#$ -l h_rt=48:0:0
#$ -l h_vmem=10G
./run_$script_name.sh $MCR $seed_0 $simnum_0 $simnum_f
EOF

# And finally Run ACENET
sftp -i ~/.ssh/id_rsa$cluster_name $dtnURL <<END
	cd $run_name
	put $job_name
END
rm $job_name
ssh -i ~/.ssh/id_rsa$cluster_name $URL <<END
	cd $run_name
	chmod +x $script_name run_$script_name.sh
	qsub $job_name
END
done


## Manual setup
## Set up keygen on Selenium
# ssh-keygen -t rsa #Hit enter three times
# chmod go-w ~/
# chmod 700 ~/.ssh
# cd ~/.ssh && chmod 600 authorized_keys id_rsa id_rsa.pub known_hosts 
# cat ~/.ssh/id_rsa.pub | ssh titanium@fundy.ace-net.ca "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys && chmod go-w ~/ && chmod 700 ~/.ssh && cd ~/.ssh && chmod 600 authorized_keys"










