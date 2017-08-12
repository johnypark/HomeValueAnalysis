


#def loadInfodf
loadInfdf<-function(Dat_frm, Ncol_cat=NULL, Range_ts=NULL){
  
  tmp<-list()
  if(is.null(Ncol_cat)){
    Ncol_cat<-c(1:6)
  }
  if(is.null(Range_ts)){
    Range_ts<- c("1996-04-01","2017-06-01")
  }
  
  tmp$CatColnames<-Dat_frm%>%names%>%.[Ncol_cat]
  tmp$TsDates<-seq.Date(Range_ts[1]%>%as.Date,Range_ts[2]%>%as.Date,by="month")
  
  return(tmp)
}

#def getPrice_bycity
getPrice_bycity<-function(Dat_frm,region.info){
  
  Dat_frm.info<-loadInfdf(Dat_frm)
  tmp<-data.frame(
    price=Dat_frm%>%
      filter(RegionName==region.info[1])%>%
      filter(State==region.info[2])%>%
      select(-one_of(Dat_frm.info$CatColnames))%>%as.numeric(),
    date=Dat_frm.info$TsDates,
    city=region.info[1],
    state=region.info[2]
  )%>%
    mutate(year=lubridate::year(date))%>%
    group_by(year,city,state)%>%
    summarise(med_price=median(price,na.rm=TRUE))
  return(tmp)
}

#def plotPrice_bycity
plotPrice_bycity<-function(Dat_frm,region.info){
  tmp.f<-getPrice_bycity(Dat_frm,region.info)%>%
    ggplot(data=.,aes(x=year,y=med_price))+
    geom_point()+
    geom_line()+
    ggtitle("%s, %s"%>%sprintf(region.info[1],region.info[2]))
  return(tmp.f)
}


#def getPrice_Ncities

getPrice_Ncities<-function(Dat_frm, df.region.info){
  tmp<-list()
  for(line in 1:dim(df.region.info)[1]){
    region.info<-rep(0,2)
    region.info[1]<-df.region.info[line,1]%>%as.character()
    region.info[2]<-df.region.info[line,2]%>%as.character()
    tmp[[line]]<-getPrice_bycity(Dat_frm,region.info)
  }
  tmp%<>%do.call("rbind",.)
  return(tmp)  
  
}


#def plotPrice_byRank 

plotPrice_byRank<-function(Dat_frm, Rank){
  
  df.highest15.info<-Dat_frm%>%arrange(-X2017.06)%>%.[Rank,]%>%
    select(RegionName,State)
  names(df.highest15.info)=c("city","state")
  df.Ncities<-getPrice_Ncities(Dat_frm,df.highest15.info)
  df.Ncities%<>%group_by(city)%>%mutate(region=paste(city,state,sep=", "))
  tmp.f<-df.Ncities%>%ggplot(aes(year,med_price,group=region,colour=region))+
    geom_point()+
    geom_line()+
    theme_bw()+
    viridis::scale_colour_viridis(discrete = TRUE)+
    ggtitle("Rank of home value from %s to %s"%>%sprintf(range(Rank)[1],range(Rank)[2]))
  return(tmp.f)
}