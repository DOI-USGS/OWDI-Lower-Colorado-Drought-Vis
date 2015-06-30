################################################################################
# Script to process DecreeData.csv
################################################################################
library(dplyr)
dat<-read.csv("src_data//LBDecreeAccounting//DecreeData.csv",
              stringsAsFactors=FALSE)

################################################################################
# Selects out last five years, calcs mean for total consumptive use/users and 
# throws out state totals
################################################################################
five_yr <- dat %>%
  filter(Year>2008)%>%
  filter(Variable=="ConsumptiveUse")%>%
  group_by(Year,WaterUser,ContractorID)%>%
  summarise(Value=sum(Value))%>%
  group_by(WaterUser,ContractorID)%>%
  summarise(LastFiveMean=mean(Value))%>%
  filter(WaterUser!="NEVADA TOTALS" & 
         WaterUser!="ARIZONA TOTALS" &
         WaterUser!="CALIFORNIA TOTALS" &
         LastFiveMean>100) %>%
  arrange(desc(LastFiveMean))

################################################################################
#Example location data for draft viz
#Locations from Census Geocoder - some approximate
################################################################################
loc<-data.frame(matrix(c(-112.09543,33.449245,-112.065735,33.701202,-114.41961,
                         34.55366,-114.98839,36.04119,-114.62361,32.691235,
                         -114.51914,33.60818,-115.56997,32.847363,-110.946495,
                         32.236023),ncol=2,byrow=TRUE))
user<-data.frame(WaterUser=c("ARIZONA STATE LAND DEPARTMENT","CENTRAL ARIZONA PROJECT",
        "CHEMEHUEVI INDIAN RESERVATION","CITY OF HENDERSON","CITY OF YUMA",
        "EHRENBURG IMPROVEMENT ASSN.","IMPERIAL IRRIGATION DISTRICT",
        "UNIVERSITY OF ARIZONA"))
names(loc)<-c("long","lat")
loc<-cbind(user,loc)
five_yr_2<-merge(five_yr, loc, by = "WaterUser")
write.csv(five_yr_2,"src_data/wat_acc_examp.csv",row.names=FALSE)


