#!/bin/sh
#location=/main/apps/linux-x86_64/local6/MCR-R2017a/v92 #ACENET
location=/Applications/MATLAB/MATLAB_Runtime/v91  #My Laptop
#location=/usr/local/matlab-runtime/R2017a #ACENET NEW
script_name=RunCluster

chmod +x $script_name
chmod +x run_$script_name.sh
declare -i seed_0=0
simsize=5


for simnum in `seq 0 4`; do
	declare -i simnum_0=$simsize*$simnum+1
	declare -i simnum_f=$simsize+$simnum_0-1
	echo $seed_0 $simnum_0 $simnum_f
	./run_$script_name.sh $location $seed_0 $simnum_0 $simnum_f
done

#./run_grrrrr.sh /Applications/MATLAB/MATLAB_Runtime/v91 0 1 1
#./run_grrrrr.sh /main/apps/linux-x86_64/local6/MCR-R2017a/v92 0 1 1
#./run_RunCluster.sh /main/apps/linux-x86_64/local6/MCR-R2017a/v92 0 1 1





