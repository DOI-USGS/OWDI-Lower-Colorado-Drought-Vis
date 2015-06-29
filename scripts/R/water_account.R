################################################################################
## Script for developing water accounting use viz
## Slide 7
## Authors: J.W. Hollister
##          Megan Hines
## Date: May 15, 2015
################################################################################

# leaflet, miscPackage, and quickmapr packages not on CRAN, install with:
# devtools::install_github("rstudio/leaflet")
# devtools::install_github("jhollist/quickmapr)
# more: https://rstudio.github.io/leaflet/

#devtools::install_github("chgrl/leafletR")
#Package had a bug when styling multiple layers
#Fix is in my repo, but legends need to be added
#manually
library(devtools)

if(!require(leafletR)){
	devtools::install_github("jhollist/leafletR")
	library(leafletR)
}
if(!require(miscPackage)){
	devtools::install_github("jhollist/miscPackage")
	library(miscPackage)
}

library(htmlwidgets)
library(rgdal)
library(rgeos)
library(sp)
library(dplyr)

################################################################################
# Get Data set up
################################################################################
#wbdhu2_lco<-readOGR("src_data//CO_WBD","WBDHU2_14-15-clean")
#wbdhu4_lco<-readOGR("src_data//CO_WBD","WBDHU4_14-15-clean")
p4s<-"+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"
lc_huc_simp <-readOGR("src_data//CO_WBD","lc_huc_simp-clean")
wat_acc_examp <- read.csv("src_data//wat_acc_examp.csv")
wae_coord <- coordinates(wat_acc_examp[,3:4])
wae_data <- wat_acc_examp[,1:2]
wat_acc_sp <- SpatialPointsDataFrame(wae_coord,data=wae_data,
                                     proj4string = CRS(p4s))

#clean up water use contract polygons, subset only data we want by dropping some columns
wat_use_con<-readOGR("src_data//LCContractSvcAreas","LC_Contacts_update2014")
wat_subs<-wat_use_con[,-c(2:9,11:26)]
writeOGR(wat_subs,"src_data//LCContractSvcAreas","LC_Contracts_subset", driver = "ESRI Shapefile", overwrite_layer = T)

#dissolve polys so that we have one polygon per contract user
library(maptools)
wat_use_con<-readOGR("src_data//LCContractSvcAreas","LC_Contracts_subset")
cont.union<-unionSpatialPolygons(wat_use_con,IDs = paste(wat_use_con$Contractor))
df <- as(wat_use_con, "data.frame")[!duplicated(wat_use_con$Contractor),]
sorted_df <- arrange(df, Contractor)
row.names(sorted_df)<- row.names(cont.union)
cont.diss <- SpatialPolygonsDataFrame(cont.union, data = sorted_df)
writeOGR(cont.diss,"src_data//LCContractSvcAreas","LC_Contracts_diss", driver = "ESRI Shapefile", overwrite_layer = T)


################################################################################
#rstudio/leaflet implementation
################################################################################
#water_account <- leaflet::leaflet() %>% 
#  addPolygons(data=wbdhu4_lco, opacity=0.4,weight = 3) %>%
#  addPolygons(data=wbdhu2_lco, opacity=1 , weight = 4, color="red", fill = FALSE) %>% 
#  addCircleMarkers(data=wat_acc_sp,
#                   color="green",
#                   radius= ~wae_brk, 
#                   popup = ~paste0("<strong>Water User: </strong>", WaterUser, "<br/>",
#                                   "<strong>Consumptive Use 5-year average: </strong>", LastFiveMean))%>%
#  addProviderTiles("Esri.WorldTopoMap") %>%
#  addControl(html="test")
#water_account

#setwd("public_html//widgets//slide_7/")
#saveWidget(water_account,file="water_accounting.html",
#           selfcontained=FALSE)

################################################################################
#leafletR implementation
################################################################################
#Data
lc_huc_gjson <- toGeoJSON(lc_huc_simp, dest = "public_html/data")
wae_gjson <- toGeoJSON(wat_acc_sp, dest = "public_html/data")
dat<-list(wae_gjson,lc_huc_gjson)

#Styles
lc_huc_sty <- styleSingle(col="slategray", lwd=5, alpha=0.8)
wae_brk <- as.numeric(quantile(wat_acc_examp$LastFiveMean, c(0,0.25,0.75,1)))
wae_sty <- styleGrad(prop="LastFiveMean",breaks = wae_brk,
                     style.par = "rad",
                     style.val=c(7,20,33))
sty<-list(wae_sty,lc_huc_sty)

#New Basemaps
addBaseMap(
  name="Esri.WorldTopoMap", 
  title="ESRI World Topo", 
  url="http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}",
  options=list(
    attribution='Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ, TomTom, Intermap, iPC, 
    USGS, FAO, NPS, NRCAN, GeoBase, Kadaster NL, Ordnance Survey, Esri Japan, METI, 
    Esri China (Hong Kong), and the GIS User Community'
  )
)

#Build Map
water_account <- leafletR::leaflet(data=dat,
                                   base.map=list("osm","Esri.WorldTopoMap"),
                                   title="water_accounting",
                                   style=sty, 
                                   popup = list(c("WaterUser","LastFiveMean"),c("")),
                                   dest="public_html/widgets/",
                                   incl.data = F,
                                   controls=c("all"))
#water_account

#Legend - Manual changes to output html

# #Add to CSS 
# 
# .grad-legend {
#   background: #0033ff;
#   border-radius: 50%; 
#   margin-top: 8px;
#   text-align: center;
#   clear: both;
# }
# 
# #Add to <div class="map"
# <div class="leaflet-bottom leaflet-right" style="margin-bottom: 25px">
#   <div class="info legend leaflet-control">
#     <i class="grad-legend" style="width: 7px; height: 7px;"></i></br>
#     <p style="float: left;">Low Use</p> 
#     <i class="grad-legend" style="width: 20px; height: 20px; "></i></br>
#     <p style="float: left;">Medium Use</p>
#     <i class="grad-legend" style="width: 33px; height: 33px; "></i></br>
#     <p style="float: left;">High Use</p>
#   </div>
# </div>
