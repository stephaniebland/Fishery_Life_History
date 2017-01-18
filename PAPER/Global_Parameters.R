# ---- Global_Parameters ----
rm(list=ls())
setwd("/Users/JurassicPark/Google Drive/GIT/Masters Project")
library(R.matlab)
test=readMat("garbage.mat")
masscalc=as.data.frame(test$masscalc)$`1.1`
lifehis=as.data.frame(test$lifehis)$`1.1`
prob_mat=as.data.frame(test$prob.mat)$`1.1`
num_years=as.data.frame(test$num.years)$`1.1`
leslie=as.data.frame(test$leslie)$`1.1`
meta_scale=as.data.frame(test$meta.scale)$`1.1`
assim=as.data.frame(test$assim)$`1.1`
func_resp=as.data.frame(test$func.resp)$`1.1`
invert=as.data.frame(func_resp$invert)$`1.1`
fish=as.data.frame(func_resp$fish)$`1.1`
herb=as.data.frame(fish$herb)$`1.1`




Params=c(test,masscalc,lifehis,prob_mat,num_years,leslie,meta_scale,assim,invert,fish,herb)
rm(list=setdiff(ls(),c('Params','test')))
x=names(Params)

xkcd=unique(x)

symb=descript=unit=refer=list()
symb$ca="dsf"
descript$ca="fdsaf"
unit$ca="dfsf"
refer$ca="sfkj"


calvin=Params


#for (i in 1:length(x){
  hobbes=x[1]
  as.character(hobbes)
  Params$Adj.Rsq
  #Params$as.symbol(hobbes)
#}

hobbes=x[1]
hobbes=as.character(hobbes)
#eval(parse(text=hobbes))

#as.name(hobbes)=list()
#assign(hobbes, list())

#eval(parse(text=hobbes))$erw=5
#as.name(hobbes)$ldfsj=5

#Adj.Rsq

#eval(as.name(paste(hobbes)))$welr=5

do.call("<-",list(hobbes, 4))

y=as.symbol(hobbes)
#as.symbol(hobbes)$er=4

list1 <- 1:10
list2 <- 11:20


#as.symbol(hobbes)=data.frame(list1, list2)

do.call("<-",list(hobbes, data.frame(list1, list2)))

trial=data.frame(matrix(NA,length(unique(x)),5),row.names = unique(x))
names(trial)=c("Symbol", "Description", "Value", "Unit", "Reference")


trial[x[2],1]
trial[x[2],]
as.list(trial)


simpsons=list(matrix(NA,length(unique(x)),5),row.names = unique(x))

pizza=list(length(unique(x)))
#names(pizza)=unique(x)


#STORE STUFF AS LIST 

thingity=5
