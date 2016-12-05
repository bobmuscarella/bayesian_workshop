## JAGS example -- Lizards on islands ##

library(rjags)
library(R2jags)

islands<-read.csv("island_data.csv")

head(islands)

islands<-islands[order(islands$perimeter.area),]

plot(islands$perimeter.area,islands$present)

#STORE DATA AS LIST FOR JAGS
data<-list(
  perim=as.numeric(islands$perimeter.area),
  pres=as.numeric(islands$present),
  ndat=length(islands$perimeter.area),
  xhat=as.vector(1:60)) #add this in to get predictions

str(data) #always check this - good way to find errors (e.g. vectors of different lengths or not numeric)

#WRITE MODEL TO FILE
write("
      
      model{

    #priors

    b0~dnorm(0,0.001)
    b1~dnorm(0,0.001)

    #likelihood
    
    for (i in 1:ndat){
    pres[i]~dbern(p[i])
    logit(p[i])<-b0+b1*perim[i]
}

  #DERIVED

    for (i in 1:length(xhat)){
    phat[i]<-b0+b1*xhat[i]
    }

  #diff between islands
  pdiff<-(b0+b1*10)-(b0+b1*20)
  ipdiff<-ilogit(pdiff) #back-transform from logit scale

  b0BT<-ilogit(b0) #back-transform from logit, want this to be a proportion (between 0 and 1)
  

      }
      
      ","islands_example.jags")

plogis(0.9+0.2) #check to make sure b0 + b1 is always between (not including) 0 and 1

inits<-list(
  list(b0=0.5,b1=0.3),
  list(b0=0.3,b1=0.5),
  list(b0=0.9,b1=0.2))

params<-c("b0","b1","b0BT","phat","ipdiff") #everything you want to monitor goes here

islands1<-jags(data,inits, params, model.file="islands_example.jags", n.chains=3,n.iter=20000,n.burnin=10000, n.thin=1, DIC=TRUE, working.directory=NULL, progress.bar = "text")

plot(islands1)
traceplot(islands1)
par(ask=F)

#Extract mean and CI's (i.e., summarize the posterior)

islands.out<-as.data.frame(islands1$BUGSoutput$summary[,c('mean','sd','2.5%','97.5%','Rhat')])
head(islands.out)

# this bit is a handy way to extract the stuff that comes before the square brackets, so that you can subset based on the name of the parameter
islands.out$param<-as.vector(sapply(strsplit(rownames(islands.out),"[[]",fixed=FALSE), "[", 1))
head(islands.out)

#PLOT

plot(islands) #raw data

library(ggplot2)

ggplot()+
  layer(data=islands,geom="point",mapping=aes(x=perimeter.area,y=present))+
  layer(data=islands.out[islands.out$param=="phat",],geom="line",mapping=aes(x=c(1:60),y=I(plogis(`2.5%`))),linetype="dashed")+
  layer(data=islands.out[islands.out$param=="phat",],geom="line",mapping=aes(x=c(1:60),y=I(plogis(`97.5%`))),linetype="dashed")+
  layer(data=islands.out[islands.out$param=="phat",],geom="line",mapping=aes(x=c(1:60),y=I(plogis(`mean`))))+
  theme_bw()+theme(axis.text.x=element_text(size=20,face="plain",angle=0,vjust=0,hjust=0.5),axis.text.y=element_text(hjust=0,size=20),axis.title.x=element_text(size=22,face="bold"),axis.title.y=element_text(angle=90,size=26,face="bold",vjust=0.1),axis.ticks = element_blank(),strip.text.x=element_text(size=22),strip.background=element_rect(fill="white",size=0),panel.grid.minor=element_blank(), panel.grid.major=element_blank())+xlab("\nPerimeter Area")+ylab("PROBABILIYT OF PRESENCE\n")

#derived quantity of pdiff

islands.out[islands.out$param=="ipdiff",] 

