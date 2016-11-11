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
lin.regr=function(N,bodymass,nichevalue){#a has two columns
  #nichevalue=a[,1]
  #bodymass=a[,2]
  
  Mregr=lm(bodymass~nichevalue)
  adjR=summary(Mregr)$adj.r.squared
  R.squar=summary(Mregr)$r.squared
  intercept.regr=summary(Mregr)$coefficients[1,1]
  slope.regr=summary(Mregr)$coefficients[2,1]
  web_num=mean(N)
  beep=cbind(web_num, intercept.regr,slope.regr,R.squar,adjR)
  return(beep)
}
# trial=function(x,y){
#   z=x*y
#   return(z)
# }
# test=rbind(c(2,50),c(3,100))
setwd("/Users/JurassicPark/Documents/Testing code/Fixed_for_morethan3fish")
n_mass=matrix(0,0,5)
n_webs=3
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
x=tapply(niche,N,std.fun)
y=tapply(indep_var,N,std.fun)
x=as.vector(unlist(x))
y=as.vector(unlist(y))
A=cbind(x,y,isfish,N)
rm(x,y)
detach(no_plants)
#Reduce it by getting rid of inverts
reduced_fish=A[A[,3]==1,]
reduced_fish=as.data.frame(reduced_fish)
colnames(reduced_fish)=c("xvar","yvar","isfish","N")
attach(fish_only)
indep_var=log_m
x=tapply(niche,N,squash)
y=tapply(indep_var,N,std.fun)
x=as.vector(unlist(x))
y=as.vector(unlist(y))

#attach(reduced_fish); x=xvar;y=yvar
M0=lm(y~x)

adjR.M0=summary(M0)$adj.r.squared
adjR.M0
plot(x,y,col=N,pch=19)

#plot(x,y,col=col_scheme[N],pch=19)
#plot(x,y,col=col_scheme[isfish+2],pch=19)
#legend("bottomright",legend=c("hi","hello"))
abline(M0)
#legend(x=.5, y=0.5,legend=c("hi"))



detach(neither)
detach(fish_only)
detach(no_plants)
detach(reduced_fish)



#Try again, but with individual linear regressions
attach(fish_only)
indep_var=log_m
x=tapply(niche,N,squash)
y=tapply(indep_var,N,std.fun)
x=as.vector(unlist(x))
y=as.vector(unlist(y))
run_lm=as.data.frame(cbind(N,y,x))
#by(test, N, function(k) cor(k$x, k$y))#finding correlation is mostly useless
#fancy.regr=by(test, N, function(k) lm(y~x, data = k))#doesn't output nearly enough data
#testing=fancy.regr[1]
trial=by(run_lm, N, function(k) lin.regr(k$N,k$y, k$x))
lm_by_web=matrix(unlist(trial),dim(trial),length(unlist(trial[1])),byrow=T)
colnames(lm_by_web)=c("web","Intercept","slope","R squared","adjusted R squared")
plot(x,y,col=N,pch=19)
abline(lm_by_web[1,2],lm_by_web[1,3],col=lm_by_web[1,1])
abline(lm_by_web[2,2],lm_by_web[2,3],col=lm_by_web[2,1])
abline(lm_by_web[3,2],lm_by_web[3,3],col=lm_by_web[3,1])
abline(lm_by_web[,2],lm_by_web[,3],col=lm_by_web[,1])
by(lm_by_web,lm_by_web[,1],function(k) abline(k$Intercept,k$slope,col=k$web))

detach(fish_only)





