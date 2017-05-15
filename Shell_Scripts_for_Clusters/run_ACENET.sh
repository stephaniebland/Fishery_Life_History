#!/bin/bash
# Variable Names:
script_name=RunCluster # Name of the file we will be compressing
run_name=may15.8 # Name of the Run, where we store the ACENET file
#cluster_name=fundy		&&	URL=titanium@fundy.ace-net.ca
#cluster_name=glooscap	&&	URL=titanium@dtn.glooscap.ace-net.ca
cluster_name=placentia	&&	URL=titanium@placentia.ace-net.ca

# On my Mac Run:
git push origin master
git push origin ACENET-RUNS

# On Selenium Run:
ssh selenium@129.173.34.107 <<END
	#Run:
	rm -rf masters/
	git clone -b ACENET-RUNS ~/GIT/masters.git/
	/usr/local/MATLAB/R2017a/bin/matlab -nodisplay -r "cd('/home/selenium/masters/');mcc -m $script_name.m;quit"
END
ssh selenium@129.173.34.107 <<END
	cd ~/masters
	# On ACENET Run: 
	sftp -i ~/.ssh/id_rsa$cluster_name $URL <<END
		mkdir /home/titanium/$run_name
		cd $run_name
		put $script_name
		put run_$script_name.sh
		put BLANDparams.sh
	END
END

# And finally Run ACENET
ssh -i /Users/JurassicPark/.ssh/id_rsa$cluster_name $URL <<END
	cd $run_name
	chmod +x ./BLANDparams.sh
	./BLANDparams.sh > BLANDparams.job 
	qsub BLANDparams.job 
END



## Manual setup
## Set up keygen on Selenium
# ssh-keygen -t rsa #Hit enter three times
# chmod go-w ~/
# chmod 700 ~/.ssh
# cd ~/.ssh && chmod 600 authorized_keys id_rsa id_rsa.pub known_hosts 
# cat ~/.ssh/id_rsa.pub | ssh titanium@fundy.ace-net.ca "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys && chmod go-w ~/ && chmod 700 ~/.ssh && cd ~/.ssh && chmod 600 authorized_keys"










