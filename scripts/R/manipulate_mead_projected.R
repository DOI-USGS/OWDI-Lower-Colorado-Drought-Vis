
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
  add_annotations(svg_nd, form.factor, language, fig, axes)
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
  unit <- c('es'=lt('projFigMetricUnits',language), 'en'=lt('projFigImperialUnits',language))
  x.ticks = c('desktop'=8, 'mobile'=6)
  x.label = c('desktop'=lt('projFigXlab',language), 'mobile'='')
  y.label = paste0(lt('projFigYlab',language)," (",unit[[language]],")")
  
  y.ticks = list('es'=list('desktop'=seq(305,370,10),'mobile'=seq(310,370,20)), 'en'=list('desktop'=seq(1000,1225,25), 'mobile'=seq(1000,1225,50)))
  y.lim = list('es'=c(990*conv,1229*conv), 'en'=c(990,1229))
  
  get_ticks <- function(x, n){
    x.rng = range(x)
    ticks = pretty(x.rng,n)
    ticks = ticks[ticks >= x.rng[1] & ticks <= x.rng[2]]
    return(ticks)
  }

  
  posDate = data$posDate
  xMinR <- as.numeric(strftime(posDate[which.min(posDate)], 
                               format = "%Y"))
  xMaxR <- as.numeric(strftime(posDate[which.max(posDate)], 
                               format = "%Y"))
  maxMonth <- as.numeric(strftime(posDate[which.max(posDate)], 
                                  format = "%m")) + 3 # go to 3 months past the last date in the series
  axes <- list('tick_len' = 5,
               'y_label' = y.label,
               'x_label' = x.label[[form.factor]],
               'y_ticks' = y.ticks[[language]][[form.factor]],
               'y_tk_label' = y.ticks[[language]][[form.factor]],
               'x_ticks' = get_ticks(c(xMinR,xMaxR), x.ticks[[form.factor]]),
               'x_tk_label' = get_ticks(c(xMinR,xMaxR), x.ticks[[form.factor]]),
               'y_lim' = y.lim[[language]],
               'x_lim' = c(xMinR-.25,xMaxR+maxMonth/12)) 

  return(axes)
}


get_heights = function(axes, fig, language){
  elevs = list('en'=c('peak'=axes$y_lim[2], 'flood'=1219.6, 'surplus'=1200, 'normal'=1145, 'shortage'=1075, bottom=axes$y_lim[1]))
  elevs$es = elevs$en
  elevs$es[c('flood','surplus','normal','shortage')] <- elevs$en[c('flood','surplus','normal','shortage')]*conv
  
  x = lapply(elevs[[language]], function(x) floor(dinosvg:::tran_y(x, axes, fig)))

  return(x)
}
add_legend <- function(g_id, form.factor, language, fig){
  
  l_bmp <- 15
  line_ln <- 15
  x1 = fig$margins[2]+l_bmp+line_ln
  y1 = fig$h-fig$margins[1]-45
  
  leg_id <- newXMLNode("g", 'parent' = g_id,
                       attrs = c('id' = "legend", 
                                 class="label", 'alignment-baseline' = "central"))
  
  newXMLNode('line',parent=leg_id, attrs=c(id='legend-line', 'x1'=x1-line_ln,'x2'=x1, y1=y1, y2=y1,fill = 'none', 
                                           style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round;stroke-linecap:round",
                                                          supply_col,line_width),visibility='hidden'))
  newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
             attrs = c(id="date_text", x=x1, y=y1,dy="-0.6em", dx="0.4em",class='legend'))
  newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
             attrs = c(id="elev_text", x=x1, y=y1, dy="0.4em", dx="0.4em",fill = '#000000', class='legend'))
  newXMLNode("text", parent = leg_id, newXMLTextNode(' '),
             attrs = c(id="model_text", x=x1, y=y1,dy="1.6em",  dx="0.4em",fill = '#000000',class='legend'))
  
}

get_fig <- function(form.factor){
  fig.dims <- list('mobile'=list('w' = 500,'h' = 400, 'margins' = c(60,80,10, 10)),
                   'desktop'=list('w' = 960,'h' = 600,'margins' = c(50,100,10, 120)))
  fig <- fig.dims[[form.factor]]
  
  fig$px_lim <- list("x" = c(fig$margins[2], fig$w-fig$margins[4]),
                     "y" = c(fig$h-fig$margins[3]-fig$margins[1], fig$margins[3]))
  return(fig)
}



add_annotations <- function(svg_nd, form.factor, language, fig, axes){
  if (form.factor == 'desktop'){
    x = get_heights(axes, fig, language)
    g_id = newXMLNode("g", parent = svg_nd, attrs=c(class='hidden', id='condition-markers'))
    newXMLNode("text", parent = g_id, newXMLTextNode(lt('projFigFloodDesktop1',language)),
               attrs = c(x = fig$px_lim$x[2], y = mean(c(x$surplus,x$flood)),dx="0.4em",class='small-text'))
    newXMLNode("text", parent = g_id, newXMLTextNode(lt('projFigFloodDesktop2',language)),
               attrs = c(x = fig$px_lim$x[2], y = mean(c(x$surplus,x$flood)), dy="1.0em", dx="0.4em",class='small-text'))
    newXMLNode("text", parent = g_id, newXMLTextNode(lt('projFigSurplusDesktop',language)),
               attrs = c(x = fig$px_lim$x[2], y = mean(c(x$normal,x$surplus)),dy="0.5em", dx="0.4em",class='small-text'))
    newXMLNode("text", parent = g_id, newXMLTextNode(lt('projFigNormalDesktop',language)),
               attrs = c(x = fig$px_lim$x[2], y = mean(c(x$shortage,x$normal)),dy="0.5em", dx="0.4em",class='small-text'))
    newXMLNode("text", parent = g_id, newXMLTextNode(lt('projFigShortageDesktop',language)),
               attrs = c(x = fig$px_lim$x[2], y = mean(c(x$bottom,x$shortage)),dy="0.5em", dx="0.4em",class='small-text')) 
  } else {
    g_id = newXMLNode("g", parent = svg_nd, attrs=c(class='hidden', id='condition-markers'))
    x1 = fig$px_lim$x[1]
    x2 = fig$px_lim$x[2]
    x.rng = x2-x1
    bins = 4
    spaces = bins-1
    space.w = 30
    bin.w = (x.rng-spaces*space.w)/bins
    bin.h = 20
    y.off = 34
    labels = c(lt('projFigFloodMobile',language), lt('projFigSurplusMobile',language),lt('projFigNormalMobile',language),lt('projFigShortageMobile',language))
    opacity = c(.8, .7, .6, .4)
    for (i in seq_len(length(labels))){
      newXMLNode('rect',parent = g_id, attrs = c(x = x1+(i-1)*(bin.w+space.w), y = fig$h-fig$margins[3]-fig$margins[1]+y.off,
                                                 width=bin.w, height=bin.h,
                                                 fill='#0066CC',opacity=opacity[i]))
      newXMLNode("text", parent = g_id, newXMLTextNode(labels[i]),
                 attrs = c(x = x1+bin.w/2+(i-1)*(bin.w+space.w), y = fig$h-fig$margins[3]-fig$margins[1]+bin.h+y.off, dy="1.0em", class='small-text', 'text-anchor'='middle'))
    }
    
  }
  
  
}

add_blocks <- function(svg_nd, form.factor, language, fig, axes){
  

  x = get_heights(axes, fig, language)
  newXMLNode('rect',parent = svg_nd, attrs = c(id='flood',x = fig$px_lim$x[1], y = x$peak,
                                               width=fig$px_lim$x[2]-fig$px_lim$x[1], height=x$surplus-x$peak+0.2,
                                               fill='#0066CC', opacity=0.8, class='level-fill'))
  newXMLNode('rect',parent = svg_nd, attrs = c(id='surplus',x = fig$px_lim$x[1], y = x$surplus,
                                               width=fig$px_lim$x[2]-fig$px_lim$x[1], height=x$normal-x$surplus+0.2,
                                               fill='#0066CC',opacity=0.7, class='level-fill'))
  newXMLNode('rect',parent = svg_nd, attrs = c(id='normal',x = fig$px_lim$x[1], y = x$normal,
                                               width=fig$px_lim$x[2]-fig$px_lim$x[1], height=x$shortage-x$normal+0.2,
                                               fill='#0066CC',opacity=0.6, class='level-fill'))
  newXMLNode('rect',parent = svg_nd, attrs = c(id='shortage',x = fig$px_lim$x[1], y = x$shortage,
                                               width=fig$px_lim$x[2]-fig$px_lim$x[1], height=x$bottom-x$shortage+0.2,
                                               fill='#0066CC',opacity=0.4, class='level-fill'))
  
}

add_lines <- function(g_id, data, form.factor, language){
  
  y.vals = list('es'=data$Value*conv, 'en'=data$Value)
  axes = get_axes(data, form.factor, language)
  fig = get_fig(form.factor)
  y_offset <- c('desktop'=fig$px_lim$y[1]-20, 'mobile'=fig$px_lim$y[2]+20)
  t_anc = c('desktop'='begin','mobile'='end')
  
  posDate = data$posDate
  
  x.raw <- as.numeric(strftime(posDate, format = "%j"))/365+
    as.numeric(strftime(posDate, format = "%Y"))
  
  y.raw = y.vals[[language]]
  
  time_ids <- strftime(posDate, '%Y-%m-%d')
  x <- sapply(x.raw, FUN = function(x) dinosvg:::tran_x(x, axes, fig))
  y <- sapply(y.raw, FUN = function(y) dinosvg:::tran_y(y, axes, fig))
  
  is.model <- data$Model != "Historical"
  is.most <- data$RunType == 0 # most probable run
  is.hist <- data$RunType == 99

  prob_run_title <- data$Model[is.most][1] # - assuming these are all the same
  
  dinosvg:::linepath(g_id, c(x[is.most][1],x[is.most][1]),c(fig$px_lim$y[2],fig$px_lim$y[2]+fig$px_lim$y[1]-fig$px_lim$y[2]),fill = 'none', 
                     style =sprintf("stroke:#FFFFFF;stroke-width:%s;stroke-dasharray:5,2",
                                    1.5))
  
  x_offset <- c(x[is.most][1] -4, x[is.most][1] + 18)
  
  
  newXMLNode("text", parent = g_id, newXMLTextNode(lt('projFigHistorical',language)),
             attrs = c(id="Historical-marker", class='hidden', 'text-anchor'=t_anc[[form.factor]],
                       'transform'=sprintf("rotate(-90,%1.1f,%1.1f),translate(%1.1f,%1.1f)",
                                           x_offset[1],y_offset[[form.factor]],x_offset[1],y_offset[[form.factor]])))
  newXMLNode("text", parent = g_id, newXMLTextNode(lt('projFigProjected',language)),
             attrs = c(id="Projected-marker", class='hidden','text-anchor'=t_anc[[form.factor]],
                       'transform'=sprintf("rotate(-90,%1.1f,%1.1f),translate(%1.1f,%1.1f)",
                                           x_offset[2],y_offset[[form.factor]],x_offset[2],y_offset[[form.factor]])))
  
  dinosvg:::linepath(g_id, x[is.hist],y[is.hist],fill = 'none', 
                     style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round;stroke-linecap:round",
                                    supply_col,line_width))
  
  dinosvg:::linepath(g_id, x[is.most],y[is.most],fill = 'none', id='dashed-projection',class='hidden',
                     style =sprintf("stroke:%s;stroke-width:%s;stroke-linejoin:round;stroke-dasharray:9,5;stroke-linecap:round",
                                    '#FFFFFF',as.numeric(line_width)-1.5))
  
  
  
  # -----
  width = 7 # FIX THIS!!!
  for (i in which(is.hist | is.most)){
    #refine this so it is actually halfway points
    
    elev = ifelse(is.na(y[i]), '', prettyNum(round(y.raw[i], digits=1),big.mark=","))
    unit = c('es'='m','en'='ft')
    
    if (is.model[i]){
      elev_text <- paste0(sprintf("ChangeText(evt, 'elev_text','%s: %s %s');ChangeText(evt, 'model_text','*%s');", lt('projFigElevLegend',language),elev,unit[[language]],prob_run_title))
    } else {
      elev_text <- paste0(sprintf("ChangeText(evt, 'elev_text','%s: %s %s');", lt('projFigElevLegend',language), elev, unit[[language]]),
                          "ChangeText(evt, 'model_text',' ');")
      
    }
    
    newXMLNode('rect','parent' = g_id, 
               attrs = c(id = time_ids[i], x = sprintf('%1.2f',x[i]-width/2), y = fig$px_lim$y[2], width = sprintf('%1.2f',width), height = fig$px_lim$y[1]-fig$px_lim$y[2],
                         'fill-opacity'="0.0", 
                         onmousemove=paste0(sprintf("document.getElementById('legend-line').setAttribute('visibility','visbile');ChangeText(evt, 'date_text','%s: %s');",lt('projFigDateLegend',language),time_ids[i]),
                                            elev_text),
                         onmouseover="highlightEle(evt,'0.1')",
                         onmouseout="highlightEle(evt,'0.0')"))
  }
  
}


read_LEGACY_mead_historical <- function(){
  # -- from Alan Butler's code --
  hData <- read.csv('src_data/MeadHistorical.csv', stringsAsFactors = F)
  # add RunType column to historical data
  hData$RunType <- 99
  meadData <- dplyr::filter(hData, Object.Name == 'Mead', Slot.Name == 'Pool Elevation')
  
  meadData$posDate = as.POSIXct(meadData$Timestep, format='%Y/%m/%d')
  return(meadData[sort.int(meadData$posDate, index.return=TRUE)$ix, ])
}

read_mead_historical <- function(){
  
  data = read.csv('src_data/DynamicMeadHistorical.csv', stringsAsFactors = F)
  data$posDate = as.POSIXct(data$posDate, format='%Y-%m-%d')
  return(data)
}

get_mead_filename <- function(){
  date <- Sys.time()-86400*14 # two weeks earlier
  paste0(toupper(format(date,'%b%y')), '.csv')
}

get_probable_name <- function(){
  date <- Sys.time()-86400*14 # two weeks earlier
  format(date,'%B')
}

read_mead_projected <- function(){
  # GET DATE!
  
  file.url <- sprintf('http://ibr3lcrsrv01.bor.doi.net:8080/webReports/%s', get_mead_filename())
  lines <- readLines(file.url)
  use.lines <- which(grepl(',HOOVER,', lines))
  tf <- tempfile()
  writeLines(paste(lines[c(use.lines[1]-1, use.lines)], collapse='\n'), tf)
  data = read.csv(tf, stringsAsFactors = FALSE)
  old.hist <- read_mead_historical()
  
  # historical:
  filter(data, Historical.Flag == 'X') %>% 
    select(Date, EOM.Elevation..Ft.) %>% 
    rename(Value=EOM.Elevation..Ft.) %>% 
    mutate(posDate = as.POSIXct(Date, format='%m/%d/%Y')) %>% 
    select(-Date) %>% 
    mutate(Slot.Name="Pool Elevation", units="ft", Model="Historical", RunType=99, Object.Name = "Mead") %>% 
    filter(!posDate %in% old.hist$posDate) %>% 
    arrange(posDate) %>% 
    full_join(x=old.hist) %>% 
    write.csv(file = 'src_data/DynamicMeadHistorical.csv', row.names = FALSE)
  
  hData <- read_mead_historical()
  
  prob.name <- get_probable_name()
  # modeled:
  all.data <- filter(data, Historical.Flag != 'X') %>% 
    select(Date, EOM.Elevation..Ft., Scenario) %>% 
    rename(Value=EOM.Elevation..Ft., Model=Scenario) %>% 
    mutate(posDate = as.POSIXct(Date, format='%m/%d/%Y')) %>% 
    select(-Date) %>% 
    mutate(Slot.Name="Pool Elevation", units="ft", RunType=0, Object.Name = "Mead") %>% 
    filter(!posDate %in% old.hist$posDate) %>% 
    arrange(posDate) %>% 
    full_join(x=hData) %>% 
    mutate(Model = ifelse(Model == "Most Probable", paste0(prob.name, " ", Model), Model))

    
  return(all.data)
}