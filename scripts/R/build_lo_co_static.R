plot_dir = 'public_html/img/lower-co-map'
read_dir = 'src_data/lower-co-map'
svg_file = file.path(read_dir,paste0('lo_CO_borders','.svg'))
out_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))

non_lo_styles = c('fill'='#FFFFFF', 'fill-opacity'='0.2', 'stroke-width'='2.5', 'stroke'='#FFFFFF', 'stroke-linejoin'='round', mask="url(#non-lo-co-mask)")

svg <- xmlParse(svg_file, useInternalNode=TRUE) %>%
  remove_svg_elements(elements = c('delete_group'='g','top-users'='g')) %>%
  attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles)) %>%
  toString.XMLNode()

cat(svg, file = out_file, append = FALSE)
