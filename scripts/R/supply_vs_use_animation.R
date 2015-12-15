# build svg line animation

if(!require(dinosvg) || packageVersion('dinosvg') != '0.1.9'){
  devtools::install_github('jread-usgs/dinosvg@v0.1.9')
  library(dinosvg)
}


library(XML)
library(dplyr)
source('scripts/R/build_ecmascript.R')
source('scripts/R/manipulate_supply_usage.R')
source('scripts/R/manipulate_lowCO_borders_svg.R')
source('scripts/R/read_translation.R')



declaration <- '<?xml-stylesheet type="text/css" href="../../css/svg.css" ?>'
form.factors = c('desktop','mobile')
languages=c('en', 'es') 
data = read_supply_use()

# create figure w/ axis based on units and form factor

for (form.factor in form.factors){
  for (language in languages){
    svg_dir <- sprintf('public_html/%s/img/',language)
    svg_nd <- supply_usage_svg(data, form.factor=form.factor, language=language)
    
    
    svg_file = file.path(svg_dir, paste0('flow_animation-',form.factor,'.svg'))
    saveXML(svg_nd, file = svg_file)
    svg <- xmlParse(svg_file, useInternalNode=TRUE) %>%
      toString.XMLNode()
    lines <- strsplit(svg,'[\n]')[[1]]
    cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), 
        file = svg_file, append = FALSE)
  }
}
