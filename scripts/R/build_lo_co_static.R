plot_dir = 'public_html/img/lower-co-map'
read_dir = 'src_data/lower-co-map'
svg_file = file.path(read_dir,paste0('lo_CO_borders','.svg'))
out_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))

svg <- xmlParse(svg_file, useInternalNode=TRUE) %>%
  remove_svg_elements(elements = c('delete_group'='g','top-users'='g')) %>%
  toString.XMLNode()

cat(svg, file = out_file, append = FALSE)
