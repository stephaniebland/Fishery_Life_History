
# first, your data
lifestage=1:9
min_niche=c(5,7,7,8,6,11,12,10,14)
spec_gener=c(3,5,2,4,4,1,3,6,3)
max_niche=min_niche+spec_gener
Prey_niche_val=data.frame(lifestage,min_niche,max_niche)

library(reshape2)
library(ggplot2)
# Create the floating bar plot
ggplot(Prey_niche_val, aes(x=lifestage,ymin = `min_niche`, 
              ymax = `max_niche`,middle=`min_niche`,lower = `min_niche`, 
              upper = `max_niche`)) + 
  geom_boxplot(stat = 'identity') +
  xlab('Lifestage') + 
  ylab('Prey Niche Range') +
scale_x_continuous(breaks=lifestage)+scale_y_continuous(breaks=0:30,limits = c(0,20))
