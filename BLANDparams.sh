#!/bin/bash
# The looping script to run on ACENET clusters.
###############################################
# ACENET (www.ace-net.ca) provides cluster computing resources for researchers at Dal (and elsewhere).
# Your thesis supervisor will have to get an account before you can, but both are free.
# The process is described in more detail at https://www.ace-net.ca/wiki/Get_an_Account.
#
# If you have never used a cluster before you will want some training.
# There are several classroom and web training sessions scheduled for early May;
# see http://www.ace-net.ca/training/workshops-seminars/ for details.
###############################################
# Use following terminal commands to run in ACENET:
# chmod +x ./BLANDparams.sh
# ./BLANDparams.sh > BLANDparams.job 
# qsub BLANDparams.job 
# and to check the queue of jobs:
# qstat 
script_name=RunCluster

echo '#$ -cwd'
echo '#$ -j yes'
echo '#$ -l h_rt=48:0:0' # Time limit
echo '#$ -l h_vmem=40G'	 # memory limit
echo 'module load matlab-runtime/r2017a'

chmod +x $script_name
chmod +x run_$script_name.sh
declare -i seed_0=0
simsize=5

for simnum in `seq 0 4`; do
	declare -i simnum_0=$simsize*$simnum+1
	declare -i simnum_f=$simsize+$simnum_0-1
	echo ./run_$script_name.sh $MCR $seed_0 $simnum_0 $simnum_f
done


#Don't run more than 2 days strict limit






















