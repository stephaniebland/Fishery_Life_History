#!/bin/sh
###############################################
############### SET LOCATION ##################
###############################################
#location=/nfs/usr/local/bin/matlab # Location for Neo's cluster
location=/Applications/MATLAB_R2016b.app/bin/matlab # Local location on my computer

###############################################
################# RUN FILES ###################
###############################################
seed_0=0
simnum=5
lifestages_linked=4
Adults_only=2
echo Parameters $seed_0 $simnum $lifestages_linked $Adults_only
$location -nodisplay -r "RunCluster($seed_0,$simnum,$lifestages_linked,$Adults_only);quit"










