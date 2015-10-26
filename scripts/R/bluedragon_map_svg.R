require(rgdal)
library(rgeos)
library(magrittr)
library(XML)
source('scripts/R/manipulate_lowCO_borders_svg.R')

transformBbox <- function (x, srcCrs, dstCrs) {
  bbox = Polygons(list(Polygon(cbind(c(x[1],x[1],x[3],x[3],x[1]), c(x[2],x[4],x[4],x[2],x[2])))),"bbox")
  spBbox = SpatialPolygons(list(bbox), proj4string = CRS(srcCrs))
  spBbox = spTransform(spBbox, CRS(dstCrs))
  return(spBbox)
}

transformPoint <- function(x, srcCrs, dstCrs) {
  point = SpatialPoints(cbind(x[1], x[2]), proj4string = CRS(srcCrs))
  point = spTransform(point, CRS(dstCrs))
  return(point)
}

bboxes <- list(
  hooverBbox=c(-114.7476482391,36.0050206578,-114.715719223,36.0300823705),
  davisBbox=c(-114.5924663544,35.1912759619,-114.5559883118,35.2145603133),
  needlesBbox=c(-114.6471405029,34.7026709419,-114.4397735596,34.8707217822),
  parkerBbox=c(-114.1537857056,34.2885663807,-114.1179084778,34.3203299518),
  headgateBbox=c(-114.2993545532,34.1550708939,-114.2504310608,34.1816307029),
  paloVerdeBbox=c(-114.5362472534,33.7134167623,-114.4813156128,33.7433978631),
  outfallBbox=c(-114.7362327576,33.2930861252,-114.6546936035,33.3706781613),
  imperialBbox=c(-114.4976234436,32.8710811177,-114.4457817078,32.9196555668),
  easternBbox=c(-113.9206695557,32.6625003547,-113.4420776367,32.9625864419),
  morelosBbox=c(-114.9540710449,32.6000478333,-113.8375854492,32.803436167),
  saltonBbox=c(-115.749206543,32.6671247331,-114.9087524414,33.4108095511)
)

refPts <- list(
	lasVegas=list(latlon=c(-115.1739, 36.1215), name="Las Vegas", pos=c(150.4375, 232.785156)),
	mexicali=list(latlon=c(-115.4678, 32.6633), name="Mexicali", pos=c(139.222656, 340.339844)),
	phoenix=list(latlon=c(-112.0667,33.4500), name="Phoenix", pos=c(228.886719, 317.398438))
)

width=7.5
height=7.6
plot_dir = 'public_html/img'
svg_file = file.path(plot_dir,paste0('bluedragon-inset','.svg'))
simp_tol <- 7000
grey_simp_tol <- 1.3*simp_tol # less res for non-highlighted states
min_area <- 1e+10
wgs84 <- '+init=epsg:4326'
epsg_code <- '+init=epsg:3479' #5070 for USGS CONUS albers?
textDx <- 12.5
textDy <- 5

mapbbox <- c(-119.53125,28.304380683,-101.42578125,40.7139558263) # in wgs84
projBbox <- transformBbox(mapbbox, wgs84, epsg_code)
ylim <- c(projBbox@bbox["y","min"], projBbox@bbox["y","max"])
xlim <- c(projBbox@bbox["x","min"], projBbox@bbox["x","max"])
  
lo_co_states <- c("California","Nevada","Arizona","Texas","Utah","Colorado","New Mexico","Oregon","Wyoming","Oklahoma","Nebraska","Kansas")

lo_co_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#BBBBBB', 'stroke-linejoin'='round')
mexico_styles = c('fill'='none', 'stroke-width'='2.5', 'stroke'='#BBBBBB', 'stroke-linejoin'='round')
co_river_styles = c('fill'='none', 'stroke-width'='3.5', 'stroke'='#0066CC', 'stroke-linejoin'="round", 
                    'style'="stroke-linejoin:round;stroke-linecap:round")
bbox_styles = c('fill'='none', 'stroke'='none')
ref_styles = c('fill'='none', 'stroke-width'=2.5, 'stroke'='#000000')
ref_text_styles = c()

mexico = readOGR(dsn = "src_data/mexico",layer="MEX_adm0") %>%
  spTransform(CRS(epsg_code)) %>%
  gSimplify(simp_tol)

states = readOGR(dsn = "src_data/states_21basic",layer="states") 
rivers = readOGR(dsn = "src_data/CRB_Rivers", layer="CRB_Rivers")

co_river <- rivers[substr(rivers$Name,1,14) == "Colorado River", ]

area <- lapply(mexico@polygons, function(x) sapply(x@Polygons, function(y) y@area))
mainPolys <- lapply(area, function(x) which(x > min_area))

# get rid of all polys below area threshold
mex_simp <- mexico
for(i in 1:length(mainPolys)){
  if(length(mainPolys[[i]]) >= 1 && mainPolys[[i]][1] >= 1){
    mex_simp@polygons[[i]]@Polygons <- mex_simp@polygons[[i]]@Polygons[mainPolys[[i]]]
    mex_simp@polygons[[i]]@plotOrder <- 1:length(mex_simp@polygons[[i]]@Polygons)
  }
}


svg(filename = svg_file,width=width, height=height)
par(omi=c(0,0,0,0),mai=c(0,0,0,0))

plot(mex_simp, ylim = ylim, xlim = xlim)

for (state in lo_co_states){
  state_border <- spTransform(states[states$STATE_NAME == state, ], CRS(epsg_code)) %>%
    gSimplify(simp_tol)
  plot(state_border, add=TRUE)
}

order <- sort(as.character(co_river@data$OBJECTID), index.return = T)$ix
co_river_line <- coordinates(co_river@lines[[order[1]]])[[1]]
for (i in 2:length(co_river@lines)){
  co_river_line <- rbind(co_river_line, coordinates(co_river@lines[[order[i]]])[[1]])
}
line <- Line(co_river_line)
lines <- Lines(list(line), ID='co-river')
co_river_join <- SpatialLines(list(lines), proj4string = CRS('+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0'))

spTransform(co_river_join, CRS(epsg_code)) %>%
  gSimplify(simp_tol) %>%
  plot(add=TRUE)

for (i in 1:length(bboxes)) {
  spBbox <- transformBbox(bboxes[[i]], wgs84, epsg_code)
  plot(spBbox, add=TRUE) 
}

ref_svg_names <- c()
for (i in 1:length(refPts)) {
  refName = names(refPts)[i]
  ref = refPts[[i]]
  spPoint <- transformPoint(ref$latlon, wgs84, epsg_code)
  plot(spPoint, pch=1, add=TRUE)
}

dev.off()

svg <- xmlParse(svg_file, useInternalNode=TRUE)

svg <- clean_svg_doc(svg) %>%
  name_svg_elements(svg, ele_names = c('Mexico', lo_co_states, 'Colorado-river', names(bboxes), names(refPts))) %>%
  group_svg_elements(groups = list('mexico' = 'Mexico', 'lo-co-states' = lo_co_states, 'co-river-polyline' = 'Colorado-river', 'bboxes' = names(bboxes), 'refPoints' = names(refPts))) %>%
  group_svg_elements(groups = c(lo_co_states,'Mexico', 'Colorado-river')) %>% # additional <g/> for each lo-co-state and mexico
  attr_svg_groups(attrs = list('mexico' = mexico_styles, 'lo-co-states' = lo_co_styles, 'co-river-polyline' = co_river_styles, 'bboxes' = bbox_styles, 'refPoints' = ref_styles)) %>%
  add_text(text=refPts[[1]]$name, x=as.character(refPts[[1]]$pos[1] - textDx),
           y=as.character(refPts[[1]]$pos[2] + textDy), 'fill'='#000000', 'text-anchor'="end", 'font-size'="1.5em") %>%
  add_text(text=refPts[[2]]$name, x=as.character(refPts[[2]]$pos[1]  - textDx),
           y=as.character(refPts[[2]]$pos[2] + textDy), 'fill'='#000000', 'text-anchor'="end", 'font-size'="1.5em") %>%
  add_text(text=refPts[[3]]$name, x=as.character(refPts[[3]]$pos[1]  + textDx),
           y=as.character(refPts[[3]]$pos[2] + textDy), 'fill'='#000000', 'text-anchor'="start", 'font-size'="1.5em") %>%
  toString.XMLNode()

cat(svg, file = svg_file, append = FALSE)
