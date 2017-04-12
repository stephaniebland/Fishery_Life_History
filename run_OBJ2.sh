#!/bin/sh
###############################################
############### SET LOCATION ##################
###############################################
#location=/nfs/usr/local/bin/matlab # Location for Neo's cluster
location=/Applications/MATLAB_R2016b.app/bin/matlab # Local location on my computer

###############################################
################# RUN FILES ###################
###############################################
echo Parameters $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13
#$location -nodisplay -r "runObj2_cluster($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13);quit"
$location -nodisplay -r "x=5*4;dlmwrite('hihelloyoutwo.txt',x);quit"










