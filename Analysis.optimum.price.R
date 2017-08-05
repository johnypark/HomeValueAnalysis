##scarped Gainesville homes from website 

source("required.packages.R")
Gville.073017<-read.csv("2017-07-30_182750.csv")
Gville.073017 %>% names

sale.type.levels<-Gville.073017$sale_type%>%levels()

Gville.073017%>%filter(sale_type%in%sale.type.levels[-c(5,6,12,13)])%>%
  filter(bedrooms%in%c(2,3))%>%group_by(bedrooms,bathrooms)%>%
  #summarise(md_price=median(price,na.rm=TRUE),sd_price=sd(price,na.rm=TRUE))%>%
  ggplot(aes(x=bathrooms,y=price,fill=zip))+geom_boxplot()+facet_grid(bedrooms ~ .)


  
  summarise(md_price=median(price,na.rm=TRUE),sd_price=sd(price,na.rm=TRUE))

c(5,6,12,13)


Gville.073017$date<-"2017-07-31"%>%as.Date

df.FL<-Gville.073017

df.FL$state<-"FL"

df.073017<-read.csv("2017-07-30_221151.csv")
df.073017$date<-"2017-07-31"%>%as.Date
df.NJ<-df.073017
df.NJ$state<-"NJ"
df.US.listings<-rbind(df.NJ,df.FL)

df.073117<-read.csv("2017-07-31_084041.csv")
df.073117$date<-as.Date("2017-07-31")
df.073117$state<-"NJ"
df.US.listings%<>%rbind(df.073117)
df.US.listings$bedrooms%<>%as.character()
df.US.listings$sqft%<>%as.numeric()

df.US.listings%>%filter(sale_type%in%sale.type.levels[-grep("Fore",sale.type.levels)])%>%
  filter(bedrooms%in%c("2","3","4"))%>%group_by(bedrooms,bathrooms)%>%
  filter(bathrooms%in%c("2","2.5","3"))%>%
  #summarise(md_price=median(price,na.rm=TRUE),sd_price=sd(price,na.rm=TRUE))%>%
  ggplot(aes(x=bathrooms,y=price,fill=city))+geom_boxplot()+facet_grid(bedrooms ~ .)+
  ylim(c(0,df.US.listings$price%>%quantile(.,0.8, na.rm=TRUE)))

sale.type.levels<-df.US.listings$sale_type%>%levels()




##fill in zeros in the front
for( i in 4:1){
  
 ifelse(df.US.listings$zip%>%nchar==i,
        #add 5-i number of zeros to the existing string 
        df.US.listings[df.US.listings$zip%>%nchar==i,"zip"]<-
        rep(0,(5-i))%>%
          as.character%>%paste(collapse="")%>%
          paste0(df.US.listings[df.US.listings$zip%>%nchar==i,"zip"]),no = NA) 
  
}


library(zipcode)
data(zipcode)
data("zipcode.civicspace")



sprintf(
   "%s%s",
   rep(0,5)%>%as.character,
   "ha"
   )

paste0(rep(0,5)%>%as.character,
       "ha",collapse="")

zipcode%>%filter(zip==(df.US.listings$zip))

zipcode[t,]

df.US.listings$city<-zipcode[]$city
a = c(5,7,2,9)
ifelse(a %% 2 == 0,"even","odd")

df.US.listings%>%ggplot(aes(zip))+geom_bar()

match.zip.city.1<-function(zip.vec){
  city.vec<-rep(0,length(zip.vec))
  for(i in 1:length(zip.vec)){
  city.vec[i]<-zipcode[zipcode$zip==zip.vec[i],"city"]
  
  
  }
  return(city.vec) #takes 1.564 sec
}


match.zip.city.2<-function(zip.vec){
  zip.unique<-zip.vec%>%unique
  
  city.vec<-rep(0,length(zip.unique))
  for(i in 1:length(zip.unique)){
    city.unique<-zipcode[zipcode$zip==zip.unique[i],"city"]
    zip.unqie.index<-which(zip.vec==zip.unique[i])
    city.vec[zip.unqie.index]<-city.unique
  
    }
  return(city.vec) #takes 0.008
  }


city.list<-match.zip.city.2(df.US.listings$zip)
df.US.listings$city<-city.list



df.US.listings%>%filter(sale_type%in%sale.type.levels[-grep("Fore",sale.type.levels)])%>%
  filter(bedrooms%in%c("2","3","4"))%>%group_by(bedrooms,bathrooms)%>%
  filter(bathrooms%in%c("2","2.5","3"))%>%
  #summarise(md_price=median(price,na.rm=TRUE),sd_price=sd(price,na.rm=TRUE))%>%
  ggplot(aes(x=sqft,y=price,colour=city))+geom_point()+
  #facet_grid(bedrooms ~ .)+
  ylim(c(0,df.US.listings$price%>%quantile(.,0.8, na.rm=TRUE)))+geom_smooth(method="lm")


df.US.listings.by.city<-df.US.listings%>%group_by(city)%>%nest()

model1<-function(df,xvar,yvar){
 df %$%lm(.[[yvar]]~.[[xvar]]) 
}


df.US.listings.by.city %<>% 
  mutate(
    
    model=data%>%map(model1,"sqft","price"),
    summary=model%>%map(broom::glance)
    
    
  )

df.US.listings


