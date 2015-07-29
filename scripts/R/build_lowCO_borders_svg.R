require(rgdal)
library(rgeos)
library(magrittr)
library(XML)
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/create_contract_areas.R')

width=7.5
height=7.6
plot_dir = 'src_data/lower-co-map'
svg_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))
simp_tol <- 7000
grey_simp_tol <- 1.3*simp_tol # less res for non-highlighted states
min_area <- 1e+10
epsg_code <- '+init=epsg:3479' #5070 for USGS CONUS albers?

ylim <- c(-1806051, 1654371) # in epsg_code
xlim <- c(-3193054, 5512372)
n.users = 20
top_users <- paste0('usage-',c(1:n.users))
lo_co_states <- c("California","Nevada","Arizona")
keep_non <- c("Texas","Utah","Colorado","New Mexico","Oregon","Wyoming","Oklahoma","Nebraska","Kansas")

non_lo_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#C0C0C0', mask="url(#non-lo-co-mask)")
lo_co_styles = c('fill'='#d3d3d3', 'fill-opacity'='0.35', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'stroke-linejoin'='round')
mexico_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'stroke-linejoin'='round')

user_styles = c('opacity'='0')
co_river_styles = c('fill'='none', 'stroke-width'='4.5', 'stroke'='#1975d1', 'stroke-linejoin'="round", 
                    'style'="stroke-linejoin:round;stroke-linecap:round")
co_basin_styles = c('fill'='#B22C2C', 'fill-opacity'='0.3', 'stroke-width'='2.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round")
top_user_styles = c('fill'='#E6E600', 'fill-opacity'='0.75', 'stroke-width'='2.5', 'stroke'='#E6E600', 'stroke-linejoin'="round")


mexico = readOGR(dsn = "src_data/mexico",layer="MEX_adm0") %>%
  spTransform(CRS(epsg_code)) %>%
  gSimplify(simp_tol)

states = readOGR(dsn = "src_data/states_21basic",layer="states") 
rivers = readOGR(dsn = "src_data/CRB_Rivers", layer="CRB_Rivers")
#mx.rivers = readOGR(dsn = "src_data/CRB_Rivers", layer="Colorado_Mexico")
contracts = readOGR("public_html/data/wat_acc_cont.geojson", "OGRGeoJSON", stringsAsFactors = F)

 
sorted_contracts <- sort(as.numeric(contracts$mean),decreasing = T, index.return = T)
co_river <- rivers[substr(rivers$Name,1,14) == "Colorado River", ]

co_basin = readOGR(dsn = "src_data/CO_WBD", layer="WBDHU2_14-15-clean")

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
order <- sort(as.character(co_river@data$OBJECTID), index.return = T)$ix
co_river_line <- coordinates(co_river@lines[[order[1]]])[[1]]
for (i in 2:length(co_river@lines)){
  co_river_line <- rbind(co_river_line, coordinates(co_river@lines[[order[i]]])[[1]])
}
line <- Line(co_river_line)
lines <- Lines(list(line), ID='co-river')
co_river_join <- SpatialLines(list(lines), proj4string = CRS('+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0'))

spTransform(co_basin, CRS(epsg_code)) %>% 
  gSimplify(simp_tol) %>%
  plot(add=TRUE)


spTransform(co_river_join, CRS(epsg_code)) %>%
  gSimplify(simp_tol) %>%
  plot(add=TRUE)


for (i in 1:n.users){
  area <- suppressWarnings(gArea(contracts[sorted_contracts$ix[i],])) # suppressing proj warning
  if (area < 0.01)
    tol = 50
  else
    tol = 100
  spTransform(contracts[sorted_contracts$ix[i],], CRS(epsg_code)) %>%
    gSimplify(tol) %>%
    plot(add=TRUE)
}


dev.off()
user_att <- vector('list',n.users) %>% 
  lapply(function(x)x=c('opacity'='0')) %>% 
  setNames(paste0('usage-',1:n.users))

svg <- xmlParse(svg_file, useInternalNode=TRUE)

svg <- clean_svg_doc(svg) %>%
  name_svg_elements(svg, ele_names = c(keep_non, 'Mexico', lo_co_states,'Lower-Colorado-river-basin','Upper-Colorado-river-basin','Colorado-river',top_users)) %>%
  group_svg_elements(groups = list('non-lo-co-states' = keep_non, 'mexico' = 'Mexico', 'lo-co-states' = lo_co_states,'co-basin-polygon' = c('Upper-Colorado-river-basin','Lower-Colorado-river-basin'), 'co-river-polyline' = 'Colorado-river','top-users' = top_users)) %>%
  group_svg_elements(groups = c(lo_co_states,'Mexico','Colorado-river','Upper-Colorado-river-basin','Lower-Colorado-river-basin')) %>% # additional <g/> for each lo-co-state and mexico
  attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles, 'mexico' = mexico_styles, 'lo-co-states' = lo_co_styles, 'co-river-polyline' = co_river_styles, 'co-basin-polygon'=co_basin_styles, 'top-users'=top_user_styles)) %>%
  attr_svg_paths(attrs = user_att) %>% 
  add_radial_mask(r=c('300','300'), id = c('non-lo-co-mask','mexico-mask'), cx=c('250','300'),cy=c('200','300')) %>%
  toString.XMLNode()

cat(svg, file = svg_file, append = FALSE)
