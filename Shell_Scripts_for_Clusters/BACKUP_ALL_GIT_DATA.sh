#!/bin/bash
# BACKUP ALL GIT DATA
# This script pushes all data to selenium and backs it up in google drive and apple storage
###############################################
DATE=`date +%Y%b%d`
cd ~/GIT
for i in *; do
	cd $i
	###############################################
	############## STANDARD BACKUPS ###############
	###############################################
	git bundle create ~/Google\ Drive/GIT\_Backup/$i\_backup\_all.bundle --all
	git bundle create ~/Library/Mobile\ Documents/com~apple~CloudDocs/BackupGIT/$i\_backup\_all.bundle --all
	git bundle create ~/BackupGIT/$i\_backup\_$DATE\_all.bundle --all
	###############################################
	################# INITIALIZE ##################
	###############################################
	#git remote -v # Check backup locations
	#echo ssh://pterodactyl@140.184.38.227/home/pterodactyl/GIT/$i.git
	#git remote add backup ssh://pterodactyl@140.184.38.227/home/pterodactyl/GIT/$i.git
	#ssh -i ~/.ssh/id_rsaPterodactyl pterodactyl@140.184.38.227 <<END
	#cd ~/GIT
	#mkdir $i.git
	#cd $i.git
	#git --bare init
	#END
	###############################################
	################## SELENIUM ###################
	###############################################
	git push origin --all -u
	scp ~/BackupGIT/$i\_backup\_$DATE\_all.bundle selenium@129.173.34.107:~/BackupGIT
	###############################################
	################# PTERODACTYL #################
	###############################################
	ssh-agent sh -c 'ssh-add ~/.ssh/id_rsaPterodactyl; git push backup --all -u' # Temporarily adds identity key to push to Pterodactyl
	scp -i ~/.ssh/id_rsaPterodactyl ~/BackupGIT/$i\_backup\_$DATE\_all.bundle pterodactyl@140.184.38.227:~/BackupGIT
	###############################################
	cd ~/GIT
done
