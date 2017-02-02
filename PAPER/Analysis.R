# ---- Global_Parameters ----
rm(list=ls())
setwd("/Users/JurassicPark/Google Drive/GIT/Masters Project")
library(R.matlab)
test=readMat("garbage.mat")
dim(test$x)
names(test)
Bsize=test$nichewebsize
x=test$x
test$t.days
Bdata=test$full.sim[,1:Bsize]
dim(Bdata)
day=t(test$day)

matplot(1:test$t.days,log10(Bdata[1:test$t.days,]),"l")

