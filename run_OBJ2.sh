#!/bin/sh
###############################################
############### SET LOCATION ##################
###############################################
#location=/nfs/usr/local/bin/matlab # Location for Neo's cluster
location=/Applications/MATLAB_R2016b.app/bin/matlab # Local location on my computer

###############################################
################# RUN FILES ###################
###############################################
echo Parameters $simnum $lifestages_linked $Adults_only
simnum=5
lifestages_linked=4
Adults_only=2
$location -nodisplay -r "RunCluster($simnum,$lifestages_linked,$Adults_only);quit"










