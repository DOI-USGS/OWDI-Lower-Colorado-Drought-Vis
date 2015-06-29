
require(rgdal)
library(rgeos)
library(magrittr)
library(XML)
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/build_usage_pictogram.R')
source('scripts/R/build_state_pictogram.R')
source('scripts/R/build_ecmascript.R')
source('scripts/R/build_css.R')
source('scripts/R/build_mead_levels.R')
width=7.5
height=7.6
plot_dir = 'public_html/img'
svg_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))
simp_tol <- 7000
picto_scale = 100000 # acre-feet per bin
grey_simp_tol <- 1.3*simp_tol # less res for non-highlighted states
min_area <- 1e+10
epsg_code <- '+init=epsg:3479' #5070 for USGS CONUS albers?
declaration <- '<?xml-stylesheet type="text/css" href="../css/main.css" ?>'
mead_poly <- c(x1=535,y1=20,x2=535,y2=450,x3=400,y3=450,x4=280,y4= 20)
mead_yvals <- get_mead_yval(mead_poly, storage = c(26.2, 23.1, 16.2, 9.6, 7.7, 6.0)) # flood, surplus, normal, shortage 1,2,3

ani_dur <- c('mead-draw'="2s", 'mead-remove'='1s','stage-move'='1s',
             'river-draw'='5s','river-reset'='1s','basin-draw'='1s')

ylim <- c(-1806051, 1654371) # in epsg_code
xlim <- c(-3193054, 5512372)
top_users <- paste0('usage-',c(1:5))
lo_co_states <- c("California","Nevada","Arizona")
keep_non <- c("Texas","Utah","Colorado","New Mexico","Oregon","Wyoming","Oklahoma","Nebraska","Kansas")

non_lo_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#C0C0C0', mask="url(#non-lo-co-mask)")
lo_co_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'stroke-linejoin'='round')
mexico_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#FFFFFF', mask="url(#mexico-mask)", 'stroke-linejoin'='round')
mead_water_styles = c(fill='#0066CC',stroke='none','clip-path'="url(#Mead-clip)")
mead_border_styles = c(fill='none','stroke-width'="2.5",stroke='#FFFFFF','stroke-linejoin'='round','stroke-linecap'="round")
mead_names <- c(group_id='Mead-2D', water_id='Mead-water-level', border_id='Mead-2D-border')
co_river_styles = c('fill'='none', 'stroke-width'='4.5', 'stroke'='#0066CC', 'stroke-linejoin'="round", 
                    'style'="stroke-dasharray:331;stroke-linejoin:round;stroke-dashoffset:331;stroke-linecap:round")
co_basin_styles = c('fill'='#B22C2C', 'fill-opacity'='0.3', 'stroke-width'='2.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round", opacity = '0')
top_user_styles = c('fill'='#E6E600', 'fill-opacity'='0.75', 'stroke-width'='2.5', 'stroke'='#E6E600', 'stroke-linejoin'="round")
pictogram_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#FFFFFF', opacity = '0')

mexico = readOGR(dsn = "src_data/mexico",layer="MEX_adm0") %>%
  spTransform(CRS(epsg_code)) %>%
  gSimplify(simp_tol)

states = readOGR(dsn = "src_data/states_21basic",layer="states") 
rivers = readOGR(dsn = "src_data/CRB_Rivers", layer="CRB_Rivers")
usage = readOGR("public_html/data/wat_acc_sp.geojson", "OGRGeoJSON")
contracts = readOGR("src_data/LCContractSvcAreas", layer = 'LC_Contacts_update2014')
 
sorted_contracts <- sort(contracts$CU,decreasing = T, index.return = T)
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

for (i in 1:5){
  cont <- spTransform(contracts[sorted_contracts$ix[i],], CRS(epsg_code))
  if (i != 4){
    cont <- gSimplify(cont, simp_tol)
  }
  plot(cont, add=TRUE)
}

non_zero_cont <- contracts$CU[sorted_contracts$ix]
non_zero_cont <- non_zero_cont[non_zero_cont!=0]
dev.off()

svg <- xmlParse(svg_file, useInternalNode=TRUE)

svg <- clean_svg_doc(svg) %>%
  add_rect(width="540", height="547", fill='grey', opacity='0.2', stroke='black', 'stroke-width'='2') %>%
  add_css(css_mead_map()) %>% 
  add_ecmascript(ecmascript_mead_map()) %>%
  name_svg_elements(svg, ele_names = c(keep_non, 'Mexico', lo_co_states,'Colorado-river','Colorado-river-basin',top_users)) %>%
  group_svg_elements(groups = list('non-lo-co-states' = keep_non, 'mexico' = 'Mexico', 'lo-co-states' = lo_co_states,'co-river-polyline' = 'Colorado-river','co-basin-polygon' = 'Colorado-river-basin', 'top-users' = top_users)) %>%
  group_svg_elements(groups = c(lo_co_states,'Mexico','Colorado-river','Colorado-river-basin')) %>% # additional <g/> for each lo-co-state and mexico
  attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles, 'mexico' = mexico_styles, 'lo-co-states' = lo_co_styles, 'co-river-polyline' = co_river_styles, 'co-basin-polygon'=co_basin_styles, 'top-users'=top_user_styles)) %>%
  attr_svg_paths(attrs = list('usage-1'=c(opacity = '0'), 'usage-2'=c(opacity = '0'), 'usage-3'=c(opacity = '0'), 'usage-4'=c(opacity = '0'), 'usage-5'=c(opacity = '0'))) %>%
  add_radial_mask(r=c('300','300'), id = c('non-lo-co-mask','mexico-mask'), cx=c('250','300'),cy=c('200','300')) %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'colorado-river-draw', begin="indefinite", fill="freeze", dur=ani_dur[['river-draw']], values="331;0;") %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'colorado-river-reset', begin="indefinite", fill="freeze", dur=ani_dur[['river-reset']], values="0;331;") %>%
  add_animation(attr = 'opacity', parent_id='co-basin-polygon', element = 'g', id = 'colorado-basin-draw', begin="indefinite", fill="freeze", dur=ani_dur[['basin-draw']], values= "0;1") %>%
  usage_bar_pictogram( values = non_zero_cont, scale=picto_scale, group_name = 'pictogram-topfive', group_style = pictogram_styles) %>%
  add_mead_levels(mead_poly, mead_water_styles, mead_border_styles,mead_names[['group_id']], mead_names[['water_id']],mead_names[['border_id']]) %>%
  add_animation(attr = 'opacity', parent_id=mead_names[['group_id']], element = 'g', id = 'mead-draw', begin="indefinite", fill="freeze", dur=ani_dur[['mead-draw']], values= "0;0;1", keyTimes="0;0.5;1") %>%
  add_animation(attr = 'opacity', parent_id=mead_names[['group_id']], element = 'g', id = 'mead-remove', begin="indefinite", fill="freeze", dur=ani_dur[['mead-remove']], values= "1;0") %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-flood-fall', 
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[1], to=mead_yvals[1]) %>% # does nothing, just here for completeness
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-flood-rise', 
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[2], to=mead_yvals[1]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-surplus-fall', 
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[1], to=mead_yvals[2]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-surplus-rise', 
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[3], to=mead_yvals[2]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-normal-fall', 
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[2], to=mead_yvals[3]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-normal-rise', 
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[4], to=mead_yvals[3]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-shortage-1-fall',
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[3], to=mead_yvals[4]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-shortage-1-rise',
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[5], to=mead_yvals[4]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-shortage-2-fall',
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[4], to=mead_yvals[5]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-shortage-2-rise',
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[6], to=mead_yvals[5]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-shortage-3-fall', 
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[5], to=mead_yvals[6]) %>%
  add_animation(attr = 'y', parent_id=mead_names[['water_id']], element = 'rect', id = 'Mead-shortage-3-rise', 
                begin="indefinite", fill="freeze", dur=ani_dur[['stage-move']], from=mead_yvals[6], to=mead_yvals[6]) %>% # does nothing, but function exists for completeness
  add_animation(attr = 'opacity', parent_id='pictogram-topfive', element = 'g', id = 'pictogram-topfive-draw', begin="indefinite", fill="freeze", dur="1s", values= "0;1") %>%
  add_animation(attr = 'opacity', parent_id='pictogram-topfive', element = 'g', id = 'pictogram-topfive-reset', begin="indefinite", fill="freeze", dur="1s", to= "0") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-1", element = 'g', id = 'pictogram-1-draw', begin="indefinite", fill="freeze", dur="2s", values= "1;0;1;0;1") %>%
  add_animation(attr = 'opacity', parent_id=top_users[1], element = 'path', id = 'user-1-draw', begin="indefinite", fill="freeze", dur="2s", values= "0;1;0") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-2", element = 'g', id = 'pictogram-2-draw', begin="indefinite", fill="freeze", dur="2s", values= "1;0;1;0;1") %>%
  add_animation(attr = 'opacity', parent_id=top_users[2], element = 'path', id = 'user-2-draw', begin="indefinite", fill="freeze", dur="2s", values= "0;1;0") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-3", element = 'g', id = 'pictogram-3-draw', begin="indefinite", fill="freeze", dur="2s", values= "1;0;1;0;1") %>%
  add_animation(attr = 'opacity', parent_id=top_users[3], element = 'path', id = 'user-3-draw', begin="indefinite", fill="freeze", dur="2s", values= "0;1;0") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-4", element = 'g', id = 'pictogram-4-draw', begin="indefinite", fill="freeze", dur="2s", values= "1;0;1;0;1") %>%
  add_animation(attr = 'opacity', parent_id=top_users[4], element = 'path', id = 'user-4-draw', begin="indefinite", fill="freeze", dur="2s", values= "0;1;0") %>%
  add_animation(attr = 'opacity', parent_id="picto-usage-5", element = 'g', id = 'pictogram-5-draw', begin="indefinite", fill="freeze", dur="2s", values= "1;0;1;0;1") %>%
  add_animation(attr = 'opacity', parent_id=top_users[5], element = 'path', id = 'user-5-draw', begin="indefinite", fill="freeze", dur="2s", values= "0;1;0") %>%
  add_animation(attr = 'opacity', parent_id='non-lo-co-states', id = 'remove-grey-states', element='g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  add_animation(attr = 'opacity', parent_id='non-lo-co-states', id = 'reset-grey-states', element='g', begin="indefinite", fill="freeze", dur="1s", values= "0;1") %>%
  add_animation(attr = 'opacity', parent_id='pictogram-topfive', id = 'remove-pictogram', element = 'g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  add_animation(attr = 'opacity', parent_id='co-river-polyline', id = 'remove-river', element = 'g', begin="indefinite", fill="freeze", dur="1s", to= "0") %>%
  add_animation(attr = 'opacity', parent_id='co-river-polyline', id = 'show-river', element = 'g', begin="indefinite", fill="freeze", dur="1s", to= "1") %>%
  add_animation(attr = 'opacity', parent_id='co-basin-polygon', id = 'remove-basin',element = 'g', begin="indefinite", fill="freeze", dur="1s", to="0") %>%
  add_animateTransform(parent_id = 'California', id = 'California-move', begin="indefinite", type = 'translate', fill="freeze", from="0 0",to="-40 -20", dur="1s") %>%
  add_animateTransform(parent_id = 'California', id = 'California-reset', begin="indefinite", type = 'translate', fill="freeze", from="-40 -20",to="0 0", dur="1s") %>%
  add_animateTransform(parent_id = 'Nevada', id = 'Nevada-move', begin="indefinite", type = 'translate', fill="freeze", from="0 0",to="-23 -32", dur="1s") %>%
  add_animateTransform(parent_id = 'Nevada', id = 'Nevada-reset', begin="indefinite", type = 'translate', fill="freeze", from="-23 -32",to="0 0", dur="1s") %>%
  add_animateTransform(parent_id = 'Arizona', id = 'Arizona-move', begin="indefinite", type = 'translate', fill="freeze", from="0 0",to="-8 12", dur="1s") %>%
  add_animateTransform(parent_id = 'Arizona', id = 'Arizona-reset', begin="indefinite", type = 'translate', fill="freeze", from="-8 12",to="0 0", dur="1s") %>%
  add_animateTransform(parent_id = 'mexico', id = 'mexico-move',begin="indefinite", element = 'g', type = 'translate', fill="freeze", from="0 0",to="-70 95", dur="1s") %>%
  add_animateTransform(parent_id = 'mexico', id = 'mexico-reset',begin="indefinite", element = 'g', type = 'translate', fill="freeze", from="-70 95",to="0 0", dur="1s") %>%
  add_animation(attr = 'stroke-width', parent_id="Mexico", id = 'Mexico-stroke', begin="indefinite", fill="freeze", dur="1s", values= "2.5;4.55") %>% # original stroke / new scale
  add_animation(attr = 'stroke-width', parent_id="Mexico", id = 'Mexico-stroke-reset', begin="indefinite", fill="freeze", dur="1s", values= "4.55;2.5") %>% # to original stroke 
  add_animateTransform(parent_id = 'Mexico', id = 'Mexico-scale', begin="indefinite", type = 'scale', fill="freeze", from = '1', to="0.55", dur="1s") %>%
  add_animateTransform(parent_id = 'Mexico', id = 'Mexico-scale-reset', begin="indefinite", type = 'scale', fill="freeze", from="0.55", to="1", dur="1s") %>%
  build_state_pictos() %>%
  toString.XMLNode()

cat(c(svg, declaration), file = svg_file, append = FALSE)
