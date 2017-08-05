##def=== loadInfodf

df.all<-read.csv("City_Zhvi_3bedroom.csv")


loadInfo<-function(df,setNcol=NULL,ts_range=NULL){
  tmp<-list()
  if(is.null(setNcol)){
  setNcol<-c(1:6)}
  if(is.null(ts_range)){
  ts_range<-c("1996-04-01","2017-06-01")}
  tmp$CatColnames<-df%>%names%>%.[setNcol]
  tmp$Dates_in_ts<-seq.Date(ts_range[1]%>%as.Date, ts_range[2]%>%as.Date,by="month")
  tmp$StateNames<-df$State%>%as.character%>%unique
  return(tmp)
}

##use str function

##def=== getPrice_bycity 
getPrice_bycity2<-function(df.all,city.name,state.name){
  df.all.info<-loadInfo(df.all)
data.frame(date=df.all.info$Dates_in_ts,
           price=df.all%>%
             filter_("%s=='%s'"%>%sprintf(df.all.info$CatColnames[2],city.name))%>%
             filter_("%s=='%s'"%>%sprintf(df.all.info$CatColnames[3],state.name))%>%
             select(-one_of(df.all.info$CatColnames))%>%as.numeric,
            state=state.name,
            city=city.name) %>%
  mutate(year=year(date))%>%
  group_by(year,city)%>%
  summarise(avg_price=mean(price,na.rm=TRUE))
}

city.name="Princeton"; state.name="NJ"

getPrice_bycity2(df.all,"Princeton","NJ")%>%
  ggplot(aes(year,avg_price))+geom_point()+geom_line()+
  ggtitle(city.name%>%paste(state.name,sep=", "))+ylim(c(100000,700000))



##time series by STATES
price_bystate<-list()

for(this.state in Name.States){
  
  price_bystate[[this.state]]<-data.frame( date=Dates_in_ts,
                                           price=df.all[df.all$State==this.state,7:261]%>%colMeans(na.rm=TRUE),
                                           state=this.state
  )
}

price_bystate<-do.call("rbind",price_bystate)

price_bystate_yearly<-price_bystate%>%mutate(year=year(date),month=month(date))%>%
  group_by(state,year)%>%
  summarise(avg_price=mean(price,na.rm=TRUE),sd_price=sd(price,na.rm=TRUE))

state_for_fig="FL"

ggplot(price_bystate_yearly%>%filter(state==state_for_fig),aes(x=year))+
  geom_point(aes(y=avg_price))+
  geom_line(aes(y=avg_price))+
  geom_errorbar(aes(ymax=avg_price+sd_price,
                    ymin=avg_price-sd_price
  )
  )


##use gganimate
##ggmap?
##raster data

func1<-function(vector.1){ #infinite loop
 i=1;
  while (!vector.1[i]%>%is.null) 
  i=i+1;
  return(i)
  
}



func2<-function(vector.1){ #infinite loop
  i=1;
  while (!vector.1[i]%>%is.na) 
    i=i+1;
  return(i-1)
  
}
#test vec.1<-rep("NJ",100); vec.1[56]="NA"; vec.1%>%func2; vec.1[56]=NA' vec.1%>%func2
#when element is "NA": returns as intended
#when element is NA: returns 56 instead of 101 


