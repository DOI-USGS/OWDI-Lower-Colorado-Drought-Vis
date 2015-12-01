library(magrittr)
library(XML)
require(rgdal)
library(rgeos)
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/build_usage_pictogram.R')
source('scripts/R/build_state_pictogram.R')
source('scripts/R/build_ecmascript.R')
source('scripts/R/build_mead_levels.R')
source('scripts/R/read_translation.R')
border_line = c(d="M 146.738281 265.828125 L 146.84375 264.300781 L 190.777344 262.011719 L 189.265625 266.664062 L 257.804688 292.414062 L 310.195312 291.324219 L 309.863281 281.632812 L 339.296875 280.402344 L 342.859375 280.863281 L 344.445312 282.222656 L 346.980469 286.742188 L 351.480469 288.71875 L 355.429688 292.640625 L 358.734375 294.546875 L 362.847656 298.976562 L 367.121094 300.609375 L 372.492188 304.875 L 374.125 308.675781 L 377.019531 312.796875 L 377.4375 318.113281 L 380.371094 323.734375 L 382.828125 325.820312 L 386.539062 327.203125 L 390.238281 330.503906 L 393.257812 331.273438 L 404.953125 336.707031 L 407.496094 336.808594 L 411.136719 332.203125 L 415.570312 319.667969 L 418.789062 318.558594 L 422.265625 315.949219 L 426.753906 317.527344 L 439.425781 316.949219 L 441.523438 320.199219 L 445.035156 322.601562 L 446.917969 323.0625 L 452.039062 327.011719 L 454.824219 330.023438 L 455.738281 333.234375 L 461.941406 342.285156 L 463.9375 347.308594 L 465.945312 348.933594 L 468.117188 349.640625 L 472.472656 354.738281 L 473.679688 357.464844 L 476.582031 359.753906 L 478.363281 359.917969 L 480.511719 361.3125 L 482.375 367.945312 L 482.539062 372.574219 L 485.652344 376.160156 L 487.027344 376.878906 L 490.8125 385.214844 L 504.371094 388.484375 L 507.292969 390.695312 L 509.480469 391.492188 L 512.296875 391.710938 L 516.441406 390.710938 L 520.46875 391.023438 L 525.5 394.585938 L 526.546875 394.546875 L 527.328125 392.675781 L 530.671875 391.261719 ")
declaration <- '<?xml-stylesheet type="text/css" href="../../css/svg.css" ?>'

contracts = readOGR("public_html/data/wat_acc_cont.geojson", "OGRGeoJSON", stringsAsFactors = F)
sorted_contracts <- sort(as.numeric(contracts$FiveYrAvg_),decreasing = T, index.return = T)
non_zero_cont <- as.numeric(contracts$FiveYrAvg_[sorted_contracts$ix])
non_zero_cont <- non_zero_cont[non_zero_cont > 15000]

contract_values <- prettyNum(round(as.numeric(contracts[sorted_contracts$ix,]$FiveYrAvg_)),big.mark=",",scientific=FALSE)
contract_titles <- gsub("\\b([a-z])([a-z]+)", "\\U\\1\\L\\2" ,tolower(contracts[sorted_contracts$ix,]$Contractor), perl=TRUE)
contract_titles <- gsub("'", "\\\\'", contract_titles)
#escaping apostrophes so that they don't cause the svg animation to error

# 100,000 acre-feet =~ 123 million m3
picto_scale = ifelse(lang=='en',100000,200000.000000999) # acre-feet per bin, vs million m3 *CONVERT TO ACTUAL!!!*
mead_poly <- c(x1=545,y1=20,x2=545,y2=450,x3=410,y3=450,x4=290,y4= 20)
mead_yvals <- get_mead_yval(mead_poly, storage = c(26.2, 23.1, 16.2, 9.6, 7.7, 6.0)) # flood, surplus, normal, shortage 1,2,3
mead_names <- c(group_id='Mead-2D', water_id='Mead-water-level', border_id='Mead-2D-border')
ani_dur <- c('mead-draw'="2s", 'mead-remove'='1s','stage-move'='1s',
             'river-draw'='5s','river-reset'='1s','basin-draw'='1s')

view.box = c('desktop'='-50 0 640 547', 'mobile'='-65 0 670 547')
x.edge = c('desktop'='-50', 'mobile'='-65')
for (form.factor in c('desktop','mobile')){
  for (lang in c('en','es')){
    
    plot_dir = sprintf('public_html/%s/img',lang)
    read_dir = 'src_data/lower-co-map'
    svg_file = file.path(read_dir,paste0('lo_CO_borders','.svg'))
    out_file = file.path(plot_dir,paste0('mead_scene_animated-',form.factor,'.svg'))
    co_river_styles = c('style'="stroke-dasharray:351;stroke-dashoffset:351;stroke-linejoin:round;stroke-linecap:round;")
    co_basin_styles = c('fill'='#B22C2C', 'fill-opacity'='0.3', 'stroke-width'='2.5', 'stroke'='#B22C2C', 'stroke-linejoin'="round", class='hidden')
    pictogram_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'class'='hidden')
    mead_water_styles = c(fill='#1975d1',stroke='none')
    mead_border_styles = c(fill='none','stroke-width'="2.5",'stroke'='#FFFFFF','stroke-linejoin'='round','stroke-linecap'="round")
    mexico_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#C0C0C0', 'fill-opacity'='0.35')
    
    
    
    svg <- xmlParse(svg_file, useInternalNode=TRUE)
    border.path = c(d = xmlAttrs(xpathApply(svg, "//*[local-name()='path'][@id='mexico-border']")[[1]])[['d']])
    svg <- add_background_defs(svg, id = 'background-image',image_url = 'mead-background.jpg') %>%
      add_flag_defs(id = 'usa-flag', x=-10,y=-80, width=500,height=500, image_url='US_flag.svg') %>% 
      add_flag_defs(id = 'mexico-flag', x=120,y=170, width=650,height=547, image_url='Mexico_flag.svg') %>% 
      edit_attr_svg(c('viewBox'=view.box[[form.factor]], 'onload'='init(evt)')) %>% 
      add_rect(x=x.edge[[form.factor]], width="100%", height="100%", style="max-width=950px", fill="url(#background-image)", at=0, rx='6',ry='6', id='background-panel') %>%
      add_scene_buttons(form.factor) %>% 
      add_picto_legend() %>% 
      attr_svg_paths(attrs = list('mexico-border'=border_line)) %>% 
      remove_svg_elements(elements = c('delete_group'='g')) %>% 
      add_ecmascript(ecmascript_mead_map()) %>%
      attr_svg_groups(attrs = list('co-river-polyline' = co_river_styles, 'co-basin-polygon'=co_basin_styles, 'mexico' = mexico_styles, "top-users"=c('class'='hidden'),"Mexico"=c("class"="mexico"))) %>%
      attr_svg_paths(attrs = list('California'=c("class"="california"), 'Nevada'=c("class"="nevada"), 'Arizona'=c("class"="arizona"))) %>% #,"Mexico"=c("class"="mexico")
      add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'draw-colorado-river', begin="indefinite", fill="freeze", dur=ani_dur[['river-draw']], values="351;0;") %>%
      add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'reset-colorado-river', begin="indefinite", fill="freeze", dur=ani_dur[['river-reset']], values="0;351;") %>%
      usage_bar_pictogram(values = non_zero_cont, value_mouse = contract_titles, value_contract = contract_values, 
                          scale=picto_scale, group_name = 'pictogram-topfive', group_style = pictogram_styles) %>%
      add_mead_levels(mead_poly, mead_water_styles, mead_border_styles,mead_names[['group_id']], mead_names[['water_id']],mead_names[['border_id']]) %>%
      build_state_pictos() %>%
      add_sankey_lines()
    
    if (form.factor == 'mobile'){
      # delete the mexico states, change the border
      delete_groups <- rep('path', 31) %>% 
        setNames(paste0("Mexico-",2:32))
      svg <- attr_svg_paths(svg, attrs = list("Mexico-1"=border.path))
      svg <- remove_svg_elements(svg, elements = delete_groups)
    }
    svg <- toString.XMLNode(svg)
    lines <- strsplit(svg,'[\n]')[[1]]
    cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = out_file, append = FALSE)
    
  }
}
