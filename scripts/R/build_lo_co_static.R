library(magrittr)
library(XML)
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/read_translation.R')

declaration <- '<?xml-stylesheet type="text/css" href="../../../css/svg.css" ?>'

for (lang in c("en", "es")) {
  
  plot_dir = sprintf('public_html/%s/img', lang)
  read_dir = 'src_data/lower-co-map'
  svg_file = file.path(read_dir,paste0('lo_CO_borders','.svg'))
  out_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))
  
  non_lo_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#505050', 'stroke-linejoin'='round', mask="url(#non-lo-co-mask)")
  lo_co_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#505050', 'stroke-linejoin'='round', mask="url(#non-lo-co-mask)")
  mexico_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#505050', mask="url(#mexico-mask)", 'stroke-linejoin'='round')
  co_river_styles = c('fill'='#1975d1')
  co_basin_styles = c('fill'='#B22C2C')
  
  svg <- xmlParse(svg_file, useInternalNode=TRUE) %>%
    remove_svg_elements(elements = c('delete_group'='g','top-users'='g', 'non-lo-co-mask'='mask','mexico-mask'='mask')) %>%
    add_radial_mask(r=c('300','300'), id = c('non-lo-co-mask','mexico-mask'), cx=c('220','300'),cy=c('200','300')) %>%
    attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles, 'mexico' = mexico_styles, 'lo-co-states' = lo_co_styles)) %>%
    add_text(text=lt('lowCoFigLowerBasin', lang), x="320", y="230", 'fill'='#B22C2C', 'text-anchor'="start") %>%
    add_text(text=lt('lowCoFigUpperBasin', lang), x="338", y="130", 'fill'='#B22C2C', 'text-anchor'="start") %>%
    add_text(text=lt('lowCoFigRiver', lang), x="345", y="70", 'fill'='#1975d1', 'text-anchor'="start") %>%
    toString.XMLNode()
  
  lines <- strsplit(svg,'[\n]')[[1]]
  cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = out_file, append = FALSE)
}