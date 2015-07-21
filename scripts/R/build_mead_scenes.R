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
co_basin_styles = c('fill'='#B22C2C', 'fill-opacity'='0.3', 'stroke-width'='2.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round")
pictogram_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'class'='hidden')
mead_water_styles = c(fill='#0066CC',stroke='none')
mead_border_styles = c(fill='none','stroke-width'="2.5",stroke='#FFFFFF','stroke-linejoin'='round','stroke-linecap'="round")

contracts = readOGR("public_html/data/wat_acc_cont.geojson", "OGRGeoJSON", stringsAsFactors = F)
sorted_contracts <- sort(as.numeric(contracts$mean),decreasing = T, index.return = T)
non_zero_cont <- as.numeric(contracts$mean[sorted_contracts$ix])
non_zero_cont <- non_zero_cont[1:20]

picto_scale = 100000 # acre-feet per bin
mead_poly <- c(x1=535,y1=20,x2=535,y2=450,x3=400,y3=450,x4=280,y4= 20)
mead_yvals <- get_mead_yval(mead_poly, storage = c(26.2, 23.1, 16.2, 9.6, 7.7, 6.0)) # flood, surplus, normal, shortage 1,2,3
mead_names <- c(group_id='Mead-2D', water_id='Mead-water-level', border_id='Mead-2D-border')
ani_dur <- c('mead-draw'="2s", 'mead-remove'='1s','stage-move'='1s',
             'river-draw'='5s','river-reset'='1s','basin-draw'='1s')


svg <- xmlParse(svg_file, useInternalNode=TRUE)

svg <- add_ecmascript(svg, ecmascript_mead_map()) %>%
  add_rect(x = '450', y='507', width="38", height="30", fill='red', opacity='0.8', stroke='black', 'stroke-width'='0.5', onclick='decrementScene()') %>%
  add_rect(x = '492', y='507', width="38", height="30", fill='blue', opacity='0.8', stroke='black', 'stroke-width'='0.5', onclick='incrementScene()') %>%
  attr_svg_groups(attrs = list('co-river-polyline' = co_river_styles, 'co-basin-polygon'=co_basin_styles)) %>%
  attr_svg_paths(attrs = list('California'=c("class"="california"), 'Nevada'=c("class"="nevada"), 'Arizona'=c("class"="arizona"),'Mexico'=c("class"="mexico"))) %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'draw-colorado-river', begin="indefinite", fill="freeze", dur=ani_dur[['river-draw']], values="331;0;") %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'reset-colorado-river', begin="indefinite", fill="freeze", dur=ani_dur[['river-reset']], values="0;331;") %>%
  usage_bar_pictogram(values = non_zero_cont, value_mouse = contracts[sorted_contracts$ix,]$Contractor, value_contract = contracts[sorted_contracts$ix,]$mean, 
                      scale=picto_scale, group_name = 'pictogram-topfive', group_style = pictogram_styles) %>%
  add_mead_levels(mead_poly, mead_water_styles, mead_border_styles,mead_names[['group_id']], mead_names[['water_id']],mead_names[['border_id']]) %>%
  build_state_pictos() %>%
  toString.XMLNode()

lines <- strsplit(svg,'[\n]')[[1]]
cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = out_file, append = FALSE)
