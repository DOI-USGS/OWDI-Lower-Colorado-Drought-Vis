################################################################################
## Script for cleaning up contract user shapefile and joining with decree data
## Pumps out a new shapefile and a geojson file
## Authors: Megan Hines, Jordan Read
## Date: July 7, 2015
################################################################################
library(rgdal)
library(rgeos)
library(sp)
library(leafletR)

#clean up water use contract polygons, subset only data we want by dropping some columns
wat_use_con<-readOGR("src_data//LCContractSvcAreas","LC_Entitlement_Service_Areas_wCU")

sortedEntitlements <- wat_use_con[order(-wat_use_con$Shape_Area),]

#Create the new spatialpdf
cont.watacc <- SpatialPolygonsDataFrame(sortedEntitlements, data = as.data.frame(sortedEntitlements))

#write out the shapefile and the geojson
writeOGR(cont.watacc,"src_data//LCContractSvcAreas","wat_acc_cont", driver = "ESRI Shapefile", overwrite_layer = T)
wat_acc_cont <- toGeoJSON(cont.watacc, dest = "public_html//data", name="wat_acc_cont")
