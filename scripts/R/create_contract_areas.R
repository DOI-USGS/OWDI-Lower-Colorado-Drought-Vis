################################################################################
## Script for cleaning up contract user shapefile and joining with decree data
## Pumps out a new shapefile and a geojson file
## Authors: Megan Hines, Jordan Read
## Date: July 7, 2015
################################################################################
library(rgdal)
library(rgeos)
library(sp)
library(dplyr)
library(maptools)
library(leafletR)

#clean up water use contract polygons, subset only data we want by dropping some columns
wat_use_con<-readOGR("src_data//LCContractSvcAreas","LC_Contacts_update2014")
wat_subs<-wat_use_con[,-c(2:9,11:26)]
writeOGR(wat_subs,"src_data//LCContractSvcAreas","LC_Contracts_subset", driver = "ESRI Shapefile", overwrite_layer = T)

#dissolve polys so that we have one polygon per contract user
wat_use_con<-readOGR("src_data//LCContractSvcAreas","LC_Contracts_subset")
cont.union<-unionSpatialPolygons(wat_use_con,IDs = paste(wat_use_con$Contractor))
df <- as(wat_use_con, "data.frame")[!duplicated(wat_use_con$Contractor),]
sorted_df <- arrange(df, Contractor)
row.names(sorted_df)<- row.names(cont.union)
cont.diss <- SpatialPolygonsDataFrame(cont.union, data = sorted_df)
writeOGR(cont.diss,"src_data//LCContractSvcAreas","LC_Contracts_diss", driver = "ESRI Shapefile", overwrite_layer = T)

#extract water user data we want
data <- read.csv('src_data//LBDecreeAccounting//DecreeData.csv')
dataSub <- filter(data, Variable == "ConsumptiveUse")

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
#get rid of those damn quotes
cont.watacc$Contractor <- gsub('"',"",cont.watacc$Contractor)
#write out the shapefile and the geojson
writeOGR(cont.watacc,"src_data//LCContractSvcAreas","wat_acc_cont", driver = "ESRI Shapefile", overwrite_layer = T)
#wat_acc_cont <- toGeoJSON(cont.watacc, dest = "src_data//LCContractSvcAreas")
