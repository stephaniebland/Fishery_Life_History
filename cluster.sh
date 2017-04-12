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
# chmod ./cluster.sh
# ./cluster.sh > params2run.job 

echo "#Created by make_jobfile.sh"
echo "universe=vanilla"
echo "getenv=true"
echo "executable=./run_OBJ2.sh"
echo 'output=log_1200m/results.output.$(Cluster).$(Process)'
echo 'error=log_1200m/results.error.$(Cluster).$(Process)'
echo 'log=log_1200m/results.log.$(Cluster).$(Process)'




#simnum=1;
#
#while [ $simnum -le 10 ]; do 
#	echo The sim is $simnum
#                         echo "arguments=" $simnum
#                         echo "queue"
#
#	let simnum=simnum+1
#done


for simnum in `seq 1 10`; do 
	echo The sim is $simnum
	for xkcd in `seq 1 10`; do 
		echo "arguments=" $simnum $xkcd
		echo "queue"
	done
done


#for ifrG_native in 0 4; do
  # for ifrG_Inv in 0 4; do
    #  for PoA in 0 1; do
         for k_level in 0 1; do
	     for fbetaI in 1 4; do
                 for fepsilonI in 1 4; do
 #                    for ftauI in 1 2; do
                        for ((ri=1;ri<=1200;ri++)) ; do
                         echo "arguments=" 4 0 0 1 $k_level 0 $fbetaI $fepsilonI 1 1 0.3 $ri 0
                         echo "queue"
                        done
                     done
                 #done
              #done
          done
      #done
    done
#done





















