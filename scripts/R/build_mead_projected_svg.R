# build svg line animation

if(!require(dinosvg)){
  devtools::install_github('jread-usgs/dinosvg')
  library(dinosvg)
}


library(XML)
library(dplyr)
source('scripts/R/build_ecmascript.R')
source('scripts/R/manipulate_lowCO_borders_svg.R')

svg_file <- 'public_html/img/mead_elev_projected.svg'
declaration <- '<?xml-stylesheet type="text/css" href="../css/main.css" ?>'
usage_col <- '#B22C2C'
supply_col <- '#0066CC'
line_width <- '3'
ani_time <- 15 # duration of line animation

l_bmp = 20 # px from axes
t_bmp = 20 # px from axes


# -- from Alan Butler's code --
hData <- read.csv('src_data/PowellMeadHistorical.csv', stringsAsFactors = F)
# add RunType column to historical data
hData$RunType <- 99
modData <- read.csv('src_data/PowellMead24MSResults_reformat.csv', stringsAsFactors = F)
meadData <- rbind(hData, modData)

# limit to only Mead, Pool Elevation
meadData <- dplyr::filter(meadData, Object.Name == 'Mead', Slot.Name == 'Pool Elevation')


# determine the y-axis limits
yMinR <- round(min(meadData$Value),-1)
yMaxR <- round(max(meadData$Value),-1)

# --- pixel dims ---
axes <- list('tick_len' = 5,
             'y_label' = "Elevation of Lake Mead (feet)",
             'y_ticks' = seq(yMinR,yMaxR,10),
             'y_tk_label' = seq(yMinR,yMaxR,10),
             'x_ticks' = seq(2009,2018,1),
             'x_tk_label' = seq(2009,2018,1),
             'y_lim' = c(yMinR-7,yMaxR+7),
             'x_lim' = c(2008.5,2018.25))


fig <- list('w' = 900,
            'h' = 600,
            'margins' = c(100,80,10, 10)) #bot, left, top, right

fig$px_lim <- list("x" = c(fig$margins[2], fig$w-fig$margins[4]),
                   "y" = c(fig$h-fig$margins[3]-fig$margins[1], fig$margins[3]))

supply_col <- '#0066CC'
line_width <- '3'
ani_time <- 15 # duration of line animation

l_bmp = 20 # px from axes
t_bmp = 20 # px from axes

svg_nd <- newXMLNode('svg', 
                     namespace = c("http://www.w3.org/2000/svg", xlink="http://www.w3.org/1999/xlink"), 
                     attrs = c(version = '1.1', onload="init(evt)", preserveAspectRatio="xMinYMin meet", viewBox=sprintf("0 0 %1.0f %1.0f",fig$w, fig$h)))

add_ecmascript(svg_nd, text = ecmascript_mead_proj())

g_id <- newXMLNode('g', parent = svg_nd)
add_axes(g_id, axes, fig)

#-- legend --
leg_id <- newXMLNode("g", 'parent' = g_id,
                     attrs = c('id' = "legend", 
                               class="label", 'alignment-baseline' = "central"))

newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
           attrs = c(id="date_text", x=fig$margins[2]+l_bmp, y=fig$margins[3]+t_bmp,class='legend'))
newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
           attrs = c(id="elev_text", x=fig$margins[2]+l_bmp, y=fig$margins[3]+t_bmp+15, fill = supply_col,class='legend'))
newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
           attrs = c(id="model_text", x=fig$margins[2]+l_bmp, y=fig$margins[3]+t_bmp+30, fill = '#000000',class='legend'))
#------

x <- as.numeric(strftime(as.POSIXct(meadData$Timestep), format = "%j"))/365+
  as.numeric(strftime(as.POSIXct(meadData$Timestep), format = "%Y"))

y = meadData$Value

time_ids <- strftime(as.POSIXct(meadData$Timestep), '%Y-%m-%d')
x <- sapply(x, FUN = function(x) dinosvg:::tran_x(x, axes, fig))
y <- sapply(y, FUN = function(y) dinosvg:::tran_y(y, axes, fig))

is.model <- meadData$Model != "Historical"
is.most <- meadData$RunType == 0 # most probable run
is.hist <- meadData$RunType == 99
is.minP <- meadData$RunType == 1 # minimum probable run
is.maxP <- meadData$RunType == 2 # maximum probable run

newXMLNode('rect',parent = g_id, attrs = c(id='ddddd',x = x[is.most][1], y = fig$px_lim$y[2], 
                                           width=fig$px_lim$x[2]-x[is.model][1], height=fig$px_lim$y[1]-fig$px_lim$y[2], 
                                                      fill='grey', opacity='0.2', stroke='none'))

y_offset <- fig$px_lim$y[1]-40
x_offset <- c(x[is.most][1] -4, x[is.most][1] + 18)

newXMLNode("text", parent = g_id, newXMLTextNode('Historical'),
           attrs = c(id="Historical-marker", 
                     'transform'=sprintf("rotate(-90,%1.1f,%1.1f),translate(%1.1f,%1.1f)",x_offset[1],y_offset,x_offset[1],y_offset)))
newXMLNode("text", parent = g_id, newXMLTextNode('Projected'),
           attrs = c(id="Projected-marker", 
                     'transform'=sprintf("rotate(-90,%1.1f,%1.1f),translate(%1.1f,%1.1f)",x_offset[2],y_offset,x_offset[2],y_offset)))

dinosvg:::linepath(g_id, x[is.hist],y[is.hist],fill = 'none', 
                              style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round",
                                             supply_col,line_width))

dinosvg:::linepath(g_id, c(x[is.minP], rev(x[is.maxP])),
                   c(y[is.minP], rev(y[is.maxP])),fill = '#99CCFF', 
                   style ="stroke:none;",opacity='0.5')

dinosvg:::linepath(g_id, x[is.most],y[is.most],fill = 'none', 
                              style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round;stroke-dasharray:6;stroke-linecap:round",
                                             '#555555',line_width))



# -----
width = 7 # FIX THIS!!!
for (i in 1:length(x)){
  #refine this so it is actually halfway points
  
  elev = ifelse(is.na(meadData$Value[i]), '', sprintf('%1.1f',meadData$Value[i]))
  
  
  if (is.model[i]){
    elev_text <- paste0(sprintf("ChangeText(evt, 'elev_text','Elevation: %s (ft)');", elev),
                        "ChangeText(evt, 'model_text','*Projected');")
  } else {
    elev_text <- paste0(sprintf("ChangeText(evt, 'elev_text','Elevation: %s (ft)');", elev),
                        "ChangeText(evt, 'model_text',' ');")
    
  }
    
  newXMLNode('rect','parent' = g_id, 
             attrs = c(id = time_ids[i], x = sprintf('%1.2f',x[i]-width/2), y = fig$px_lim$y[2], width = sprintf('%1.2f',width), height = fig$px_lim$y[1]-fig$px_lim$y[2],
                       'fill-opacity'="0.0", 
                       onmousemove=paste0(sprintf("ChangeText(evt, 'date_text','%s');",time_ids[i]),
                                          elev_text),
                       onmouseover="highlightEle(evt,'0.1')",
                       onmouseout="highlightEle(evt,'0.0')"))
}



root_nd <- xmlRoot(g_id)

saveXML(root_nd, file = svg_file)


cat('\n',declaration, file = svg_file, append = TRUE)

