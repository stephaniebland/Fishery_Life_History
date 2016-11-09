rm(list=ls())
detach(neither)
setwd("/Users/JurassicPark/Google Drive/GIT/Masters Project/Testing Code Files/Niche_mass_correlation")
#n_mass=matrix(,0,5)
N=100#10000
adjR=rep(0,N)
R_sq=rep(0,N)
for (i in 1:N){
  x=paste0("n_mass_",i,".txt")
  n_mass=read.csv(x,header=F)
  colnames(n_mass)=c("niche","mass","fish","plant","either")
  neither=n_mass[n_mass$either==0,]
  neither$mass=log10(neither$mass)
  attach(neither)
  #plot(niche,mass)
  M0=lm(mass~niche)
  summary(M0)
  adjR[i]=summary(M0)$adj.r.squared
  R_sq[i]=summary(M0)$r.squared
  #adjR.M0
  #abline(M0)
  detach(neither)
}
adjR
R_sq
hist(adjR,main="Histogram of adjusted R squared")
hist(R_sq,main="Histogram of R squared")
setwd("/Users/JurassicPark/Google Drive/GIT/Masters Project/Testing Code Files")
write.csv(adjR,file=paste0("adjR_",N,".txt"))
write.csv(R_sq,file=paste0("Rsq_",N,".txt"))


