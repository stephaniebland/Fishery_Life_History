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
# Use following terminal commands to run:
# chmod +x ./BLANDparams.sh
# ./BLANDparams.sh > BLANDparamsList.job 
# Once in condor run this to get it to run:
# condor_submit BLANDparamsList.job 
# and to check the queue of jobs:
# condor_q
##### MATLAB #####
#location=/Applications/MATLAB_R2016b.app/bin/matlab # Local location on my computer
##### MATLAB RUNTIME #####
#location=/Applications/MATLAB/MATLAB_Runtime/v91  #My Laptop
#location=/usr/local/matlab-runtime/r2017a/v92 #ACENET NEW
script_name=RunCluster

echo '#$ -cwd'
echo '#$ -j yes'
echo '#$ -l h_rt=48:0:0'
echo '#$ -l h_vmem=40G'
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






















