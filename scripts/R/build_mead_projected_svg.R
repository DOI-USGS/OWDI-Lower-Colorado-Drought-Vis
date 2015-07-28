# build svg line animation

if(!require(dinosvg)){
  devtools::install_github('jread-usgs/dinosvg')
  library(dinosvg)
}


library(XML)
library(dplyr)
source('scripts/R/build_ecmascript.R')
source('scripts/R/manipulate_lowCO_borders_svg.R')

svg_file <- 'public_html/img/lake-mead-static/mead_elev_projected.svg'
declaration <- '<?xml-stylesheet type="text/css" href="../../css/svg.css" ?>'
supply_col <- '#0066CC'
#line_width <- '10'
ani_time <- 15 # duration of line animation

l_bmp = 20 # px from axes
t_bmp = 20 # px from axes


# -- from Alan Butler's code --
hData <- read.csv('src_data/MeadHistorical.csv', stringsAsFactors = F)
# add RunType column to historical data
hData$RunType <- 99
modData <- read.csv('src_data/Mead24MSResults.csv', stringsAsFactors = F)
meadData <- rbind(hData, modData)

# limit to only Mead, Pool Elevation
meadData <- dplyr::filter(meadData, Object.Name == 'Mead', Slot.Name == 'Pool Elevation')


# determine the y-axis limits
yMinR <- round(min(meadData$Value),-1)
yMaxR <- round(max(meadData$Value),-1)

xMinR <- as.numeric(strftime(as.POSIXct(
  meadData$Timestep[which.min(as.numeric(as.POSIXct(meadData$Timestep)))]), 
  format = "%Y"))
xMaxR <- as.numeric(strftime(as.POSIXct(
  meadData$Timestep[which.max(as.numeric(as.POSIXct(meadData$Timestep)))]), 
  format = "%Y"))
maxMonth <- as.numeric(strftime(as.POSIXct(
  meadData$Timestep[which.max(as.numeric(as.POSIXct(meadData$Timestep)))]), 
  format = "%m")) + 3 # go to 3 months past the last date in the series


# --- pixel dims ---
1216 #full pool 
800 #dead pool
axes <- list('tick_len' = 5,
             'y_label' = "Elevation of Lake Mead (feet)",
             'y_ticks' = seq(1000,1200,50),
             'y_tk_label' = seq(1000,1200,50),
             'x_ticks' = seq(xMinR,xMaxR,1),
             'x_tk_label' = seq(xMinR,xMaxR,1),
             'y_lim' = c(990,1229),
             'x_lim' = c(xMinR-.25,xMaxR+maxMonth/12)) 


fig <- list('w' = 960,
            'h' = 600,
            'margins' = c(100,125,10, 125)) #bot, left, top, right

fig$px_lim <- list("x" = c(fig$margins[2], fig$w-fig$margins[4]),
                   "y" = c(fig$h-fig$margins[3]-fig$margins[1], fig$margins[3]))

supply_col <- '#FFFFFF'#0066CC'
line_width <- '5'
ani_time <- 15 # duration of line animation

l_bmp = 30 # px from axes
t_bmp = 50 # px from axes

svg_nd <- newXMLNode('svg', 
                     namespace = c("http://www.w3.org/2000/svg", xlink="http://www.w3.org/1999/xlink"), 
                     attrs = c(version = '1.1', onload="init(evt)", preserveAspectRatio="xMinYMin meet", viewBox=sprintf("0 0 %1.0f %1.0f",fig$w, fig$h)))

add_ecmascript(svg_nd, text = ecmascript_mead_proj())


peak = floor(dinosvg:::tran_y(axes$y_lim[2], axes, fig))
flood = floor(dinosvg:::tran_y(1219.6, axes, fig))
surplus = floor(dinosvg:::tran_y(1200, axes, fig))
normal = floor(dinosvg:::tran_y(1145, axes, fig))
shortage1 = floor(dinosvg:::tran_y(1075, axes, fig))
shortage2 = floor(dinosvg:::tran_y(1050, axes, fig))
shortage3 = floor(dinosvg:::tran_y(1025, axes, fig))
bottom = floor(dinosvg:::tran_y(axes$y_lim[1], axes, fig))

newXMLNode('rect',parent = svg_nd, attrs = c(id='peak',x = fig$px_lim$x[1], y = peak,
                                           width=fig$px_lim$x[2]-fig$px_lim$x[1], height=flood-peak+0.5,
                                           fill='#0066CC',opacity=0.9, class='level-fill'))
newXMLNode('rect',parent = svg_nd, attrs = c(id='flood',x = fig$px_lim$x[1], y = flood,
                                           width=fig$px_lim$x[2]-fig$px_lim$x[1], height=surplus-flood+0.5,
                                           fill='#0066CC', opacity=0.8, class='level-fill'))
newXMLNode('rect',parent = svg_nd, attrs = c(id='surplus',x = fig$px_lim$x[1], y = surplus,
                                           width=fig$px_lim$x[2]-fig$px_lim$x[1], height=normal-surplus+0.5,
                                           fill='#0066CC',opacity=0.7, class='level-fill'))
newXMLNode('rect',parent = svg_nd, attrs = c(id='normal',x = fig$px_lim$x[1], y = normal,
                                             width=fig$px_lim$x[2]-fig$px_lim$x[1], height=shortage1-normal+0.5,
                                             fill='#0066CC',opacity=0.6, class='level-fill'))
newXMLNode('rect',parent = svg_nd, attrs = c(id='shortage1',x = fig$px_lim$x[1], y = shortage1,
                                             width=fig$px_lim$x[2]-fig$px_lim$x[1], height=shortage2-shortage1+0.5,
                                             fill='#0066CC',opacity=0.5, class='level-fill'))
newXMLNode('rect',parent = svg_nd, attrs = c(id='shortage2',x = fig$px_lim$x[1], y = shortage2,
                                             width=fig$px_lim$x[2]-fig$px_lim$x[1], height=shortage3-shortage2+0.5,
                                             fill='#0066CC',opacity=0.4, class='level-fill'))
newXMLNode('rect',parent = svg_nd, attrs = c(id='shortage3',x = fig$px_lim$x[1], y = shortage3,
                                             width=fig$px_lim$x[2]-fig$px_lim$x[1], height=bottom-shortage3+0.5,
                                             fill='#0066CC',opacity=0.3, class='level-fill'))
g_id = newXMLNode("g", parent = svg_nd, attrs=c(class='hidden', id='condition-markers'))
newXMLNode("text", parent = g_id, newXMLTextNode('Flood Control Surplus'),
           attrs = c(x = fig$px_lim$x[2], y = mean(c(surplus,flood)),dy="0.5em", dx="0.4em",class='small-text'))
newXMLNode("text", parent = g_id, newXMLTextNode('Domestic Surplus'),
           attrs = c(x = fig$px_lim$x[2], y = mean(c(normal,surplus)),dy="0.5em", dx="0.4em",class='small-text'))
newXMLNode("text", parent = g_id, newXMLTextNode('Normal Conditions'),
           attrs = c(x = fig$px_lim$x[2], y = mean(c(shortage1,normal)),dy="0.5em", dx="0.4em",class='small-text'))
newXMLNode("text", parent = g_id, newXMLTextNode('Shortage Tier 1'),
           attrs = c(x = fig$px_lim$x[2], y = mean(c(shortage2,shortage1)),dy="0.5em", dx="0.4em",class='small-text'))
newXMLNode("text", parent = g_id, newXMLTextNode('Shortage Tier 2'),
           attrs = c(x = fig$px_lim$x[2], y = mean(c(shortage3,shortage2)),dy="0.5em", dx="0.4em",class='small-text'))
newXMLNode("text", parent = g_id, newXMLTextNode('Shortage Tier 3'),
           attrs = c(x = fig$px_lim$x[2], y = mean(c(shortage3,bottom)),dy="0.5em", dx="0.4em",class='small-text'))



g_id <- newXMLNode('g', parent = svg_nd, attrs = c('id' = "axes", class='label'))
add_axes(g_id, axes, fig)

attr_svg(svg_nd, attr=list('y-label'=c(dy='-0.3em')), 'text')
attr_svg(svg_nd, attr=list('axis.box'=c(style="fill:none;stroke:black")), 'rect')


#-- legend --
leg_id <- newXMLNode("g", 'parent' = g_id,
                     attrs = c('id' = "legend", 
                               class="label", 'alignment-baseline' = "central"))

newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
           attrs = c(id="date_text", x=fig$margins[2]+l_bmp, y=fig$h-fig$margins[1]-t_bmp,dy="-0.6em", dx="0.4em",class='legend'))
newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
           attrs = c(id="elev_text", x=fig$margins[2]+l_bmp, y=fig$h-fig$margins[1]-t_bmp, dy="0.4em", dx="0.4em",fill = '#000000', class='legend'))
newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
           attrs = c(id="model_text", x=fig$margins[2]+l_bmp, y=fig$h-fig$margins[1]-t_bmp,dy="1.6em",  dx="0.4em",fill = '#000000',class='legend'))
newXMLNode('line',parent=leg_id, attrs=c(id='legend-line', 'x1'=fig$margins[2]+15,'x2'=fig$margins[2]+l_bmp, y1=fig$h-fig$margins[1]-t_bmp, y2= fig$h-fig$margins[1]-t_bmp,fill = 'none', 
                                         style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round;stroke-linecap:round",
                                                        supply_col,line_width),visibility='hidden'))
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

prob_run_title <- meadData$Model[is.most][1] # - assuming these are all the same

dinosvg:::linepath(g_id, c(x[is.most][1],x[is.most][1]),c(fig$px_lim$y[2],fig$px_lim$y[2]+fig$px_lim$y[1]-fig$px_lim$y[2]),fill = 'none', 
                   style =sprintf("stroke:#FFFFFF;stroke-width:%s;stroke-dasharray:5,2",
                                  1.5))

y_offset <- fig$px_lim$y[1]-20
x_offset <- c(x[is.most][1] -4, x[is.most][1] + 18)

newXMLNode("text", parent = g_id, newXMLTextNode('Historical'),
           attrs = c(id="Historical-marker", class='hidden',
                     'transform'=sprintf("rotate(-90,%1.1f,%1.1f),translate(%1.1f,%1.1f)",x_offset[1],y_offset,x_offset[1],y_offset)))
newXMLNode("text", parent = g_id, newXMLTextNode('Projected'),
           attrs = c(id="Projected-marker", class='hidden',
                     'transform'=sprintf("rotate(-90,%1.1f,%1.1f),translate(%1.1f,%1.1f)",x_offset[2],y_offset,x_offset[2],y_offset)))

dinosvg:::linepath(g_id, x[is.hist],y[is.hist],fill = 'none', 
                              style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round;stroke-linecap:round",
                                             supply_col,line_width))

# 
# dinosvg:::linepath(g_id, c(x[is.minP], rev(x[is.maxP])),
#                    c(y[is.minP], rev(y[is.maxP])),fill = 'white', 
#                    style ="stroke:none;",opacity='0.4',class='hidden',id='filled-projection')

dinosvg:::linepath(g_id, x[is.most],y[is.most],fill = 'none', id='dashed-projection',class='hidden',
                              style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round;stroke-dasharray:9;stroke-linecap:round",
                                             '#a9a9a9',line_width))



# -----
width = 7 # FIX THIS!!!
for (i in 1:length(x)){
  #refine this so it is actually halfway points
  
  elev = ifelse(is.na(meadData$Value[i]), '', sprintf('%1.1f',meadData$Value[i]))
  
  
  if (is.model[i]){
    elev_text <- paste0(sprintf("ChangeText(evt, 'elev_text','Elevation: %s (ft)');ChangeText(evt, 'model_text','*%s');", elev,prob_run_title))
  } else {
    elev_text <- paste0(sprintf("ChangeText(evt, 'elev_text','Elevation: %s (ft)');", elev),
                        "ChangeText(evt, 'model_text',' ');")
    
  }
    
  newXMLNode('rect','parent' = g_id, 
             attrs = c(id = time_ids[i], x = sprintf('%1.2f',x[i]-width/2), y = fig$px_lim$y[2], width = sprintf('%1.2f',width), height = fig$px_lim$y[1]-fig$px_lim$y[2],
                       'fill-opacity'="0.0", 
                       onmousemove=paste0(sprintf("document.getElementById('legend-line').setAttribute('visibility','visbile');ChangeText(evt, 'date_text','%s');",time_ids[i]),
                                          elev_text),
                       onmouseover="highlightEle(evt,'0.1')",
                       onmouseout="highlightEle(evt,'0.0')"))
}



root_nd <- xmlRoot(g_id)

saveXML(root_nd, file = svg_file)
svg <- xmlParse(svg_file, useInternalNode=TRUE) %>%
  toString.XMLNode()
lines <- strsplit(svg,'[\n]')[[1]]
cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = svg_file, append = FALSE)


