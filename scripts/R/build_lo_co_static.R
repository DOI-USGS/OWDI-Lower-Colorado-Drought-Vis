library(magrittr)
library(XML)

declaration <- '<?xml-stylesheet type="text/css" href="../../css/svg.css" ?>'

plot_dir = 'public_html/img/lower-co-map'
read_dir = 'src_data/lower-co-map'
svg_file = file.path(read_dir,paste0('lo_CO_borders','.svg'))
out_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))

non_lo_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#505050', 'stroke-linejoin'='round', mask="url(#non-lo-co-mask)")
lo_co_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#505050', 'stroke-linejoin'='round', mask="url(#non-lo-co-mask)")
mexico_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#505050', mask="url(#mexico-mask)", 'stroke-linejoin'='round')
co_river_styles = c('fill'='#0066CC')
co_basin_styles = c('fill'='#B22C2C')

svg <- xmlParse(svg_file, useInternalNode=TRUE) %>%
  remove_svg_elements(elements = c('delete_group'='g','top-users'='g', 'non-lo-co-mask'='mask','mexico-mask'='mask','rect')) %>%
  add_radial_mask(r=c('300','300'), id = c('non-lo-co-mask','mexico-mask'), cx=c('220','300'),cy=c('200','300')) %>%
  attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles, 'mexico' = mexico_styles, 'lo-co-states' = lo_co_styles)) %>%
  add_text(text="Colorado Basin", x="320", y="230", 'fill'='#B22C2C', 'text-anchor'="start") %>%
  add_text(text="Colorado River", x="350", y="90", 'fill'='#0066CC', 'text-anchor'="start") %>%
  toString.XMLNode()

lines <- strsplit(svg,'[\n]')[[1]]
cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = out_file, append = FALSE)
