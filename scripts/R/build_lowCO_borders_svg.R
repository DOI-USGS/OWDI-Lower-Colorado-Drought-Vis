
require(rgdal)
library(rgeos)
library(magrittr)
width=7.5
height=7.1
simp_tol <- 7000
grey_simp_tol <- 1.3*simp_tol # less res for non-highlighted states
min_area <- 1e+10
epsg_code <- '+init=epsg:3479' #5070 for USGS CONUS albers?

ylim <- c(-1806051, 2054371) # in epsg_code
xlim <- c(-2693054, 5512372)
lo_co_states <- c("California","Nevada","Arizona")
keep_non <- c("Texas","Utah","Colorado","New Mexico","Oregon","Wyoming","Oklahoma","Nebraska","Kansas")

plot_dir = '../public_html/img'

mexico = readOGR(dsn = "../src_data/mexico",layer="MEX_adm0") %>%
  spTransform(CRS(epsg_code)) %>%
  gSimplify(simp_tol)

states = readOGR(dsn = "../src_data/states_21basic",layer="states") 

area <- lapply(mexico@polygons, function(x) sapply(x@Polygons, function(y) y@area))
mainPolys <- lapply(area, function(x) which(x > min_area))

# get rid of all polys below area threshold
mex_simp <- mexico
for(i in 1:length(mainPolys)){
  if(length(mainPolys[[i]]) >= 1 && mainPolys[[i]][1] >= 1){
    mex_simp@polygons[[i]]@Polygons <- mex_simp@polygons[[i]]@Polygons[mainPolys[[i]]]
    mex_simp@polygons[[i]]@plotOrder <- 1:length(mex_simp@polygons[[i]]@Polygons)
    
  }
}

svg(filename = file.path(plot_dir,paste0('lo_CO_borders','.svg')),width=width, height=height)
par(omi=c(0,0,0,0),mai=c(0,0,0,0))

# this keeps the svg paths in explicit order, for easy finding later
for (state in keep_non){
  state_border <- spTransform(states[states$STATE_NAME == state, ], CRS(epsg_code)) %>%
    gSimplify(simp_tol)
  
  if (state == keep_non[1]){
    plot(state_border, ylim = ylim, xlim = xlim, border='grey90')
  } else {
    plot(state_border, border='grey90', add=TRUE)
  }
}

plot(mex_simp, add=TRUE)

for (state in lo_co_states){
  state_border <- spTransform(states[states$STATE_NAME == state, ], CRS(epsg_code)) %>%
    gSimplify(simp_tol)
  plot(state_border, add=TRUE)
}

dev.off()


