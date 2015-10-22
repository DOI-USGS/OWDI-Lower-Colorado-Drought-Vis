# build svg line animation

if(!require(dinosvg)){
  devtools::install_github('jread-usgs/dinosvg')
  library(dinosvg)
}


library(XML)
library(dplyr)
source('scripts/R/build_ecmascript.R')
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/manipulate_mead_projected.R')
svg_dir <- 'public_html/img/lake-mead-static/'
declaration <- '<?xml-stylesheet type="text/css" href="../../css/svg.css" ?>'
form.factors = c('desktop','mobile')
languages=c('en')#'es',
data = read_mead_projected()

for (form.factor in form.factors){
  for (language in languages){
    svg_nd <- mead_projected_svg(data, form.factor=form.factor, language=language)
    
    
    svg_file = file.path(svg_dir, paste0('mead_elev_projected-',form.factor,'-',language,'.svg'))
    saveXML(svg_nd, file = svg_file)
    svg <- xmlParse(svg_file, useInternalNode=TRUE) %>%
      toString.XMLNode()
    lines <- strsplit(svg,'[\n]')[[1]]
    cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), 
        file = svg_file, append = FALSE)
  }
}
