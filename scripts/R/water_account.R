################################################################################
## Script for developing water accounting use viz
## Slide 7
## Authors: J.W. Hollister
##          Emily Read
##          Laura DeCicco
## Date: May 15, 2015
################################################################################

# leaflet, miscPackage, and quickmapr packages not on CRAN, install with:
# devtools::install_github("rstudio/leaflet")
# devtools::install_github("jhollist/quickmapr)
# more: https://rstudio.github.io/leaflet/

devtools::install_github("jhollist/leafletR")
library(leafletR)
library(htmlwidgets)
library(rgdal)
library(rgeos)
library(sp)
library(miscPackage)



################################################################################
#Used to generate clean topology and generalize.
#Tolerance of 0.0005 nice trade off between size of files (both under 1Mb) and 
#accuracy of geography.
#Added lower CO boundary from Alan.  had some stray poly's/points.
#Note: Commented out as it is a one off run.  data are availble in 
#src_data/CO_WBD
################################################################################
library(spgrass6)
library(raster) 
initGRASS("C:\\Program Files (x86)\\GRASS GIS 7.0.1svn",override=TRUE,
          home=tempdir())
#execGRASS("v.in.ogr",input="src_data//CO_WBD//WBDHU4_14-15.shp", snap=1e-07, 
#          output="hu4",flags = c("o","overwrite"))
execGRASS("v.in.ogr",input="src_data//CO_WBD//LC_HUCs_wMexico_20140714.shp", snap=1e-07, 
        output="lc_huc",flags = c("o","overwrite"))
#execGRASS("v.generalize",input="hu4",output="hu4_simp",threshold=0.0005,method="douglas",
#                   flags=c("overwrite","verbose"))
execGRASS("v.generalize",input="lc_huc",output="lc_huc_simp",threshold=0.0005,method="douglas",
                   flags=c("overwrite","verbose"))

################################################################################
#Aggregate into HUC2.  Using this to make sure linework is the same.  
#Could be slightly different with hu2 built and generalized separately.
################################################################################
#wbdhu4_lco<-readVECT("hu4_simp")
lc_huc_simp <- readVECT("lc_huc_simp")
#HUC2<-substr(as.character(wbdhu4_lco$HUC4),1,2)
#wbdhu4_lco@data$HUC2<-HUC2
#wbdhu2_lco<-aggregate(wbdhu4_lco,vars='HUC2')



################################################################################
#Add CRS
################################################################################
p4s<-"+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"
#proj4string(wbdhu4_lco)<-p4s
#proj4string(wbdhu2_lco)<-p4s
proj4string(lc_huc_simp)<-p4s

################################################################################
#Write Out to Shape
################################################################################
#writeOGR(wbdhu4_lco,"src_data//CO_WBD","WBDHU4_14-15-clean",driver = "ESRI Shapefile")
#writeOGR(wbdhu2_lco,"src_data//CO_WBD","WBDHU2_14-15-clean",driver = "ESRI Shapefile")
writeOGR(lc_huc_simp,"src_data//CO_WBD","lc_huc_simp-clean",driver = "ESRI Shapefile")


################################################################################
# Get Data set up
################################################################################
#wbdhu2_lco<-readOGR("src_data//CO_WBD","WBDHU2_14-15-clean")
#wbdhu4_lco<-readOGR("src_data//CO_WBD","WBDHU4_14-15-clean")
lc_huc_simp <-readOGR("src_data//CO_WBD","LC_HUCs_wMexico_20140714")
wat_acc_examp <- read.csv("src_data//wat_acc_examp.csv")
wae_brk <- as.numeric(as.character(cut(wat_acc_examp$LastFiveMean,
                                       quantile(wat_acc_examp$LastFiveMean, c(0,0.25,0.75,1)),
                                       c(5,15,25),
                                       include.lowest=TRUE)))
wae_coord <- coordinates(wat_acc_examp[,3:4])
wae_data <- wat_acc_examp[,1:2]
wat_acc_sp <- SpatialPointsDataFrame(wae_coord,data=wae_data,
                                     proj4string = CRS(proj4string(wbdhu2_lco)))


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
lc_huc_gjson <- toGeoJSON(lc_huc_simp,dest="src_data/CO_WBD")
wae_gjson <- toGeoJSON(wat_acc_sp,dest="src_data/CO_WBD")

dat<-list(lc_huc_gjson,wae_gjson)
lc_huc_sty <- styleSingle(col="red")#, lwd=5, alpha=0.5)
#wae_brk <- as.numeric(quantile(wat_acc_examp$LastFiveMean, c(0,0.25,0.75,1)))
#wae_sty <- styleGrad("LastFiveMean",
#                     breaks= c(0,5000,10000), 
#                     style.par = "rad",
#                     style.val=c(5,20))
wae_sty <- styleSingle(col="green")
sty<-list(lc_huc_sty,wae_sty)
water_account <- leafletR::leaflet(data=dat,
                                   base.map=list("osm","mqsat"),
                                   style=sty, 
                                   popup = list("HUC2",c("WaterUser","LastFiveMean")),
                                   dest="public_html/widgets/slide_7/",
                                   incl.data = FALSE,
                                   controls=c("all"))
water_account
