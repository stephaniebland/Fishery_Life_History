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
cat > task_$JobID\_done.sh << EOF
if [ \$(qstat | grep -c $JobID) -eq 0 ]; then
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


# And then over on my mac, crontab a script to look for the zip files
crontab -l > tmp_cron.sh
echo \*/10 \* \* \* \* ~/$JobID$cluster_name.sh >> tmp_cron.sh
crontab tmp_cron.sh
rm tmp_cron.sh
#######################################################
# Crontab script for my mac:
#######################################################
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










