################################################################################
# Script to process DecreeData.csv
################################################################################
library(dplyr)
library(leafletR)
library(rgdal)
library(rgeos)
library(maptools)

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
#loc<-data.frame(matrix(c(-112.09543,33.449245,-112.065735,33.701202,-114.41961,
#                         34.55366,-114.98839,36.04119,-114.62361,32.691235,
#                         -114.51914,33.60818,-115.56997,32.847363,-110.946495,
#                         32.236023),ncol=2,byrow=TRUE))
#user<-data.frame(WaterUser=c("ARIZONA STATE LAND DEPARTMENT","CENTRAL ARIZONA PROJECT",
#        "CHEMEHUEVI INDIAN RESERVATION","CITY OF HENDERSON","CITY OF YUMA",
#        "EHRENBURG IMPROVEMENT ASSN.","IMPERIAL IRRIGATION DISTRICT",
#        "UNIVERSITY OF ARIZONA"))
#names(loc)<-c("long","lat")
#loc<-cbind(user,loc)
#five_yr_2<-merge(five_yr, loc, by = "WaterUser")
#write.csv(five_yr_2,"src_data/wat_acc_examp.csv",row.names=FALSE)

#Get the values of last five years by WaterUser
topFiveYrs <- dataSub %>%
  group_by(WaterUser) %>%
  arrange(desc(Year)) %>%
  slice(1:5)

#Get the mean for each wateruser for last five years
contMean <- summarise(group_by(topFiveYrs, WaterUser,ContractorID), m = mean(Value))
contMean <- dplyr::rename(contMean, Contractor=WaterUser, OBJECTID_1=ContractorID, mean=m)

#Rip out NA ContractorID
contMean <- filter(contMean, OBJECTID_1 != "NA")
#probably want to do it this way because Jordan says the way I'm doing it is fragile
#contMean <- filter(contMean, !is.na(OBJECTID_1))
sortedContData <- contMean[order(contMean$OBJECTID_1),]

#get a list of ids we have data for
myIDs <-sortedContData$OBJECTID_1

#read in the shapefile of service area polygons
cont <- readOGR("src_data//LCContractSvcAreas","LC_Contracts_diss")
sortedCont <- cont[order(cont$OBJECTID_1),]

#get only the polygons that are in our NA list

sub.cont <- subset(sortedCont, OBJECTID_1 %in% myIDs)

#add a blank field for mean in the polygon file
sub.cont$mean <- c(NA)

sub.cont <- sub.cont[order(sub.cont$OBJECTID_1),]

#give the data the same names as the polygon file
row.names(sub.cont)<- row.names(sortedContData)

#Create the new spatialpdf

cont.watacc <- SpatialPolygonsDataFrame(sub.cont, data = as.data.frame(sortedContData))

#write out the shapefile and the geojson
writeOGR(cont.watacc,"src_data//LCContractSvcAreas","wat_acc_cont", driver = "ESRI Shapefile", overwrite_layer = T)
wat_acc_cont <- toGeoJSON(cont.watacc, dest = "src_data//LCContractSvcAreas")


