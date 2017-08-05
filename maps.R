install.packages(c("maps", "mapdata"))

# the github version of ggmap, which recently pulled in a small fix I had
# for a bug 
devtools::install_github("dkahle/ggmap")



library(mapdata)
states <- map_data("state")
west_coast <- subset(states, region %in% c("california", "oregon", "washington"))

ggplot(data = west_coast) + 
  geom_polygon(aes(x = long, y = lat, group = group), fill = "palegreen", color = "black") + 
  coord_fixed(1.3)

ca_df <- subset(states, region == "california")
##home price per county in NJ, NY, FL
counties <- map_data("county")

name_state<-"new jersey"; abb_state<-"NJ"


draw_state_map<-function(name_state,abb_state){
  
fc_state<-subset(states, region == name_state)
fc_counties <- subset(counties, region == name_state)

#



##get 2017 avg price of 3 bedroom for each county 

df.2017<-df.all[,c(1:6,250:261)]

df.2017$price_2017<-df.2017[,-c(1:6)]%>%rowMeans(na.rm=TRUE) 

df.2017.bycounty<-df.2017%>%
  filter(State==abb_state)%>%
  group_by(CountyName)%>%
  summarise(
    avg_price=mean(price_2017,na.rm=TRUE),
    std_price=sd(price_2017,na.rm=TRUE)
    )%>% 
  mutate(subregion=CountyName%>%tolower)%>%
  select(-CountyName)

fc_counties%<>%inner_join(df.2017.bycounty,by="subregion")

cnames <- aggregate(cbind(long, lat) ~ subregion, data=fc_counties, FUN=mean)

fig<-ggplot(fc_counties, aes(long, lat))+
  geom_polygon(aes(fill = avg_price, group=group), color = "white")+
  geom_point(data = us.cities%>%filter(country.etc==abb_state), 
             mapping = aes(x = long, y = lat, label=name, color="red"),
             )+
  #geom_label_repel(data = us.cities%>%filter(country.etc==abb_state), 
  #                mapping = aes(x = long, y = lat, label=name))+
  geom_label_repel(data=cnames,aes(x=long,y=lat,label=subregion))
return(fig)
}
cowplot::plot_grid(fig.avg.price,fig.std.price)

qmap('New Jersey',zoom=8)+geom_polygon(fc_counties, aes(long, lat, fill = avg_price, group=group), color = "white")+
  geom_point(data = us.cities%>%filter(country.etc==abb_state), 
             mapping = aes(x = long, y = lat, label=name, color="red"),
  )
