# build svg line animation

library(dinosvg)
library(XML)
data <- read.csv('../src_data/NaturalFlow.csv', stringsAsFactors = F)
flows <- data$Natural.Flow.above.Imperial/1000000
years <- data$Year
usage <- seq(5,15, length.out = length(years)) + runif(length(years))
# --- pixel dims ---
axes <- list('tick_len' = 5,
             'y_label' = "Volume (million acre-feet)",
             'y_ticks' = seq(0,25,5),
             'y_tk_label' = seq(0,25,5),
             'x_ticks' = seq(1900,2010,10),
             'x_tk_label' = seq(1900,2010,10),
             'y_lim' = c(0,27),
             'x_lim' = c(1900,2014))

fig <- list('w' = 900,
            'h' = 600,
            'margins' = c(100,80,10, 60)) #bot, left, top, right

fig$px_lim <- list("x" = c(fig$margins[2], fig$w-fig$margins[2]-fig$margins[4]),
                   "y" = c(fig$h-fig$margins[3]-fig$margins[1], fig$margins[3]))




g_id <- svg_init(fig, def_opacity = 0.5)
add_axes(g_id, axes, fig)

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
keyTimes <- paste(difTimes,collapse=';')
difTimes <- c(0,difTimes)*ani_time # now same length as elements
line_nd <- dinosvg:::linepath(g_id, x,y,style =sprintf("stroke:#0066CC;stroke-width:3;stroke-dasharray:%0.0f;stroke-linecap:round;stroke-dashoffset:%0.0f",tot_len+1,tot_len+1), id = 'test')
dinosvg:::animate_attribute(line_nd, attr_name = "stroke-dashoffset", 
                            begin = "indefinite", id = "timeAdvance", dur = sprintf('%fs',ani_time), values = values, keyTimes = keyTimes)
for (i in 1:length(x)){
  nd <- dinosvg:::circle(g_id, x[i], y[i], style="fill:#0066CC;fill-opacity:0", id = paste0('usage-',i), r = 1.5, tip_name = years[i])
  newXMLNode("animate", 'parent' = nd,
             attrs = c('attributeName' = "fill-opacity",
                       'begin' = sprintf("timeAdvance.begin+%0.3fs",difTimes[i]),
                       'fill' = "freeze", 'from'='0','to'='1',dur="0.1s"))
  newXMLNode('set', 'parent' = nd,
             attrs = c('attributeName' = "r",
                       to="5", begin="year_1979.mouseover", end="year_1979.mouseout"))
}

# --- for usage ----
y <- sapply(usage, FUN = function(y) dinosvg:::tran_y(y, axes, fig))
x1 <- head(x,-1)
x2 <- tail(x,-1)
y1 <- head(y,-1)
y2 <- tail(y,-1)
line_len <- line_length(x1,y1,x2,y2)
tot_len <- sum(line_len)
tot_time <- tail(years,1) - head(years,1)

# calc_lengths 
values <- paste(tot_len- cumsum(line_len),collapse=';')
line_nd <- dinosvg:::linepath(g_id, x,y,style =sprintf("stroke:#B22C2C;stroke-width:3;stroke-dasharray:%0.0fpx;stroke-linecap:round;stroke-dashoffset:%0.0f",tot_len+1,tot_len+1), id = 'test')
dinosvg:::animate_attribute(line_nd, attr_name = "stroke-dashoffset", 
                            begin = "timeAdvance.begin", id = "usage", dur = sprintf('%fs',ani_time), values = values, keyTimes = keyTimes)
newXMLNode('rect','parent' = g_id, 
           attrs = c(id = 'year_1979', x = 40, y = 40, width = 40, height = 40))
for (i in 1:length(x)){
  nd <- dinosvg:::circle(g_id, x[i], y[i], style="fill:#B22C2C;fill-opacity:0", id = paste0('supply-',i), r = 1.5, tip_name = years[i])
  newXMLNode('set', 'parent' = nd,
             attrs = c('attributeName' = "r",
                       to="5", begin="year_1979.mouseover", end="year_1979.mouseout"))
  newXMLNode("animate", 'parent' = nd,
             attrs = c('attributeName' = "fill-opacity",
                       'begin' = sprintf("timeAdvance.begin+%0.3fs",difTimes[i]),
                       'fill' = "freeze", 'from'='0','to'='1',dur="0.1s"))
}

newXMLNode("rect", parent = g_id, newXMLTextNode('Tooltip'),
           attrs = c(class="label", id="tooltip_bg", x="0", y="0", rx="4", ry="4", 
                     width="55", height="28", style="fill:#f6f6f6;fill-opacity:0.85;stroke:#696969;stroke-width:0.5;",
                     visibility="hidden"))

newXMLNode("text", parent = g_id, newXMLTextNode('Tooltip'),
           attrs = c(class="label", id="tooltip", x="0", y="0", 
                     visibility="hidden"))

root_nd <- xmlRoot(g_id)

saveXML(root_nd, file = './flow_animation.svg')
