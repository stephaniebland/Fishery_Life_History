# ---- Von_Bert ----
# first, your data
q=0.0125
L_inf=28.4
K=0.37
t_0=-0.2



# Write Von-Bert Function
VonBert=function(t){
  q*(L_inf^3)*((1-exp(-K*(t-t_0)))^3)
}


W_inf=q*(L_inf^3)# Not needed for plot, just good to know what W_inf is 


# Create plot
curve(VonBert,0,8,xlab='Time (age)',ylab='Weight (grams)')


#Extra stuff because nothing makes sense anymore and I want to test stuff
VonBert_length=function(t){
  L_inf*(1-exp(-K*(t-t_0)))
}

