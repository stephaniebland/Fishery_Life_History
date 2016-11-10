rm(list=ls())
detach(neither)
detach(fish)
setwd("/Users/JurassicPark/Documents/Testing code/Everything")
n_mass=matrix(0,0,5)
for (i in 1:10){
  x=paste("n_mass_",i,".txt",sep="")
  temp=read.csv(x,header=F)
  n_mass=rbind(n_mass,temp)
}
colnames(n_mass)=c("N","niche","mass","ln_m","log_m","fish","plant","either","Troph","meta","T1","T2")
neither=n_mass[n_mass$either==0,]#only use invertebrates
attach(neither)
#Declare function to standardize niche values
squash=function(x){
  y=x-min(x)
  y=y/max(y)
  return(y)
}
x=tapply(niche,N,squash)
y=tapply(log_m,N,squash)



#This is where i got stuck
#when i pick up i should turn x, y into simple matrix
#and plot in colours according to foodweb (N)
plot(x,y)


# neither=n_mass[n_mass$either==0,]
# neither$mass=log10(neither$mass)
# attach(neither)
fish=n_mass[n_mass$either==0,]
fish$mass=log10(fish$mass)
attach(fish)
plot(niche,mass)
M0=lm(mass~niche)
summary(M0)
adjR.M0=summary(M0)$adj.r.squared
adjR.M0
abline(M0)

