# ---- Global_Parameters ----
setwd("/Users/JurassicPark/Google Drive/GIT/Masters Project")
library(R.matlab)
test=readMat("garbage.mat")
names(test);
thingity=5
masscalc=as.data.frame(test$masscalc)$`1.1`
lifehis=as.data.frame(test$lifehis)$`1.1`
prob_mat=as.data.frame(test$prob.mat)$`1.1`

Symbol
Description
Value
Unit
Reference