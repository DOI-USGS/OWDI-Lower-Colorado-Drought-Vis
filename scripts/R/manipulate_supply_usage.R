
usage_col <- '#B22C2C'
supply_col <- '#0066CC'

conv = 1.23348 # multiple maf by this to get billion m3
supply_usage_svg <- function(data, unit = 'Imperial', form.factor='desktop', language = 'en'){
  
  
  fig = get_fig(form.factor)
  svg_nd <- newXMLNode('svg', 
                       namespace = c("http://www.w3.org/2000/svg", xlink="http://www.w3.org/1999/xlink"), 
                       attrs = c(version = '1.1', onload="init(evt)", preserveAspectRatio="xMinYMin meet", viewBox=sprintf("0 0 %1.0f %1.0f",fig$w, fig$h)))
  
  add_ecmascript(svg_nd, text = ecmascript_supply_usage())
  g_id <- newXMLNode('g', parent = svg_nd, attrs = c(id="plot-contents", class="hidden"))

  
  
  a_id <- newXMLNode('g', parent = g_id, attrs = c('id' = "axes", class='label'))
  dinosvg::add_axes(a_id, get_axes(data, form.factor, language), fig, x_tick_rotate = 0)
  label.shifts <- list('mobile'=list('y-label'=c(dy='-0.4em'), 'x-label'=c(dy='-0.8em')),
                       'desktop'=list('y-label'=c(dy='-1em'), 'x-label'=c(dy='-0.5em')))
  attr_svg(svg_nd, attr=label.shifts[[form.factor]], 'text')
  
  add_legend(g_id, form.factor, language, fig)
  add_lines(g_id, data, form.factor, language)
  
  return(svg_nd)
  
}

get_fig <- function(form.factor){
  fig.dims <- list('mobile'=list('w' = 500,'h' = 400, 'margins' = c(40,60,10, 10)),
                   'desktop'=list('w' = 960,'h' = 600,'margins' = c(50,100,10, 100)))
  fig <- fig.dims[[form.factor]]
  
  fig$px_lim <- list("x" = c(fig$margins[2], fig$w-fig$margins[4]),
                     "y" = c(fig$h-fig$margins[3]-fig$margins[1], fig$margins[3]))
  return(fig)
}
get_axes <- function(data, form.factor, language){
  unit <- c('es'=lt('usageFigMetricUnits',language),'en'=lt('usageFigImperialUnits',language))
  x.ticks = c('desktop'=10, 'mobile'=5)
  y.label = c('desktop'=paste0(lt('usageFigYlabDesktop',language)," (",unit[[language]],")"), 
              'mobile'=paste0(lt('usageFigYlabMobile',language)," (",unit[[language]],")"))

  y.ticks = list('es'=seq(0,30*conv,5), 'en'=seq(0,25,5))
  y.lim = list('es'=c(0,30*conv), 'en'=c(0,29))
  
  get_ticks <- function(x, n){
    x.rng = range(x)
    ticks = pretty(x.rng,n)
    ticks = ticks[ticks >= x.rng[1] & ticks <= x.rng[2]]
    return(ticks)
  }
  
  # --- pixel dims ---
  axes <- list('tick_len' = 5,
               'y_label' = y.label[[form.factor]],
               'x_label' = lt('usageFigXlab',language),
               'y_ticks' = y.ticks[[language]],
               'y_tk_label' = y.ticks[[language]],
               'x_ticks' = get_ticks(data$times, x.ticks[[form.factor]]),
               'x_tk_label' = get_ticks(data$times, x.ticks[[form.factor]]),
               'y_lim' = y.lim[[language]],
               'x_lim' = c(range(data$times)[1]-2, range(data$times)[2]+2))
  return(axes)
}

read_supply_use <- function(){
  data <- read.csv('src_data/NaturalFlow.csv', stringsAsFactors = F)
  use_i <- !is.na(data$Natural.Flow.above.Imperial)
  flows <- data$Natural.Flow.above.Imperial[use_i]/1000000 #into millions acre-feet units
  years <- data$Year[use_i]
  data <- read.table('src_data/Basin_Depletion_yearly_PROVISIONAL.tsv', stringsAsFactors = F, sep = '\t', header = T)
  # will add stuff here to either fill usage w/NAs, or trim to have same supply and use be the same length
  usage <- c(rep(NA,8),data$depletion/1000,NA,NA) #into millions acre-feet units
  return(data.frame(times=years, supply=flows, usage=usage))
}

add_legend <- function(g_id, form.factor, language, fig){
  #-- legend --
  leg_id <- newXMLNode("g", 'parent' = g_id,
                       attrs = c('id' = "legend", visibility = 'hidden',
                                 class="label", 'alignment-baseline' = "central"))
  text.place = list('mobile'=list(c(dy='1.0em', dx='0.5em'), c(dy='2.0em', dx='0.5em'), c(dy='3.0em', dx='0.5em')),
                    'desktop'=list(c(dy='1.5em', dx='1.0em'), c(dy='2.5em', dx='1.0em'), c(dy='3.5em', dx='1.0em')))
  newXMLNode("text", parent = leg_id, newXMLTextNode('year'),
             attrs = c(id="year_text", x=fig$margins[2], y=fig$margins[3],class='legend', text.place[[form.factor]][[1]]))
  newXMLNode("text", parent = leg_id, newXMLTextNode('use_text'),
             attrs = c(id="use_text", x=fig$margins[2], y=fig$margins[3], fill = usage_col,class='legend', text.place[[form.factor]][[2]]))
  newXMLNode("text", parent = leg_id, newXMLTextNode('supply_text'),
             attrs = c(id="supply_text", x=fig$margins[2], y=fig$margins[3], fill = supply_col,class='legend', text.place[[form.factor]][[3]]))
  
}

add_lines <- function(g_id, data, form.factor, language){
  
  axes = get_axes(data, form.factor, language)
  fig = get_fig(form.factor)
  
  line_width <- '3'
  ani_time <- 12 # duration of line animation
  
  years = data$times
  flows = data$supply
  usage = data$usage
  if (language == 'es'){
    flows = flows*conv
    usage = usage*conv
  }

  x <- sapply(years, FUN = function(x) dinosvg:::tran_x(x, axes, fig))
  y <- sapply(flows, FUN = function(y) dinosvg:::tran_y(y, axes, fig))
  line_length <- function(x1,y1,x2,y2){
    len <- sqrt((x2-x1)^2 + (y2-y1)^2)
    return(len)
  }
  
  tot_time <- tail(years,1) - head(years,1)
  difTimes <- cumsum(diff(years)/tot_time)
  difTimes <- c(0,difTimes)*ani_time
  x1 <- head(x,-1)
  x2 <- tail(x,-1)
  y1 <- head(y,-1)
  y2 <- tail(y,-1)
  line_len <- line_length(x1,y1,x2,y2)
  tot_len <- sum(line_len)
  
  
  # calc_lengths 
  values <- paste(tot_len- cumsum(line_len),collapse=';')
  line_nd <- dinosvg:::linepath(g_id, x,y,fill = 'none', id='supply-liner',
                                style =sprintf("stroke:%s;stroke-width:%s;stroke-dasharray:%0.0f;stroke-linejoin:round;stroke-dashoffset:%0.0f",
                                               supply_col,line_width,tot_len+1,tot_len+1))
  dinosvg:::animate_attribute(line_nd, attr_name = "stroke-dashoffset", 
                              begin = "indefinite;visibleAxes.begin+1s", id = "timeAdvance", 
                              fill = 'freeze', dur = sprintf('%fs',ani_time), values = values)
  
  usage_id <- newXMLNode("g", 'parent' = g_id,
                         attrs = c('id' = "supply", style=paste0("fill:",supply_col), r = '0', visibility = 'hidden'))
  
  
  for (i in 1:length(x)){
    
    nd <- dinosvg:::circle(usage_id , x[i], y[i],  id = paste0('supply-',years[i]))
    
    if(!is.na(y[i])){
      # / otherwise, radius is never > 0
      newXMLNode('animate', 'parent' = nd,
                 attrs = c('attributeName' = "r",
                           'begin' = sprintf("timeAdvance.begin+%0.3fs",max(difTimes[i]-0.2,0)),
                           'fill' = "freeze", 'from'='0','to'='1.5',dur="0.01s"))
      
    }
    
    
  }
  
  # --- for usage ----
  y <- sapply(usage, FUN = function(y) dinosvg:::tran_y(y, axes, fig))
  # note x is the same as above
  y1 <- head(y,-1)
  y2 <- tail(y,-1)
  line_len <- line_length(x1,y1,x2,y2)
  line_len[is.na(line_len)] = 0
  tot_len <- sum(line_len, na.rm = T)
  
  width <- x2[1]-x1[1] # assumes continuous years!!
  
  
  
  # -----usage line
  values <- paste(tot_len- cumsum(line_len),collapse=';')
  
  line_nd <- dinosvg:::linepath(g_id, x[!is.na(y)],y[!is.na(y)], fill = 'none', id='usage-liner',
                                style =sprintf("stroke:%s;stroke-width:%s;stroke-dasharray:%0.0fpx;stroke-linejoin:round;stroke-dashoffset:%0.0f",
                                               usage_col, line_width, tot_len+1,tot_len+1))
  dinosvg:::animate_attribute(line_nd, attr_name = "stroke-dashoffset", 
                              begin = "timeAdvance.begin", id = "usage", 
                              fill = 'freeze', dur = sprintf('%fs',ani_time), values = values)
  # -----
  usage.label = c('desktop'=lt('usageFigUseDesktop',language), 'mobile'=lt('usageFigUseMobile',language))
  supply.label = c('desktop'=lt('usageFigSupplyDesktop',language), 'mobile'=lt('usageFigSupplyMobile',language))
  unit = c('es'='bcm','en'='maf')
  for (i in 1:length(x)){
    #refine this so it is actually halfway points
    
    use = ifelse(is.na(usage[i]), '', sprintf('%1.1f %s',usage[i], unit[[language]]))
    flow = ifelse(is.na(flows[i]), '', sprintf('%1.1f %s',flows[i], unit[[language]]))
    newXMLNode('rect','parent' = g_id, 
               attrs = c(id = sprintf('year_%s',years[i]), x = sprintf('%1.2f',x[i]-width/2), y = fig$px_lim$y[2], width = sprintf('%1.2f',width), height = fig$px_lim$y[1]-fig$px_lim$y[2],
                         'fill-opacity'="0.0", 
                         onmousemove=paste0(sprintf("legendViz(evt,'supply-%s');",years[i]),
                                            sprintf("ChangeText(evt, 'year_text','%s: %s');",lt('usageFigXlab',language),years[i]),
                                            sprintf("ChangeText(evt, 'use_text','%s: %s');", usage.label[[form.factor]],use),
                                            sprintf("ChangeText(evt, 'supply_text','%s: %s');", supply.label[[form.factor]], flow)),
                         onmouseover=paste0(sprintf("highlightViz(evt,'supply-%s','0.1');",years[i])),
                         onmouseout=paste0("document.getElementById('legend').setAttribute('visibility', 'hidden');",
                                           sprintf("highlightViz(evt,'supply-%s','0.0');",years[i]))))
  }
}