# build svg line animation

library(dinosvg)
library(XML)


data <- read.csv('../src_data/NaturalFlow.csv', stringsAsFactors = F)
flows <- data$Natural.Flow.above.Imperial/1000000 #into millions acre-feet units
years <- data$Year
data <- read.table('../src_data/Basin_Depletion_yearly_PROVISIONAL.tsv', stringsAsFactors = F, sep = '\t', header = T)
usage <- c(data$depletion/1000,NA,NA) #into millions acre-feet units


# --- pixel dims ---
axes <- list('tick_len' = 5,
             'y_label' = "Volume (million acre-feet)",
             'y_ticks' = seq(0,25,5),
             'y_tk_label' = seq(0,25,5),
             'x_ticks' = seq(1910,2010,10),
             'x_tk_label' = seq(1910,2010,10),
             'y_lim' = c(0,29),
             'x_lim' = c(1904,2014))

fig <- list('w' = 900,
            'h' = 600,
            'margins' = c(100,80,10, 60)) #bot, left, top, right

fig$px_lim <- list("x" = c(fig$margins[2], fig$w-fig$margins[2]-fig$margins[4]),
                   "y" = c(fig$h-fig$margins[3]-fig$margins[1], fig$margins[3]))


l_bmp = 20 # px from axes
t_bmp = 20 # px from axes

g_id <- svg_init(fig, def_opacity = 0.5)
add_axes(g_id, axes, fig)

#-- legend --
leg_id <- newXMLNode("g", 'parent' = g_id,
                     attrs = c('id' = "legend", visibility = 'hidden'))

newXMLNode("text", parent = leg_id, newXMLTextNode('year'),
           attrs = c(class="label", id="year_text", x=fig$margins[2]+l_bmp, y=fig$margins[3]+t_bmp, 'alignment-baseline' = "central"))
newXMLNode("text", parent = leg_id, newXMLTextNode('use_text'),
           attrs = c(class="label", id="use_text", x=fig$margins[2]+l_bmp, y=fig$margins[3]+t_bmp+15, 'alignment-baseline' = "central", fill = "#B22C2C"))
newXMLNode("text", parent = leg_id, newXMLTextNode('supply_text'),
           attrs = c(class="label", id="supply_text", x=fig$margins[2]+l_bmp, y=fig$margins[3]+t_bmp+30, 'alignment-baseline' = "central", fill = "#0066CC"))
#------



# --- for flows (supply) ---
x <- sapply(years, FUN = function(x) dinosvg:::tran_x(x, axes, fig))
y <- sapply(flows, FUN = function(y) dinosvg:::tran_y(y, axes, fig))
line_length <- function(x1,y1,x2,y2){
  len <- sqrt((x2-x1)^2 + (y2-y1)^2)
  return(len)
}

x1 <- head(x,-1)
x2 <- tail(x,-1)
y1 <- head(y,-1)
y2 <- tail(y,-1)
line_len <- line_length(x1,y1,x2,y2)
tot_len <- sum(line_len)
tot_time <- tail(years,1) - head(years,1)
ani_time <- 15
# calc_lengths 
values <- paste(tot_len- cumsum(line_len),collapse=';')
difTimes <- cumsum(diff(years)/tot_time)
keyTimes <- paste(difTimes,collapse=';') # not used?
difTimes <- c(0,difTimes)*ani_time # now same length as elements
line_nd <- dinosvg:::linepath(g_id, x,y,fill = 'none', style =sprintf("stroke:#0066CC;stroke-width:3;stroke-dasharray:%0.0f;stroke-linecap:round;stroke-dashoffset:%0.0f",tot_len+1,tot_len+1))
dinosvg:::animate_attribute(line_nd, attr_name = "stroke-dashoffset", 
                            begin = "indefinite", id = "timeAdvance", 
                            fill = 'freeze', dur = sprintf('%fs',ani_time), values = values)


#!! consider reusing defs:
# <defs>
#   <circle id="animation" r="0"
#     fill="#0066CC" visibility = 'hidden'>
#       <animate attributeName="r" 
#         from="0" to="1.5" 
#         dur="0.01s"/>
#   </rect>
# </defs>
#     
# <!-- use  multiple times -->
# <use xlink:href="#animation"/>
# <use xlink:href="#animation" x="100" />
#     

usage_id <- newXMLNode("g", 'parent' = g_id,
                     attrs = c('id' = "supply", style="fill:#0066CC", r = '0', visibility = 'hidden'))


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
tot_time <- tail(years,1) - head(years,1)

# calc_lengths 

# -----usage line
values <- paste(tot_len- cumsum(line_len),collapse=';')

line_nd <- dinosvg:::linepath(g_id, x,y, fill = 'none',
                              style =sprintf("stroke:#B22C2C;stroke-width:3;stroke-dasharray:%0.0fpx;stroke-linecap:round;stroke-dashoffset:%0.0f",tot_len+1,tot_len+1))
dinosvg:::animate_attribute(line_nd, attr_name = "stroke-dashoffset", 
                            begin = "timeAdvance.begin", id = "usage", 
                            fill = 'freeze', dur = sprintf('%fs',ani_time), values = values)
# -----


for (i in 1:length(x)){
  #refine this so it is actually halfway points
  width <- x2[i]-x1[i]
  if (is.na(width)){
    width = x2[1]-x1[1] # for the last one. Can/should improve this
  }
  
  use = ifelse(is.na(usage[i]), '', sprintf('%1.1f',usage[i]))
  flow = ifelse(is.na(flows[i]), '', sprintf('%1.1f',flows[i]))
  newXMLNode('rect','parent' = g_id, 
             attrs = c(id = sprintf('year_%s',years[i]), x = x[i]-width/2, y = fig$px_lim$y[2], width = width, height = fig$px_lim$y[1]-fig$px_lim$y[2],
                       'fill-opacity'="0.0", 
                       onmousemove=paste0(sprintf("legendViz(evt,'supply-%s');",years[i]),
                                          sprintf("ChangeText(evt, 'year_text','%s');",years[i]),
                                          sprintf("ChangeText(evt, 'use_text','usage: %s');", use),
                                          sprintf("ChangeText(evt, 'supply_text','supply: %s');", flow)),
                       onmouseover=paste0(sprintf("highlightViz(evt,'supply-%s','0.1');",years[i])),
                       onmouseout=paste0("document.getElementById('legend').setAttribute('visibility', 'hidden');",
                                         sprintf("highlightViz(evt,'supply-%s','0.0');",years[i]))))
}

root_nd <- xmlRoot(g_id)

saveXML(root_nd, file = '../public_html/img/flow_animation.svg')
