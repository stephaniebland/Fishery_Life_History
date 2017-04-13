#!/bin/sh
###############################################
############### SET LOCATION ##################
###############################################
#location=/nfs/usr/local/bin/matlab # Location for Fernanda's cluster (OLD)
#location=/nfs/MATLAB/R2013a/bin/matlab # Location for Fernanda's cluster (NEW)
location=/Applications/MATLAB_R2016b.app/bin/matlab # Local location on my computer

###############################################
################# RUN FILES ###################
###############################################
seed_0=0
simnum=5
Exper=1
echo Parameters $seed_0 $simnum $Exper
$location -nodisplay -r "RunCluster($seed_0,$simnum,$Exper);quit"










