require(rgdal)
library(rgeos)
library(magrittr)
library(XML)
source('scripts/R/manipulate_lowCO_borders_svg.R')

bboxes <- list(
  hoover=c(-114.7476482391,36.0050206578,-114.715719223,36.0300823705),
  davis=c(-114.5924663544,35.1912759619,-114.5559883118,35.2145603133),
  needles=c(-114.6471405029,34.7026709419,-114.4397735596,34.8707217822),
  parker=c(-114.1537857056,34.2885663807,-114.1179084778,34.3203299518),
  headgate=c(-114.2993545532,34.1550708939,-114.2504310608,34.1816307029),
  paloVerde=c(-114.5362472534,33.7134167623,-114.4813156128,33.7433978631),
  outfall=c(-114.7362327576,33.2930861252,-114.6546936035,33.3706781613),
  imperial=c(-114.4976234436,32.8710811177,-114.4457817078,32.9196555668),
  eastern=c(-113.9206695557,32.6625003547,-113.4420776367,32.9625864419),
  morelos=c(-114.9540710449,32.6000478333,-113.8375854492,32.803436167),
  salton=c(-115.749206543,32.6671247331,-114.9087524414,33.4108095511)
)

width=7.5
height=7.6
plot_dir = 'src_data/lower-co-map'
svg_file = file.path(plot_dir,paste0('bluedragon-inset','.svg'))
simp_tol <- 7000
grey_simp_tol <- 1.3*simp_tol # less res for non-highlighted states
min_area <- 1e+10
wgs84 <- '+init=epsg:4326'
epsg_code <- '+init=epsg:3479' #5070 for USGS CONUS albers?

ylim <- c(-1806051, 1654371) # in epsg_code
xlim <- c(-3193054, 5512372)

lo_co_states <- c("California","Nevada","Arizona","Texas","Utah","Colorado","New Mexico","Oregon","Wyoming","Oklahoma","Nebraska","Kansas")

non_lo_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#C0C0C0', mask="url(#non-lo-co-mask)")
lo_co_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'stroke-linejoin'='round')
mexico_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'stroke-linejoin'='round')

co_river_styles = c('fill'='none', 'stroke-width'='4.5', 'stroke'='#0066CC', 'stroke-linejoin'="round", 
                    'style'="stroke-linejoin:round;stroke-linecap:round")
co_basin_styles = c('fill'='#B22C2C', 'fill-opacity'='0.3', 'stroke-width'='2.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round", opacity = '1')
top_user_styles = c('fill'='#E6E600', 'fill-opacity'='0.75', 'stroke-width'='2.5', 'stroke'='#E6E600', 'stroke-linejoin'="round")


mexico = readOGR(dsn = "src_data/mexico",layer="MEX_adm0") %>%
  spTransform(CRS(epsg_code)) %>%
  gSimplify(simp_tol)

states = readOGR(dsn = "src_data/states_21basic",layer="states") 
rivers = readOGR(dsn = "src_data/CRB_Rivers", layer="CRB_Rivers")

co_river <- rivers[substr(rivers$Name,1,14) == "Colorado River", ]

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

plot(mex_simp, ylim = ylim, xlim = xlim)

for (state in lo_co_states){
  state_border <- spTransform(states[states$STATE_NAME == state, ], CRS(epsg_code)) %>%
    gSimplify(simp_tol)
  plot(state_border, add=TRUE)
}

order <- sort(as.character(co_river@data$OBJECTID), index.return = T)$ix
co_river_line <- coordinates(co_river@lines[[order[1]]])[[1]]
for (i in 2:length(co_river@lines)){
  co_river_line <- rbind(co_river_line, coordinates(co_river@lines[[order[i]]])[[1]])
}
line <- Line(co_river_line)
lines <- Lines(list(line), ID='co-river')
co_river_join <- SpatialLines(list(lines), proj4string = CRS('+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0'))

spTransform(co_river_join, CRS(epsg_code)) %>%
  gSimplify(simp_tol) %>%
  plot(add=TRUE)

for (i in 1:length(bboxes)) {
  x <- bboxes[[i]]
  bbox = Polygons(list(Polygon(cbind(c(x[1],x[1],x[3],x[3],x[1]), c(x[2],x[4],x[4],x[2],x[2])))),"bbox")
  spBbox = SpatialPolygons(list(bbox), proj4string = CRS(wgs84))
  spBbox = spTransform(spBbox, CRS(epsg_code))
  plot(spBbox, add=TRUE) 
}

dev.off()

svg <- xmlParse(svg_file, useInternalNode=TRUE)

svg <- clean_svg_doc(svg) %>%
  add_rect(width="540", height="547", fill='grey', opacity='0.2', stroke='black', 'stroke-width'='2') %>%
  name_svg_elements(svg, ele_names = c(keep_non, 'Mexico', lo_co_states,'Colorado-river-basin','Colorado-river',top_users)) %>%
  group_svg_elements(groups = list('non-lo-co-states' = keep_non, 'mexico' = 'Mexico', 'lo-co-states' = lo_co_states,'co-basin-polygon' = 'Colorado-river-basin', 'co-river-polyline' = 'Colorado-river','top-users' = top_users)) %>%
  group_svg_elements(groups = c(lo_co_states,'Mexico','Colorado-river','Colorado-river-basin')) %>% # additional <g/> for each lo-co-state and mexico
  attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles, 'mexico' = mexico_styles, 'lo-co-states' = lo_co_styles, 'co-river-polyline' = co_river_styles, 'co-basin-polygon'=co_basin_styles, 'top-users'=top_user_styles)) %>%
  attr_svg_paths(attrs = list('usage-1'=c(opacity = '0'), 'usage-2'=c(opacity = '0'), 'usage-3'=c(opacity = '0'), 'usage-4'=c(opacity = '0'), 'usage-5'=c(opacity = '0'))) %>%
  add_radial_mask(r=c('300','300'), id = c('non-lo-co-mask','mexico-mask'), cx=c('250','300'),cy=c('200','300')) %>%
  toString.XMLNode()

cat(svg, file = svg_file, append = FALSE)
