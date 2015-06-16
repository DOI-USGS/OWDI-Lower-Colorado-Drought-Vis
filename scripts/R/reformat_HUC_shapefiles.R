
################################################################################
#Used to generate clean topology and generalize.
#Tolerance of 0.0005 nice trade off between size of files (both under 1Mb) and 
#accuracy of geography.
#Added lower CO boundary from Alan.  had some stray poly's/points.
#Note: Commented out as it is a one off run.  data are availble in 
#src_data/CO_WBD
################################################################################

# both spgrass7 and rgrass7 seem to work
#library(spgrass7) # not available for R 3.2.0
library(rgrass7)
library(rgdal)
library(rgeos)
library(raster)

#grassFolder <- "/usr/local/grass-7.0.0/"
grassFolder <- "C:/Program Files (x86)/GRASS GIS 7.0.1svn"

initGRASS(grassFolder,override=TRUE, home=tempdir())
execGRASS("v.in.ogr",input="src_data//CO_WBD//WBDHU4_14-15.shp", snap=1e-07, 
         output="hu4",flags = c("o","overwrite"))
execGRASS("v.in.ogr",input="src_data//CO_WBD//LC_UC_HUCs_wMexico_20140820.shp", snap=1e-07, 
       output="lc_huc",flags = c("o","overwrite"))
execGRASS("v.generalize",input="hu4",output="hu4_simp",threshold=0.0005,method="douglas",
                  flags=c("overwrite","verbose"))
execGRASS("v.generalize",input="lc_huc",output="lc_huc_simp",threshold=0.0005,method="douglas",
                  flags=c("overwrite","verbose"))

################################################################################
#Aggregate into HUC2.  Using this to make sure linework is the same.  
#Could be slightly different with hu2 built and generalized separately.
################################################################################
wbdhu4_lco<-readVECT("hu4_simp")
lc_huc_simp <- readVECT("lc_huc_simp")
HUC2<-substr(as.character(wbdhu4_lco$HUC4),1,2)
wbdhu4_lco@data$HUC2<-HUC2
wbdhu2_lco<-aggregate(wbdhu4_lco,vars='HUC2')

################################################################################
#Add CRS
################################################################################
p4s<-"+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"
proj4string(wbdhu4_lco)<-p4s
proj4string(wbdhu2_lco)<-p4s
proj4string(lc_huc_simp)<-p4s

################################################################################
#Write Out to Shape
################################################################################
writeOGR(wbdhu4_lco,"src_data//CO_WBD","WBDHU4_14-15-clean",driver = "ESRI Shapefile",
         overwrite_layer = T)
writeOGR(wbdhu2_lco,"src_data//CO_WBD","WBDHU2_14-15-clean",driver = "ESRI Shapefile",
         overwrite_layer = T)
writeOGR(lc_huc_simp,"src_data//CO_WBD","lc_huc_simp-clean",driver = "ESRI Shapefile",
         overwrite_layer = T)
