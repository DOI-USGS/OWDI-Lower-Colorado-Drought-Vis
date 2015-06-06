
require(rgdal)
library(rgeos)
library(magrittr)
simp_tol <- 3000
min_area <- 1e+9
ylim <- c(-2158000, -1182596) # in epsg:2163"
xlim <- c(-1950000, 1300000)
lo_co_states <- c("California","Nevada","Arizona")

plot_dir = '../public_html/img'

mexico = readOGR(dsn = "../src_data/mexico",layer="MEX_adm0") %>%
  spTransform(CRS("+init=epsg:2163")) %>%
  gSimplify(simp_tol)

states = readOGR(dsn = "../src_data/states_21basic",layer="states") 

lo_co_borders <- states[states$STATE_NAME %in% lo_co_states,] %>%
  spTransform(CRS("+init=epsg:2163")) %>%
  gSimplify(simp_tol)
other_borders <- states[!states$STATE_NAME %in% lo_co_states,] %>%
  spTransform(CRS("+init=epsg:2163")) %>%
  gSimplify(simp_tol)

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

svg(filename = file.path(plot_dir,paste0('lo_CO_borders','.svg')), width=7.5, height=7.1)
par(omi=c(0,0,0,0),mai=c(0,0,0,0))
plot(other_borders, ylim = ylim, xlim = xlim, border='grey90')
plot(mex_simp, add=TRUE)
plot(lo_co_borders, add=TRUE)
dev.off()

