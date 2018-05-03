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
simsize=1
sims_per_cluster=1

###############################################
# Setup
script_name=RunCluster # Name of the file we will be compressing
myLinux=selenium@129.173.34.107
declare -a avail_clusters=("cedar" "graham")
DATE=`date +%Y%b%d`
JobID=`date +%m%d`$version
run_name=$DATE\_$version # Name of the Run, where we store the ACENET file
exe_name=$script_name\_$run_name # Name of the executable
# Options to run it locally instead
# MCR=/Applications/MATLAB/MATLAB_Runtime/v91 # Run on my Mac
# MCR=/usr/local/MATLAB/MATLAB_Runtime/v92 # Run on linux (Selenium)
MCR=/usr/local/matlab-runtime/r2017a/v92 # Run on ACENET

###############################################
# Push commits to Linux and Backup Servers (& Bundle Backups):
# This runs on my mac
echo "run_name='$run_name';" > DateVersion.m
git commit -m "$run_name" DateVersion.m
git push origin master ACENET-RUNS Fix-Cluster # Push MATLAB code to Selenium Server 
ssh-agent sh -c 'ssh-add ~/.ssh/id_rsaPterodactyl; git push backup --all -u' # Push all MATLAB code to Shadow Server
git bundle create ~/Documents/master\'s\ Backup/backup_$DATE.bundle master ACENET-RUNS # Save a local backup of your work
# git bundle create ~/Documents/master\'s\ Backup/backup_$DATE_all.bundle --all #Stores all branches

###############################################
# Compile MATLAB On Selenium to get a Linux Executable:
ssh -T $myLinux << END
	rm -rf masters/
	git clone -b master ~/GIT/masters.git/
	/usr/local/MATLAB/R2017a/bin/matlab -nodisplay -r "cd('~/masters/');mcc -m $script_name.m -o $exe_name;quit"
END
# To compile it on my mac instead to get a mac executable use:
# /Applications/MATLAB_R2016b.app/bin/matlab -nodisplay -r "cd('~/GIT/MastersProject');mcc -m $script_name.m -o $exe_name;quit"

###############################################
########### LOOP THROUGH CLUSTERS #############
###############################################
for cluster_num in `seq 0`; do
	cluster_name=${avail_clusters[$cluster_num]}
	URL=titanium@$cluster_name.computecanada.ca
	dtnURL="$URL"
	if [ "$cluster_name" = "glooscap" ]; then
		dtnURL=titanium@dtn.$cluster_name.ace-net.ca
	fi
	# Drop the compiled files in the cluster
	ssh $myLinux <<- END
		cd ~/masters
		sftp -i ~/.ssh/id_rsa$cluster_name $dtnURL <<- ENDsftp
			mkdir /home/titanium/$run_name
			cd $run_name
			put $exe_name
		ENDsftp
	END

	#Find the total number of jobs to do in each cluster
	declare -i jobs_per_cluster=$sims_per_cluster/$simsize
	declare -i job_0=$cluster_num*$jobs_per_cluster
	declare -i job_f=$job_0+$jobs_per_cluster-1

	###############################################
	######### LOOP THROUGH JOB SCRIPTS ############
	###############################################
	# These loops happen within the cluster loops
	ssh -T -i ~/.ssh/id_rsa$cluster_name $URL <<- END
		cd $run_name
		chmod +x $exe_name run_$exe_name.sh
		###############################################
		# Loop through job scripts
		###############################################
		for simnum in \`seq $job_0 $job_f\`; do
			declare -i simnum_0=$simsize*\$simnum+1
			declare -i simnum_f=$simsize+\$simnum_0-1
			for fishpred in 2; do
			for splitdiet in 0; do
			job_name=r$JobID\_\$simnum_0\_\$fishpred\_\$splitdiet.job
			###############################################
			# The contents of the job script
			#######################################################
			cat > \$job_name <<- EOF
				#!/bin/bash
				#SBATCH --time=48:00:00
				#SBATCH --job-name=\$job_name
				#SBATCH --account=def-akuparin
				#SBATCH --output=%x-%j.out
				#SBATCH --array=0-7
				module load mcr/R2017a
				setrpaths.sh --path $exe_name
				run_mcr_binary.sh $exe_name $seed_0 \\\$SLURM_ARRAY_TASK_ID \\\$SLURM_ARRAY_TASK_ID \$fishpred \$splitdiet

				#######################################################
				# Bundle results together into a tar file to reduce number of files
			EOF
			sed -i '$ a for tarfile in \`seq '"\$simnum_0 \$simnum_f"'\`; do' \$job_name 
			cat >> \$job_name <<- \EOF
					files=\$(ls $run_name\_*_sim\$tarfile\_*)
					tar rfW results_\$tarfile.tar \$files    # creates an archive file. r appends, W verifies
					if [[ \$? == 0 ]]   # safety check, don't delete .txts unless tar worked
					then
						rm \$files
					else
						echo "Error: tar failed, intermediate files retained"
					fi
				done
			EOF
			#######################################################

			#######################################################
			#######################################################
			# And finally Run ACENET Cluster
			sbatch \$job_name
			done
			done
		# Finish job script loop
		done
		# Save the Job-ID associated with this run (for maxvmem)
		#######################################################
		echo \$(squeue  -u titanium | grep r$JobID) > qstat_$JobID.txt
		# And just the list of jobs
		echo \$( (squeue  -u titanium | grep r$JobID) | cut -d' ' -f1 ) > joblist_$JobID.txt
		#######################################################
		# Run script every few minutes to check if the job is done:
		#######################################################
		crontab -l > tmp_cron.sh
		sed -i "/$JobID/d" tmp_cron.sh
		echo \*/10 \* \* \* \* ~/task_$JobID\_done.sh >> tmp_cron.sh
		crontab tmp_cron.sh
		rm tmp_cron.sh
		# Check if job is done:
		#######################################################
		# Crontab script for linux:
		#######################################################
		cat > ~/task_$JobID\_done.sh <<- EOF
			totaljobs=\$(qstat | grep -c r$JobID)
		EOF
		cat >> ~/task_$JobID\_done.sh <<- \EOF
			# IMPORTANT: First load bashrc so crontab can see qstat:
			source /usr/local/lib/bashrc 
			# Keep track of progress through acenet runs:
			declare -i jobs_left=\$(qstat | grep -c r$JobID) # Track number of remaining jobs early so that experiments all have a chance to compress. 
			declare -i progress=100-100*\$jobs_left/\$totaljobs
			echo \$progress"% through" > $run_name/progress_$JobID$cluster_name.txt
			# Concatenate all the tar files together.
			cd $run_name
			files=\$(ls results_*.tar)
			for addfile in \$files; do 
				#tar -A allTars_$cluster_name.tar \$addfile # This version will be too slow for many large data sets.
				cat \$addfile >> allTars_$cluster_name.tar # https://superuser.com/a/941552 Need to use -i option to ignore these nulls between headers while extracting.
				if [[ \$? == 0 ]]   # safety check, don't delete .txts unless tar worked
				then
					rm \$addfile
				else
					echo "Error: Tar concatenation failed on file" \$addfile >> concatenation_failures.txt
				fi
			done
			cd ~
			# If all the jobs are finished we can cotinue.
			if [ \$jobs_left -eq 0 ]; then
				# If the job is done we can:
				# a) Remove the crontab task first, so that we only execute script once:
				crontab -l > tmp_cron2.sh
				sed -i "/$JobID/d" tmp_cron2.sh
				crontab tmp_cron2.sh
				rm tmp_cron2.sh
				# b.1) Store memory usage stats (This step is slow)
				cd $run_name
					declare -a alljobs=(\$(cat joblist_$JobID.txt))
					for job in "\${alljobs[@]}"; do 
						echo \$job \$(qacct -j \$job | grep -E 'ru_wallclock|maxvmem') \$(ls *\$job | cut -d'.' -f1) >> maxvmem_$JobID$cluster_name.txt
					done
					# b.2) Store time it took to complete all jobs:
					START=$(date +%s);
					END=\$(date +%s);
					echo \$((\$END-START)) | awk '{printf "%d days and %02d:%02d", \$1/86400, (\$1/3600)%24, (\$1/60)%60}' > progress_$JobID$cluster_name.txt
					# c) Compress the file in Zip form
					#cat results_* >> allTars_$cluster_name.tar # This would join all tar files once at end of all runs.
					files=\$(ls -I "*.tar")
					tar rfW extra_data.tar \$files 
					cat extra_data.tar >> allTars_$cluster_name.tar
					tar cJf temp.tar.xz allTars_$cluster_name.tar
				cd ~
				# d) Rename the zip file. (Two steps so it's not transferred until fully compressed.)
				mv $run_name/temp.tar.xz ~/$run_name\_$cluster_name.tar.xz
				# e) And remove itself - no need for clutter!
				rm task_$JobID\_done.sh
			fi
		EOF
		chmod +x ~/task_$JobID\_done.sh
		#######################################################	
	END

	# And then over on my mac, crontab a script to look for the zip files
	crontab -l > tmp_cron.sh
	sed -i '' "/$JobID$cluster_name/d" tmp_cron.sh
	echo \*/10 \* \* \* \* ~/$JobID$cluster_name.sh >> tmp_cron.sh
	crontab tmp_cron.sh
	rm tmp_cron.sh
	#######################################################
	# Crontab script for my mac:
	#######################################################
	cat > ~/$JobID$cluster_name.sh <<- EOF
		# Bring them over to my mac
		if ssh -qi .ssh/id_rsa$cluster_name $URL test -e $run_name\_$cluster_name.tar.xz; then
			# a) Remove the crontab task first, so that we only execute script once:
			crontab -l > tmp_cron2.sh
			sed -i '' "/$JobID$cluster_name/d" tmp_cron2.sh
			crontab tmp_cron2.sh
			rm tmp_cron2.sh
			# b) Retrieve the file:
			sftp -qi .ssh/id_rsa$cluster_name $dtnURL > /dev/null <<- END
				get $run_name\_$cluster_name.tar.xz
			END
			# c) And uncompress them 
			mv $run_name\_$cluster_name.tar.xz ~/GIT/Analysis/$run_name\_$cluster_name.tar.xz
			mkdir -p ~/GIT/Analysis/$run_name
			# I need to use gtar (gnu-tar) to access -i option
			PATH="/usr/local/opt/gnu-tar/libexec/gnubin:\$PATH"
			PATH="/usr/local/Cellar/xz/5.2.3/bin:\$PATH"
			tar ixf ~/GIT/Analysis/$run_name\_$cluster_name.tar.xz -C ~/GIT/Analysis/$run_name
			tar ixf ~/GIT/Analysis/$run_name/allTars_$cluster_name.tar -C ~/GIT/Analysis/$run_name
			rm ~/GIT/Analysis/$run_name/allTars_$cluster_name.tar 
			# d) And remove itself - no need for clutter!
			rm $JobID$cluster_name.sh
			rm progress_$JobID$cluster_name.txt
		else
			sftp -qi .ssh/id_rsa$cluster_name $dtnURL > /dev/null <<- END
				get $run_name/progress_$JobID$cluster_name.txt
			END
		fi
	EOF
	chmod +x ~/$JobID$cluster_name.sh

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
# cd ~/.ssh && chmod 600 authorized_keys id_rsa* known_hosts 
# cat ~/.ssh/id_rsafundy.pub | ssh titanium@fundy.ace-net.ca "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys && chmod go-w ~/ && chmod 700 ~/.ssh && cd ~/.ssh && chmod 600 authorized_keys"

###############################################
############ USEFUL EXTRA STUFF ###############
###############################################
# To find memory requirements for a list of jobs, use this:
#joblist=$( ( (ls *.o* | grep '.job.o') | cut -d'.' -f3 ) | cut -d'o' -f2)
#for job in $joblist; do (qstat -j $job | grep maxvmem) | cut -d'=' -f6; done
# And once the job is done running:
#for job in $joblist; do (qacct -j $job | grep maxvmem); done

# Find the files with errors so I can redo them:
# grep CTF $(ls r11280_*)
# grep Error $(ls r11280_*)
# grep -L Exper4 $(ls r11280_*job.o*)
# grep -L CompletedAllRuns $(ls r11280_*job.o*)

# Short little script to clean up messes you made on every cluster
# WARNING THIS SCRIPT IS VERY POWERFUL AND DANGEROUS
#       version=1
#       DATE=2017Jun07
#       JobID=0607$version
#       
#       run_name=$DATE\_$version 
#       declare -a avail_clusters=("fundy" "glooscap" "placentia" "mahone")
#       for cluster_num in `seq 0 3`; do
#       cluster_name=${avail_clusters[$cluster_num]}
#       URL=titanium@$cluster_name.ace-net.ca
#       echo "###############################################"
#       echo "###############################################"
#       echo "###############################################"
#       echo $URL
#       ssh -T -i ~/.ssh/id_rsa$cluster_name $URL <<- END
#       echo "1. CLEAR CRONTAB-------------------------------"
#       crontab -l
#       #crontab -r
#       echo "2. CLEAR QUEUE---------------------------------"
#       ( (qstat | grep r$JobID) | cut -d' ' -f1 ) 
#       #qdel \$( (qstat | grep r$JobID) | cut -d' ' -f1 )
#       qstat
#       echo "2. CLEAN BAD FILES-----------------------------"
#       ls
#       #rm -r $run_name
#       #rm $JobID$cluster_name.zip
#       #rm task_$JobID\_done.sh
#       END
#       done # FINISH LOOPING THROUGH CLUSTERS
#       
#       # And clean up local computer
#       echo "1. CLEAR CRONTAB-------------------------------"
#       crontab -l
#       #crontab -l > tmp_cron2.sh
#       #sed -i '' "/$JobID/d" tmp_cron2.sh
#       #crontab tmp_cron2.sh
#       #rm tmp_cron2.sh  
#       echo "2. CLEAN BAD FILES-----------------------------"
#       cd ~; ls
#       #rm progress_$JobID*.txt $JobID*.sh
#       cd ~/GIT/Analysis; ls






