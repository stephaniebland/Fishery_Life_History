rm(list=ls())
detach(neither)
detach(fish_only)
detach(reduced_fish)
detach(no_plants)
library(RColorBrewer)
col_scheme=brewer.pal(8,'Dark2')
#Declare function to standardize niche values
squash=function(x){
  y=x-min(x)
  y=y/max(y)
  return(y)
}
std.fun=function(x){
  y=(x-mean(x))/sd(x)
  return(y)
}
setwd("/Users/JurassicPark/Documents/Testing code/Fixed_for_morethan3fish")
n_mass=matrix(0,0,5)
n_webs=20927
#col_scheme <- brewer.pal(n_webs, "Dark2")
for (i in 1:n_webs){
  x=paste("n_mass_",i,".txt",sep="")
  temp=read.csv(x,header=F)
  n_mass=rbind(n_mass,temp)
}
colnames(n_mass)=c("N","niche","mass","ln_m","log_m","isfish","plant","either","Troph","meta","T1","T2")
neither=n_mass[n_mass$either==0,]#only use invertebrates
fish_only=n_mass[n_mass$isfish==1,]#only use fish
no_plants=n_mass[n_mass$plant==0,]#fish and invertebrates
####################################################

attach(no_plants)
indep_var=log_m
x=tapply(niche,N,squash)
y=tapply(indep_var,N,std.fun)
x=as.vector(unlist(x))
y=as.vector(unlist(y))
A=cbind(x,y,isfish,N)
rm(x,y)
detach(no_plants)
#Reduce it by getting rid of inverts
reduced_fish=A[A[,3]==1,]
reduced_fish=as.data.frame(reduced_fish)
colnames(reduced_fish)=c("x","y","isfish","N")
attach(fish_only)
indep_var=log_m
x=tapply(niche,N,std.fun)
y=tapply(indep_var,N,std.fun)
x=as.vector(unlist(x))
y=as.vector(unlist(y))

#attach(reduced_fish)
M0=lm(y~x)

adjR.M0=summary(M0)$adj.r.squared
adjR.M0
plot(x,y,col=N,pch=19)

#plot(x,y,col=col_scheme[N],pch=19)
plot(x,y,col=col_scheme[isfish+2],pch=19)
#legend("bottomright",legend=c("hi","hello"))
abline(M0)
#legend(x=.5, y=0.5,legend=c("hi"))



detach(neither)
detach(fish_only)
detach(no_plants)


