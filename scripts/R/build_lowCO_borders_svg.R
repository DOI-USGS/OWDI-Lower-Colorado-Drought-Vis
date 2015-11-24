require(rgdal)
library(rgeos)
library(magrittr)
library(XML)
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/create_contract_areas.R')

width=11
height=9.6
plot_dir = 'src_data/lower-co-map'
svg_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))
min.contract = 15000
simp_tol <- 7000
grey_simp_tol <- 1.3*simp_tol # less res for non-highlighted states
min_area <- 1e+10
epsg_code <- '+init=epsg:3479' #5070 for USGS CONUS albers?

ylim <- c(-2806051, 1254371) # in epsg_code
xlim <- c(-2893054, 9512372)

lo_co_states <- c("California","Nevada","Arizona")
keep_non <- c("Texas","Utah","Colorado","New Mexico","Oregon","Wyoming","Oklahoma","Nebraska","Kansas")

non_lo_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#C0C0C0', mask="url(#non-lo-co-mask)")
lo_co_styles = c('fill'='#d3d3d3', 'fill-opacity'='0.35', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'stroke-linejoin'='round')
mexico_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'stroke-linejoin'='round')
mexico_bdr_styles = c('fill'='none', 'stroke-width'='4.5', 'stroke'='#FFFFFF','stroke-linejoin'='round')

user_styles = c('opacity'='0')
co_river_styles = c('fill'='none', 'stroke-width'='4.5', 'stroke'='#1975d1', 'stroke-linejoin'="round", 
                    'style'="stroke-linejoin:round;stroke-linecap:round")
co_basin_styles = c('fill'='#B22C2C', 'fill-opacity'='0.3', 'stroke-width'='2.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round")
top_user_styles = c('fill'='#00CC99', 'fill-opacity'='0.75', 'stroke-width'='2.5', 'stroke'='#00CC99', 'stroke-linejoin'="round")


mexico = readOGR(dsn = "src_data/mexico",layer="mexstates") %>%
  spTransform(CRS(epsg_code)) %>%
  gSimplify(simp_tol)

mexico_bdr <- readOGR(dsn = "src_data/mexico_outline",layer="mex_outline") %>%
  spTransform(CRS(epsg_code)) %>%
  gSimplify(simp_tol)

states = readOGR(dsn = "src_data/states_21basic",layer="states") 
rivers = readOGR(dsn = "src_data/CRB_Rivers", layer="CRB_Rivers")
contracts = readOGR("public_html/data/wat_acc_cont.geojson", "OGRGeoJSON", stringsAsFactors = F)
co_basin = readOGR(dsn = "src_data/CO_WBD", layer="LC_UC_Basin_2015")
writeOGR(co_basin, dsn = "public_html/data/wbd1415.geojson", driver = "GeoJSON", layer="OGRGeoJSON", overwrite_layer=TRUE)

sorted_contracts <- sort(as.numeric(contracts$FiveYrAvg_),decreasing = T, index.return = T)
sorted_values <- sorted_contracts$x[sorted_contracts$x > min.contract]
sorted_contract_i <- sorted_contracts$ix[sorted_contracts$x > min.contract]
n.users = length(sorted_contract_i)
top_users <- paste0('usage-',c(1:n.users))

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
plot(mexico_bdr, add=TRUE)

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
  
  spTransform(contracts[sorted_contract_i[i],], CRS(epsg_code)) %>%
    plot(add=TRUE)
  
  
}
dev.off()
user_att <- vector('list',n.users) %>% 
  lapply(function(x)x=c('opacity'='0')) %>% 
  setNames(paste0('usage-',1:n.users))

border_line = c(d="M 146.738281 265.828125 L 146.84375 264.300781 L 190.777344 262.011719 L 189.265625 266.664062 L 257.804688 292.414062 L 310.195312 291.324219 L 309.863281 281.632812 L 339.296875 280.402344 L 342.859375 280.863281 L 344.445312 282.222656 L 346.980469 286.742188 L 351.480469 288.71875 L 355.429688 292.640625 L 358.734375 294.546875 L 362.847656 298.976562 L 367.121094 300.609375 L 372.492188 304.875 L 374.125 308.675781 L 377.019531 312.796875 L 377.4375 318.113281 L 380.371094 323.734375 L 382.828125 325.820312 L 386.539062 327.203125 L 390.238281 330.503906 L 393.257812 331.273438 L 404.953125 336.707031 L 407.496094 336.808594 L 411.136719 332.203125 L 415.570312 319.667969 L 418.789062 318.558594 L 422.265625 315.949219 L 426.753906 317.527344 L 439.425781 316.949219 L 441.523438 320.199219 L 445.035156 322.601562 L 446.917969 323.0625 L 452.039062 327.011719 L 454.824219 330.023438 L 455.738281 333.234375 L 461.941406 342.285156 L 463.9375 347.308594 L 465.945312 348.933594 L 468.117188 349.640625 L 472.472656 354.738281 L 473.679688 357.464844 L 476.582031 359.753906 L 478.363281 359.917969 L 480.511719 361.3125 L 482.375 367.945312 L 482.539062 372.574219 L 485.652344 376.160156 L 487.027344 376.878906 L 490.8125 385.214844 L 504.371094 388.484375 L 507.292969 390.695312 L 509.480469 391.492188 L 512.296875 391.710938 L 516.441406 390.710938 L 520.46875 391.023438 L 525.5 394.585938 L 526.546875 394.546875 L 527.328125 392.675781 L 530.671875 391.261719 ")
mexico_names = paste0("Mexico-",1:32)
svg <- xmlParse(svg_file, useInternalNode=TRUE)

svg <- clean_svg_doc(svg) %>%
  name_svg_elements(svg, ele_names = c(keep_non, mexico_names, 'mexico-border',lo_co_states,'Lower-Colorado-river-basin','Upper-Colorado-river-basin','Colorado-river',top_users)) %>% 
  group_svg_elements(groups = list('non-lo-co-states' = keep_non, 'Mexico' = mexico_names,'Mexico-border'='mexico-border', 'lo-co-states' = lo_co_states,'co-basin-polygon' = c('Upper-Colorado-river-basin','Lower-Colorado-river-basin'), 'co-river-polyline' = 'Colorado-river','top-users' = top_users)) %>% 
  group_svg_elements(groups = c(lo_co_states,'Colorado-river',mexico_names,'Upper-Colorado-river-basin','Lower-Colorado-river-basin')) %>% # additional <g/> for each lo-co-state and mexico
  group_svg_group(groups = list('mexico'='Mexico')) %>% 
  attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles, 'mexico' = mexico_styles, 'Mexico-border'=mexico_bdr_styles,'lo-co-states' = lo_co_styles, 'co-basin-polygon'=co_basin_styles, 'top-users'=top_user_styles, 'co-river-polyline' = co_river_styles)) %>%
  attr_svg_paths(attrs = user_att) %>% 
  attr_svg_paths(attrs = list('mexico-border'=border_line)) %>% 
  group_svg_group(groups = list('total-g' = c('non-lo-co-states',"mexico", 'Mexico-border',"lo-co-states", 'co-basin-polygon', "co-river-polyline", "top-users"))) %>% 
  attr_svg_groups(attrs = list('total-g'=c(transform="translate(10,-20),scale(0.97)"))) %>% 
  add_radial_mask(r=c('300','300'), id = c('non-lo-co-mask','mexico-mask'), cx=c('250','300'),cy=c('200','300')) %>%
  edit_attr_svg(c('viewBox'='0 0 540 547')) %>% 
  toString.XMLNode()

cat(svg, file = svg_file, append = FALSE)