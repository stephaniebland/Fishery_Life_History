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

echo "#Created by BLANDparams.sh"
echo "universe=vanilla"
echo "getenv=true"
echo "executable=./BLANDrun_cluster.sh"
echo 'output=log_BLAND/results.output.$(Cluster).$(Process)'
echo 'error=log_BLAND/results.error.$(Cluster).$(Process)'
echo 'log=log_BLAND/results.log.$(Cluster).$(Process)'

seed_0=0

for simnum in `seq 1 10`; do
	for Exper in `seq 1 3`; do
		echo "arguments=" $seed_0 $simnum $Exper
		echo "queue"
	done
done





















