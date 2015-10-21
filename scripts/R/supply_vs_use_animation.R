# build svg line animation

if(!require(dinosvg)){
	devtools::install_github('jread-usgs/dinosvg')
	library(dinosvg)
}


library(XML)
library(dplyr)
source('scripts/R/build_ecmascript.R')
source('scripts/R/manipulate_supply_usage.R')
source('scripts/R/manipulate_lowCO_borders_svg.R')

svg_file <- 'public_html/img/water-usage/flow_animation.svg'
mobile_svg_file <- 'public_html/img/water-usage/flow_animation-mobile.svg'
declaration <- '<?xml-stylesheet type="text/css" href="../../css/svg.css" ?>'

data = read_supply_use()

# create figure w/ axis based on units and form factor
svg_nd <- init_figure_supply_use(data, form.factor = 'mobile')



saveXML(svg_nd, file = mobile_svg_file)
svg <- xmlParse(mobile_svg_file, useInternalNode=TRUE) %>%
  toString.XMLNode()
lines <- strsplit(svg,'[\n]')[[1]]
cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = mobile_svg_file, append = FALSE)