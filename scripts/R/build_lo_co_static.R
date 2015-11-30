library(magrittr)
library(XML)
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/read_translation.R')

declaration <- '<?xml-stylesheet type="text/css" href="../../../css/svg.css" ?>'

border_line = c(d="M 146.738281 265.828125 L 146.84375 264.300781 L 190.777344 262.011719 L 189.265625 266.664062 L 257.804688 292.414062 L 310.195312 291.324219 L 309.863281 281.632812 L 339.296875 280.402344 L 342.859375 280.863281 L 344.445312 282.222656 L 346.980469 286.742188 L 351.480469 288.71875 L 355.429688 292.640625 L 358.734375 294.546875 L 362.847656 298.976562 L 367.121094 300.609375 L 372.492188 304.875 L 374.125 308.675781 L 377.019531 312.796875 L 377.4375 318.113281 L 380.371094 323.734375 L 382.828125 325.820312 L 386.539062 327.203125 L 390.238281 330.503906 L 393.257812 331.273438 L 404.953125 336.707031 L 407.496094 336.808594 L 411.136719 332.203125 L 415.570312 319.667969 L 418.789062 318.558594 L 422.265625 315.949219 L 426.753906 317.527344 L 439.425781 316.949219 L 441.523438 320.199219 L 445.035156 322.601562 L 446.917969 323.0625 L 452.039062 327.011719 L 454.824219 330.023438 L 455.738281 333.234375 L 461.941406 342.285156 L 463.9375 347.308594 L 465.945312 348.933594 L 468.117188 349.640625 L 472.472656 354.738281 L 473.679688 357.464844 L 476.582031 359.753906 L 478.363281 359.917969 L 480.511719 361.3125 L 482.375 367.945312 L 482.539062 372.574219 L 485.652344 376.160156 L 487.027344 376.878906 L 490.8125 385.214844 L 504.371094 388.484375 L 507.292969 390.695312 L 509.480469 391.492188 L 512.296875 391.710938 L 516.441406 390.710938 L 520.46875 391.023438 L 525.5 394.585938 L 526.546875 394.546875 L 527.328125 392.675781 L 530.671875 391.261719 ")

for (lang in c("en", "es")) {
  
  plot_dir = sprintf('public_html/%s/img', lang)
  read_dir = 'src_data/lower-co-map'
  svg_file = file.path(read_dir,paste0('lo_CO_borders','.svg'))
  out_file = file.path(plot_dir,paste0('lo_CO_borders','.svg'))
  
  non_lo_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#505050', 'stroke-linejoin'='round', mask="url(#non-lo-co-mask)")
  lo_co_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#505050', 'stroke-linejoin'='round', mask="url(#non-lo-co-mask)")
  mexico_styles = c('fill'='none', 'stroke-width'='1.5', 'stroke'='#505050', mask="url(#mexico-mask)", 'stroke-linejoin'='round')
  mexico_bdr_styles  = c('fill'='none', 'stroke-width'='4.5', 'stroke'='#505050', mask="url(#mexico-mask)", 'stroke-linejoin'='round')
  co_river_styles = c('fill'='#1975d1')
  co_basin_styles = c('fill'='#B22C2C')
  
  svg <- xmlParse(svg_file, useInternalNode=TRUE) %>%
    remove_svg_elements(elements = c('delete_group'='g','top-users'='g', 'non-lo-co-mask'='mask','mexico-mask'='mask')) %>%
    add_radial_mask(r=c('300','300'), id = c('non-lo-co-mask','mexico-mask'), cx=c('220','300'),cy=c('200','300')) %>%
    attr_svg_paths(attrs = list('mexico-border'=border_line)) %>% 
    attr_svg_groups(attrs = list('non-lo-co-states' = non_lo_styles, 'mexico' = mexico_styles, 'Mexico-border'=mexico_bdr_styles,'lo-co-states' = lo_co_styles)) %>%
    add_text(text=lt('lowCoFigLowerBasin', lang), x="320", y="230", 'fill'='#B22C2C', 'text-anchor'="start") %>%
    add_text(text=lt('lowCoFigUpperBasin', lang), x="338", y="130", 'fill'='#B22C2C', 'text-anchor'="start") %>%
    add_text(text=lt('lowCoFigRiver', lang), x="345", y="70", 'fill'='#1975d1', 'text-anchor'="start") %>%
    toString.XMLNode()
  
  lines <- strsplit(svg,'[\n]')[[1]]
  cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = out_file, append = FALSE)
}