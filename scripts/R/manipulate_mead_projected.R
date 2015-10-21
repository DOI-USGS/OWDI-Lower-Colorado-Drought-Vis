
conv = 0.3048 # feet to meters
supply_col <- '#FFFFFF'
line_width <- '5'
mead_projected_svg <- function(data, unit = 'Imperial', form.factor='desktop', language = 'en'){
  fig = get_fig(form.factor)
  axes = get_axes(data, form.factor, language)
  svg_nd <- newXMLNode('svg', 
                       namespace = c("http://www.w3.org/2000/svg", xlink="http://www.w3.org/1999/xlink"), 
                       attrs = c(version = '1.1', onload="init(evt)", preserveAspectRatio="xMinYMin meet", 
                                 viewBox=sprintf("0 0 %1.0f %1.0f",fig$w, fig$h), id="mead-elev-projected-svg"))
  
  add_ecmascript(svg_nd, text = ecmascript_mead_proj())
  
  add_blocks(svg_nd, form.factor, language, fig, axes)
  g_id <- newXMLNode('g', parent = svg_nd, attrs = c('id' = "axes", class='label'))
  
  
  add_axes(g_id, axes, fig, x_tick_rotate=0)
  
  label.shifts <- list('mobile'=list('y-label'=c(dy='-0.4em'), 'x-label'=c(dy='-0.8em')),
                       'desktop'=list('y-label'=c(dy='-1em'), 'x-label'=c(dy='-0.5em')))
  attr_svg(svg_nd, attr=label.shifts[[form.factor]], 'text')
  attr_svg(svg_nd, attr=list('axis.box'=c(style="fill:none;stroke:black")), 'rect')
  add_legend(g_id, form.factor, language, fig)
  
  add_lines(g_id, data, form.factor, language)
  return(svg_nd)
}

get_axes <- function(data, form.factor, language){
  unit <- c('es'='meters', 'en'='feet')
  x.ticks = c('desktop'=8, 'mobile'=4)
  y.label = c('desktop'=paste0("Elevation of Lake Mead (",unit[[language]],")"), 'mobile'=paste0("Elevation of Lake Mead (",unit[[language]],")"))
  
  y.ticks = list('es'=seq(1000,1225,25)*conv, 'en'=seq(1000,1225,25))
  y.lim = list('es'=c(990*conv,1229*conv), 'en'=c(990,1229))
  
  get_ticks <- function(x, n){
    x.rng = range(x)
    ticks = pretty(x.rng,n)
    ticks = ticks[ticks >= x.rng[1] & ticks <= x.rng[2]]
    return(ticks)
  }
  
  yMinR <- round(min(data$Value),-1)
  yMaxR <- round(max(data$Value),-1)
  
  posDate = data$posDate
  xMinR <- as.numeric(strftime(posDate[which.min(posDate)], 
                               format = "%Y"))
  xMaxR <- as.numeric(strftime(posDate[which.max(posDate)], 
                               format = "%Y"))
  maxMonth <- as.numeric(strftime(posDate[which.max(posDate)], 
                                  format = "%m")) + 3 # go to 3 months past the last date in the series
  
  axes <- list('tick_len' = 5,
               'y_label' = y.label[[form.factor]],
               'x_label' = "Year",
               'y_ticks' = y.ticks[[language]],
               'y_tk_label' = y.ticks[[language]],
               'x_ticks' = seq(xMinR,xMaxR,2),
               'x_tk_label' = seq(xMinR,xMaxR,2),
               'y_lim' = y.lim[[language]],
               'x_lim' = c(xMinR-.25,xMaxR+maxMonth/12)) 

  return(axes)
}

add_legend <- function(g_id, form.factor, language, fig){
  
  leg_id <- newXMLNode("g", 'parent' = g_id,
                       attrs = c('id' = "legend", 
                                 class="label", 'alignment-baseline' = "central"))
  
  newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
             attrs = c(id="date_text", x=fig$margins[2], y=fig$h-fig$margins[1],dy="-0.6em", dx="0.4em",class='legend'))
  newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
             attrs = c(id="elev_text", x=fig$margins[2], y=fig$h-fig$margins[1], dy="0.4em", dx="0.4em",fill = '#000000', class='legend'))
  newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
             attrs = c(id="model_text", x=fig$margins[2], y=fig$h-fig$margins[1],dy="1.6em",  dx="0.4em",fill = '#000000',class='legend'))
  newXMLNode('line',parent=leg_id, attrs=c(id='legend-line', 'x1'=fig$margins[2]+15,'x2'=fig$margins[2], y1=fig$h-fig$margins[1], y2= fig$h-fig$margins[1],fill = 'none', 
                                           style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round;stroke-linecap:round",
                                                          supply_col,line_width),visibility='hidden'))
}

get_fig <- function(form.factor){
  fig.dims <- list('mobile'=list('w' = 500,'h' = 400, 'margins' = c(40,60,10, 60)),
                   'desktop'=list('w' = 960,'h' = 600,'margins' = c(50,100,10, 100)))
  fig <- fig.dims[[form.factor]]
  
  fig$px_lim <- list("x" = c(fig$margins[2], fig$w-fig$margins[4]),
                     "y" = c(fig$h-fig$margins[3]-fig$margins[1], fig$margins[3]))
  return(fig)
}

read_mead_projected <- function(){
  
  # -- from Alan Butler's code --
  hData <- read.csv('src_data/MeadHistorical.csv', stringsAsFactors = F)
  # add RunType column to historical data
  hData$RunType <- 99
  modData <- read.csv('src_data/Mead24MSResults.csv', stringsAsFactors = F)
  meadData <- rbind(hData, modData)
  
  # limit to only Mead, Pool Elevation
  meadData <- dplyr::filter(meadData, Object.Name == 'Mead', Slot.Name == 'Pool Elevation')
  
  
  # determine the y-axis limits
  
  
  meadData$posDate = as.POSIXct(meadData$Timestep, format='%m/%d/%Y')
  return(meadData)
  
}

add_blocks <- function(svg_nd, form.factor, language, fig, axes){
  
  peak = floor(dinosvg:::tran_y(axes$y_lim[2], axes, fig))
  flood = floor(dinosvg:::tran_y(1219.6, axes, fig))
  surplus = floor(dinosvg:::tran_y(1200, axes, fig))
  normal = floor(dinosvg:::tran_y(1145, axes, fig))
  shortage = floor(dinosvg:::tran_y(1075, axes, fig))
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
                                               width=fig$px_lim$x[2]-fig$px_lim$x[1], height=shortage-normal+0.5,
                                               fill='#0066CC',opacity=0.6, class='level-fill'))
  newXMLNode('rect',parent = svg_nd, attrs = c(id='shortage',x = fig$px_lim$x[1], y = shortage,
                                               width=fig$px_lim$x[2]-fig$px_lim$x[1], height=bottom-shortage+0.5,
                                               fill='#0066CC',opacity=0.4, class='level-fill'))
  g_id = newXMLNode("g", parent = svg_nd, attrs=c(class='hidden', id='condition-markers'))
  newXMLNode("text", parent = g_id, newXMLTextNode('Flood Control Conditions'),
             attrs = c(x = fig$px_lim$x[2], y = mean(c(surplus,flood)),dy="0.5em", dx="0.4em",class='small-text'))
  newXMLNode("text", parent = g_id, newXMLTextNode('Surplus Conditions'),
             attrs = c(x = fig$px_lim$x[2], y = mean(c(normal,surplus)),dy="0.5em", dx="0.4em",class='small-text'))
  newXMLNode("text", parent = g_id, newXMLTextNode('Normal Conditions'),
             attrs = c(x = fig$px_lim$x[2], y = mean(c(shortage,normal)),dy="0.5em", dx="0.4em",class='small-text'))
  newXMLNode("text", parent = g_id, newXMLTextNode('Shortage Conditions'),
             attrs = c(x = fig$px_lim$x[2], y = mean(c(bottom,shortage)),dy="0.5em", dx="0.4em",class='small-text'))
}

add_lines <- function(g_id, data, form.factor, language){
  
  
  axes = get_axes(data, form.factor, language)
  fig = get_fig(form.factor)
  
  posDate = data$posDate
  
  x <- as.numeric(strftime(posDate, format = "%j"))/365+
    as.numeric(strftime(posDate, format = "%Y"))
  
  y = data$Value
  
  time_ids <- strftime(posDate, '%Y-%m-%d')
  x <- sapply(x, FUN = function(x) dinosvg:::tran_x(x, axes, fig))
  y <- sapply(y, FUN = function(y) dinosvg:::tran_y(y, axes, fig))
  
  is.model <- data$Model != "Historical"
  is.most <- data$RunType == 0 # most probable run
  is.hist <- data$RunType == 99
  is.minP <- data$RunType == 1 # minimum probable run
  is.maxP <- data$RunType == 2 # maximum probable run
  
  prob_run_title <- data$Model[is.most][1] # - assuming these are all the same
  
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
  
  dinosvg:::linepath(g_id, x[is.most],y[is.most],fill = 'none', id='dashed-projection',class='hidden',
                     style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round;stroke-dasharray:9;stroke-linecap:round",
                                    '#FFFFFF',line_width))
  
  
  
  # -----
  width = 7 # FIX THIS!!!
  for (i in 1:length(x)){
    #refine this so it is actually halfway points
    
    elev = ifelse(is.na(data$Value[i]), '', sprintf('%1.1f',data$Value[i]))
    
    
    if (is.model[i]){
      elev_text <- paste0(sprintf("ChangeText(evt, 'elev_text','Elevation: %s ft');ChangeText(evt, 'model_text','*%s');", elev,prob_run_title))
    } else {
      elev_text <- paste0(sprintf("ChangeText(evt, 'elev_text','Elevation: %s ft');", elev),
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
  
}