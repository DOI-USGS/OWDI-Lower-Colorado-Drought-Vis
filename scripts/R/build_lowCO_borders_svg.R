
require(rgdal)
library(rgeos)
library(magrittr)
library(XML)
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/build_usage_pictogram.R')
source('scripts/R/build_ecmascript.R')
width=7.5
height=7.6
plot_dir = 'public_html/img'
svg_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))
simp_tol <- 7000
picto_scale = 100000 # acre-feet per bin
grey_simp_tol <- 1.3*simp_tol # less res for non-highlighted states
min_area <- 1e+10
epsg_code <- '+init=epsg:3479' #5070 for USGS CONUS albers?

ylim <- c(-1806051, 1654371) # in epsg_code
xlim <- c(-3193054, 5512372)
lo_co_states <- c("California","Nevada","Arizona")
keep_non <- c("Texas","Utah","Colorado","New Mexico","Oregon","Wyoming","Oklahoma","Nebraska","Kansas")

non_lo_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#C0C0C0', mask="url(#non-lo-co-mask)")
lo_co_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'stroke-linejoin'='round')
mexico_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#FFFFFF', mask="url(#mexico-mask)", 'stroke-linejoin'='round')
co_river_styles = c('fill'='none', 'stroke-width'='4.5', 'stroke'='#0066CC', 'stroke-linejoin'="round", 
                    'style'="stroke-dasharray:331;stroke-linejoin:round;stroke-dashoffset:331;stroke-linecap:round")
co_basin_styles = c('fill'='#B22C2C', 'fill-opacity'='0.3', 'stroke-width'='2.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round", opacity = '0')
pictogram_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#FFFFFF', opacity = '0')

mexico = readOGR(dsn = "src_data/mexico",layer="MEX_adm0") %>%
  spTransform(CRS(epsg_code)) %>%
  gSimplify(simp_tol)

states = readOGR(dsn = "src_data/states_21basic",layer="states") 
rivers = readOGR(dsn = "src_data/CRB_Rivers", layer="CRB_Rivers")
usage = readOGR("public_html/data/wat_acc_sp.geojson", "OGRGeoJSON")
co_river <- rivers[substr(rivers$Name,1,14) == "Colorado River", ]

co_basin = readOGR("public_html/data/lc_huc_simp.geojson", "OGRGeoJSON")

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


spTransform(co_river_join, CRS(epsg_code)) %>%
  gSimplify(simp_tol) %>%
  plot(add=TRUE)

spTransform(co_basin, CRS(epsg_code)) %>% 
  gSimplify(simp_tol) %>%
  plot(add=TRUE)


dev.off()

svg <- xmlParse(svg_file, useInternalNode=TRUE)

svg <- clean_svg_doc(svg) %>%
  add_ecmascript(ecmascript_mead_map()) %>%
  name_svg_elements(svg, ele_names = c(keep_non, 'Mexico', lo_co_states,'Colorado-river','Colorado-river-basin')) %>%
  group_svg_elements(groups = list('non-lo-co-states' = keep_non, 'mexico' = 'Mexico', 'lo-co-states' = lo_co_states,'co-river-polyline' = 'Colorado-river','co-basin-polygon' = 'Colorado-river-basin')) %>%
  group_svg_elements(groups = c(lo_co_states,'Mexico','Colorado-river','Colorado-river-basin')) %>% # additional <g/> for each lo-co-state and mexico
  attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles, 'mexico' = mexico_styles, 'lo-co-states' = lo_co_styles, 'co-river-polyline' = co_river_styles, 'co-basin-polygon'=co_basin_styles)) %>%
  add_radial_mask(r=c('300','300'), id = c('non-lo-co-mask','mexico-mask'), cx=c('250','300'),cy=c('200','300')) %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'colorado-river-draw', begin="indefinite", fill="freeze", dur="5s", values="331;0;") %>%
  add_animation(attr = 'opacity', parent_id='co-basin-polygon', element = 'g', id = 'colorado-basin-draw', begin="indefinite", fill="freeze", dur="1s", values= "0;1") %>%
  usage_bar_pictogram(values = sort(as.numeric(as.character(usage$LastFiveMean)),decreasing = T), scale=picto_scale, group_name = 'pictogram-topfive', group_style = pictogram_styles) %>%
  add_animation(attr = 'opacity', parent_id='pictogram-topfive', element = 'g', id = 'pictogram-topfive-draw', begin="indefinite", fill="freeze", dur="1s", values= "0;1") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-1", element = 'g', id = 'pictogram-1-draw', begin="indefinite", fill="freeze", dur="1s", values= "1;0;1") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-2", element = 'g', id = 'pictogram-2-draw', begin="indefinite", fill="freeze", dur="1s", values= "1;0;1") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-3", element = 'g', id = 'pictogram-3-draw', begin="indefinite", fill="freeze", dur="1s", values= "1;0;1") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-4", element = 'g', id = 'pictogram-4-draw', begin="indefinite", fill="freeze", dur="1s", values= "1;0;1") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-5", element = 'g', id = 'pictogram-5-draw', begin="indefinite", fill="freeze", dur="1s", values= "1;0;1") %>%
  add_animation(attr = 'opacity', parent_id='non-lo-co-states', id = 'remove-grey-states', element='g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  add_animation(attr = 'opacity', parent_id='pictogram-topfive', id = 'remove-pictogram', element = 'g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  add_animation(attr = 'opacity', parent_id='co-river-polyline', id = 'remove-river', element = 'g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  add_animation(attr = 'opacity', parent_id='co-basin-polygon', id = 'remove-basin',element = 'g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  add_animateTransform(parent_id = 'California', id = 'California-move', begin="indefinite", type = 'translate', fill="freeze", from="0 0", to="-10 -20", dur="1s") %>%
  add_animateTransform(parent_id = 'Nevada', id = 'Nevada-move', begin="indefinite", type = 'translate', fill="freeze", from="0 0", to="7 -32", dur="1s") %>%
  add_animateTransform(parent_id = 'Arizona', id = 'Arizona-move', begin="indefinite", type = 'translate', fill="freeze", from="0 0", to="22 -17", dur="1s") %>%
  add_animateTransform(parent_id = 'mexico', id = 'mexico-move',begin="indefinite", element = 'g', type = 'translate', fill="freeze", from="0 0", to="0 95", dur="1s") %>%
  add_animation(attr = 'stroke-width', parent_id="Mexico", id = 'Mexico-stroke', begin="indefinite", fill="freeze", dur="1s", values= "2.5;4.55") %>% # original stroke / new scale
  add_animateTransform(parent_id = 'Mexico', id = 'Mexico-scale', begin="indefinite", type = 'scale', fill="freeze", from = '1', to="0.55", dur="1s") %>%
  toString.XMLNode() %>%
  cat(file = svg_file, append = FALSE)
