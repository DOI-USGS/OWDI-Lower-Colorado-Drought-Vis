library(magrittr)
library(XML)
require(rgdal)
library(rgeos)
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/build_usage_pictogram.R')
source('scripts/R/build_state_pictogram.R')
source('scripts/R/build_ecmascript.R')
source('scripts/R/build_mead_levels.R')


declaration <- '<?xml-stylesheet type="text/css" href="../../css/svg.css" ?>'

plot_dir = 'public_html/img/lake-mead-animated'
read_dir = 'src_data/lower-co-map'
svg_file = file.path(read_dir,paste0('lo_CO_borders','.svg'))
out_file = file.path(plot_dir,paste0('mead_scene_animated','.svg'))
co_river_styles = c('style'="stroke-dasharray:331;stroke-dashoffset:331;stroke-linejoin:round;stroke-linecap:round;")
co_basin_styles = c('fill'='#B22C2C', 'fill-opacity'='0.3', 'stroke-width'='2.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round", opacity = '0')
pictogram_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#FFFFFF', opacity = '0')
mead_water_styles = c(fill='#0066CC',stroke='none','clip-path'="url(#Mead-clip)")
mead_border_styles = c(fill='none','stroke-width'="2.5",stroke='#FFFFFF','stroke-linejoin'='round','stroke-linecap'="round")

contracts = readOGR("public_html/data/wat_acc_cont.geojson", "OGRGeoJSON", stringsAsFactors = F)
sorted_contracts <- sort(as.numeric(contracts$mean),decreasing = T, index.return = T)
non_zero_cont <- as.numeric(contracts$mean[sorted_contracts$ix])
non_zero_cont <- non_zero_cont[non_zero_cont!=0]

picto_scale = 100000 # acre-feet per bin
mead_poly <- c(x1=535,y1=20,x2=535,y2=450,x3=400,y3=450,x4=280,y4= 20)
mead_yvals <- get_mead_yval(mead_poly, storage = c(26.2, 23.1, 16.2, 9.6, 7.7, 6.0)) # flood, surplus, normal, shortage 1,2,3
mead_names <- c(group_id='Mead-2D', water_id='Mead-water-level', border_id='Mead-2D-border')
ani_dur <- c('mead-draw'="2s", 'mead-remove'='1s','stage-move'='1s',
             'river-draw'='5s','river-reset'='1s','basin-draw'='1s')


svg <- xmlParse(svg_file, useInternalNode=TRUE)

svg <- add_ecmascript(svg, ecmascript_mead_map()) %>%
  attr_svg_groups(attrs = list('co-river-polyline' = co_river_styles, 'co-basin-polygon'=co_basin_styles)) %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'colorado-river-draw', begin="indefinite", fill="freeze", dur=ani_dur[['river-draw']], values="331;0;") %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'colorado-river-reset', begin="indefinite", fill="freeze", dur=ani_dur[['river-reset']], values="0;331;") %>%
  add_animation(attr = 'opacity', parent_id='co-basin-polygon', element = 'g', id = 'colorado-basin-draw', begin="indefinite", fill="freeze", dur=ani_dur[['basin-draw']], values= "0;1") %>%
  usage_bar_pictogram(values = non_zero_cont, value_mouse = contracts[sorted_contracts$ix,]$Contractor, value_contract = contracts[sorted_contracts$ix,]$mean, 
                      scale=picto_scale, group_name = 'pictogram-topfive', group_style = pictogram_styles) %>%
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
  add_animation(attr = 'opacity', parent_id="Mexico-pictos", id = 'draw-mexico-pictogram', element='g', begin="indefinite", fill="freeze", dur="2s", values= "0;0;1", keyTimes="0;0.75;1") %>%
  add_animation(attr = 'opacity', parent_id="California-pictos", id = 'draw-california-pictogram', element='g', begin="indefinite", fill="freeze", dur="2s", values= "0;0;1", keyTimes="0;0.75;1") %>%
  add_animation(attr = 'opacity', parent_id="Arizona-pictos", id = 'draw-arizona-pictogram', element='g', begin="indefinite", fill="freeze", dur="2s", values= "0;0;1", keyTimes="0;0.75;1") %>%
  add_animation(attr = 'opacity', parent_id="Nevada-pictos", id = 'draw-nevada-pictogram', element='g', begin="indefinite", fill="freeze", dur="2s", values= "0;0;1", keyTimes="0;0.75;1") %>%
  add_animation(attr = 'opacity', parent_id="Mexico-pictos", id = 'remove-mexico-pictogram', element='g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  add_animation(attr = 'opacity', parent_id="California-pictos", id = 'remove-california-pictogram', element='g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  add_animation(attr = 'opacity', parent_id="Arizona-pictos", id = 'remove-arizona-pictogram', element='g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  add_animation(attr = 'opacity', parent_id="Nevada-pictos", id = 'remove-nevada-pictogram', element='g', begin="indefinite", fill="freeze", dur="1s", values= "1;0") %>%
  toString.XMLNode()

lines <- strsplit(svg,'[\n]')[[1]]
cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = out_file, append = FALSE)
