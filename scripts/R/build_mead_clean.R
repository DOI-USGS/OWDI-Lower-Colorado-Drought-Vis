################################################################################
## Script for cleaning up mead shapefile 
## Pumps out a new shapefile without islands
## Authors: Megan Hines, Jordan Read
## Date: July , 2015
################################################################################
library(rgdal)
library(rgeos)

#remove nonwater parts of lake mead shapefile
mead = readOGR(dsn = "src_data//lake_mead", layer="lakebnds")
meadclean <- mead[substr(mead$BNDTYPE,1,5) == "water", ]
writeOGR(meadclean,"src_data//lake_mead","meadwater", driver = "ESRI Shapefile", overwrite_layer = T)
