
require(rgdal)
library(rgeos)
library(magrittr)
source('R/manipulate_lowCO_borders_svg.R')
source('R/build_usage_pictogram.R')
width=7.5
height=7.1
plot_dir = '../public_html/img'
svg_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))
simp_tol <- 7000
grey_simp_tol <- 1.3*simp_tol # less res for non-highlighted states
min_area <- 1e+10
epsg_code <- '+init=epsg:3479' #5070 for USGS CONUS albers?

ylim <- c(-1806051, 2054371) # in epsg_code
xlim <- c(-2693054, 5512372)
lo_co_states <- c("California","Nevada","Arizona")
keep_non <- c("Texas","Utah","Colorado","New Mexico","Oregon","Wyoming","Oklahoma","Nebraska","Kansas")

non_lo_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#C0C0C0', mask="url(#non-lo-co-mask)")
lo_co_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#000000')
mexico_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#000000', mask="url(#mexico-mask)")
co_river_styles = c('fill'='none', 'stroke-width'='3.5', 'stroke'='#0066CC', 'stroke-linejoin'="round")
co_basin_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round")

mexico = readOGR(dsn = "../src_data/mexico",layer="MEX_adm0") %>%
  spTransform(CRS(epsg_code)) %>%
  gSimplify(simp_tol)

states = readOGR(dsn = "../src_data/states_21basic",layer="states") 
rivers = readOGR(dsn = "../src_data/rivs_cbrfc", layer="rivs_cbrfc")
co_river <- rivers[substr(rivers$NAME,1,10) == "COLORADO R", ]

co_basin = readOGR("../src_data/CO_WBD/LowerCO.json", "OGRGeoJSON")

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

svg(filename = svg_file,width=width, height=height)
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
order <- sort(as.character(co_river@data$SEQUENCE_N), index.return = T)$ix
co_river_line <- coordinates(co_river@lines[[order[1]]])[[1]]
for (i in 2:length(co_river@lines)){
  co_river_line <- rbind(co_river_line, coordinates(co_river@lines[[order[i]]])[[1]])
}
line <- Line(co_river_line)
lines <- Lines(list(line), ID='co-river')
co_river_join <- SpatialLines(list(lines), proj4string = CRS('+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0'))


spTransform(co_river_join, CRS(epsg_code)) %>%
  gSimplify(simp_tol) %>%
  plot(add=TRUE)

spTransform(co_basin[1, ], CRS(epsg_code)) %>% # upper only!
  gSimplify(simp_tol) %>%
  plot(add=TRUE)

spTransform(co_basin[2, ], CRS(epsg_code)) %>% # lower only!
  gSimplify(simp_tol) %>%
  plot(add=TRUE)
dev.off()

svg <- xmlParse(svg_file, useInternalNode=TRUE)

svg <- name_svg_elements(svg, ele_names = c(keep_non, 'Mexico', lo_co_states,'Colorado-river','upper-Colorado-river-basin','lower-Colorado-river-basin')) %>%
  group_svg_elements(groups = list('non-lo-co-states' = keep_non, 'mexico' = 'Mexico', 'lo-co-states' = lo_co_states,'co-river-polyline' = 'Colorado-river','co-basin-polygon' = c('upper-Colorado-river-basin','lower-Colorado-river-basin'))) %>%
  group_svg_elements(groups = c(lo_co_states,'Mexico','Colorado-river', 'lower-Colorado-river-basin')) %>% # additional <g/> for each lo-co-state and mexico
  attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles, 'mexico' = mexico_styles, 'lo-co-states' = lo_co_styles, 'co-river-polyline' = co_river_styles, 'co-basin-polygon'=co_basin_styles)) %>%
  add_radial_mask(r=c('250','300'), id = c('non-lo-co-mask','mexico-mask'), cx=c('250','300'),cy=c('200','300')) %>%
  usage_bar_pictogram()

cat(toString.XMLNode(svg), file = svg_file, append = FALSE)
