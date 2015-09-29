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
co_river_styles = c('style'="stroke-dasharray:341;stroke-dashoffset:341;stroke-linejoin:round;stroke-linecap:round;")
co_basin_styles = c('fill'='#B22C2C', 'fill-opacity'='0.3', 'stroke-width'='2.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round", class='hidden')
pictogram_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'class'='hidden')
mead_water_styles = c(fill='#1975d1',stroke='none')
mead_border_styles = c(fill='none','stroke-width'="2.5",'stroke'='#FFFFFF','stroke-linejoin'='round','stroke-linecap'="round")
mexico_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#C0C0C0', 'fill-opacity'='0.35')


contracts = readOGR("public_html/data/wat_acc_cont.geojson", "OGRGeoJSON", stringsAsFactors = F)
sorted_contracts <- sort(as.numeric(contracts$FiveYrAvg_),decreasing = T, index.return = T)
non_zero_cont <- as.numeric(contracts$FiveYrAvg_[sorted_contracts$ix])
non_zero_cont <- non_zero_cont[non_zero_cont > 15000]

picto_scale = 100000 # acre-feet per bin
mead_poly <- c(x1=545,y1=20,x2=545,y2=450,x3=410,y3=450,x4=290,y4= 20)
mead_yvals <- get_mead_yval(mead_poly, storage = c(26.2, 23.1, 16.2, 9.6, 7.7, 6.0)) # flood, surplus, normal, shortage 1,2,3
mead_names <- c(group_id='Mead-2D', water_id='Mead-water-level', border_id='Mead-2D-border')
ani_dur <- c('mead-draw'="2s", 'mead-remove'='1s','stage-move'='1s',
             'river-draw'='5s','river-reset'='1s','basin-draw'='1s')

contract_values <- prettyNum(round(as.numeric(contracts[sorted_contracts$ix,]$FiveYrAvg_)),big.mark=",",scientific=FALSE)
contract_titles <- gsub("\\b([a-z])([a-z]+)", "\\U\\1\\L\\2" ,tolower(contracts[sorted_contracts$ix,]$Contractor), perl=TRUE)
svg <- xmlParse(svg_file, useInternalNode=TRUE)
#stripping apostrophes from contract names which were causing problems
contract_titles <- gsub("'", "\\\\'", contract_titles)

svg <- add_background_defs(svg, id = 'background-image',image_url = 'mead-background.jpg') %>%
  add_flag_defs(id = 'usa-flag', x=0,y=-100, width=500,height=500, image_url='https://upload.wikimedia.org/wikipedia/en/a/a4/Flag_of_the_United_States.svg') %>% 
  add_flag_defs(id = 'mexico-flag', x=120,y=150, width=650,height=547, image_url='https://upload.wikimedia.org/wikipedia/commons/f/fc/Flag_of_Mexico.svg') %>% 
  edit_attr_svg(c('viewBox'='-50 0 640 547', 'onload'='init(evt)')) %>% 
  add_rect(x="-50", width="100%", height="100%", style="max-width=950px", fill="url(#background-image)", at=0, rx='6',ry='6', id='background-panel') %>%
  add_scene_buttons() %>% 
  add_picto_legend() %>% 
  remove_svg_elements(elements = c('delete_group'='g')) %>% 
  add_ecmascript(ecmascript_mead_map()) %>%
  attr_svg_groups(attrs = list('co-river-polyline' = co_river_styles, 'co-basin-polygon'=co_basin_styles, 'mexico' = mexico_styles, "top-users"=c('class'='hidden'))) %>%
  attr_svg_paths(attrs = list('California'=c("class"="california"), 'Nevada'=c("class"="nevada"), 'Arizona'=c("class"="arizona"),'Mexico'=c("class"="mexico"))) %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'draw-colorado-river', begin="indefinite", fill="freeze", dur=ani_dur[['river-draw']], values="331;0;") %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'reset-colorado-river', begin="indefinite", fill="freeze", dur=ani_dur[['river-reset']], values="0;331;") %>%
  usage_bar_pictogram(values = non_zero_cont, value_mouse = contract_titles, value_contract = contract_values, 
                      scale=picto_scale, group_name = 'pictogram-topfive', group_style = pictogram_styles) %>%
  add_mead_levels(mead_poly, mead_water_styles, mead_border_styles,mead_names[['group_id']], mead_names[['water_id']],mead_names[['border_id']]) %>%
  build_state_pictos() %>%
  add_sankey_lines() %>% 
  toString.XMLNode()

lines <- strsplit(svg,'[\n]')[[1]]
cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = out_file, append = FALSE)
