# dygraph of natural flow record for Colorado River at Lees Ferry, Arizona

library(dplyr)
library(xts)
library(dygraphs)

#' Read data
#' 
#' Text files are in src_data, downloaded from 
#' ftp://ftp.ncdc.noaa.gov/pub/data/paleo/treering/reconstructions/northamerica/usa/upper-colorado-flow2007.txt
#' and supplied by this group (Alan Butler?) in NaturalFlow.csv 
#' 
#' @import dplyr
#' @import xts
#' @return an xts object
read_flow_data <- function() {
  flow_file <- 'src_data/upper-colorado-flow2007.txt'
  lines <- readLines(flow_file)
  header_line <- grep("Year   Model  RecBCM  RMSE_BCM", lines)
  running_mean <- function(x,n=10,sides=1) {
    stats::filter(x, rep(1/n,n), sides=1) %>% as.numeric()
  }
  flow_df <- read.csv(flow_file, skip=(header_line-1), sep="", stringsAsFactors = F) %>%
    # rename key columns
    mutate(TreeRings=RecBCM, TreeRingsLwr=TreeRings-RMSE_BCM, TreeRingsUpr=TreeRings+RMSE_BCM) %>%
    # these come in billion cubic meter (/yr); convert to millions of acre feet
    # (/yr). 1233.48184 cubic meters per acre feet, 1000 million per billion,
    # means (1000 million acre feet)/(1233.48184 billion cubic meters) = 0.8107132
    mutate(TreeRings=TreeRings*0.8107132, TreeRingsLwr=TreeRingsLwr*0.8107132, TreeRingsUpr=TreeRingsUpr*0.8107132) %>%
    # could compute running averages here: 
    # mutate(TreeRings10YrRunMean = running_mean(TreeRings), TreeRingsAllYrMean = mean(TreeRings)) %>%
    select(Year, TreeRings, TreeRingsLwr, TreeRingsUpr) #TreeRings10YrRunMean, TreeRingsAllYrMean)
  
  # add more recent flow data (still only up to 2012)
  flow_file_recent <- 'src_data/NaturalFlow.csv'
  flow_df <- flow_df %>% full_join(
    read.csv(flow_file_recent) %>% 
      # these come in acre feet; convert to million acre feet
      mutate(FlowGage=Natural.Flow.above.Lees.Ferry/1000000) %>%
      select(Year, FlowGage), by="Year")
  
  # compute running means on the average of TreeRings and FlowGage (or just one, when only one is available)
  flow_df <- flow_df %>%
    mutate(MeanTreeGage = rowMeans(cbind(TreeRings, FlowGage), na.rm=TRUE),
           TreeGage10YrRunMean = running_mean(MeanTreeGage),
           TreeGageAllYrMean = mean(MeanTreeGage), 
           Min10YrMean = min(TreeGage10YrRunMean, na.rm=TRUE)
           ) %>%
    select(-MeanTreeGage, -Min10YrMean)
  
  flow_df <- flow_df %>% 
    mutate(
      #LegendYear = Year,
      Year = as.Date(paste0(Year, "-1-1")))
  
  # write the data to file; this is how the html will actually access it.
  # http://dygraphs.com/data.html: '"CSV" is actually a bit of a misnomer: the 
  # data can be tab-delimited, too. The delimiter is set by the delimiter 
  # option. It default to ",". If no delimiter is found in the first row, it 
  # switches over to tab.'
#   custom_bars_format <- function(mid, low, high) {
#     if(missing(low) | missing(high)) low <- high <- mid
#     ifelse(complete.cases(data.frame(low, mid, high)),
#            paste(low, mid, high, sep=";"), 
#            NA)
#   }
#   flow_write <- flow_df %>% 
#     transmute(Year=format(Year, "%Y/%m/%d"),
#               TreeRings=custom_bars_format(TreeRings, TreeRingsLwr, TreeRingsUpr),
#               custom_bars_format(FlowGage), 
#               custom_bars_format(TreeGage10YrRunMean), 
#               custom_bars_format(TreeGageAllYrMean))
#   write.table(flow_write, "public_html/data/natural_flow_history.tsv", sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, na="")
    
  flow_xts <- xts(flow_df %>% select(-Year) %>% as.matrix(), order.by=flow_df$Year)
  flow_xts
}
flow_data <- read_flow_data()

#' Make the figure
#'    
#' @import dplyr
#' @import dygraphs
plot_flow_data <- function(flow_data) {
  # the figure
  dg <- dygraph(flow_data, main = 'Colorado River Natural Flow at Lees Ferry, AZ') %>%
    dyRangeSelector(dateWindow = as.Date(c("1812", "2012"), format="%Y")) %>% 
    dySeries(c("TreeRingsLwr", "TreeRings", "TreeRingsUpr"), label = "Tree-Ring Reconstructed Annual Natural Flow", color="#00CCFF") %>%
    dySeries(c("FlowGage"), label = "Historical Annual Natural Flow", color="#3333FF") %>%
    dySeries(c("TreeGage10YrRunMean"), label = "10-Year Average Flow", color="#C11B17") %>%
    dySeries(c("TreeGageAllYrMean"), label = "Long-Term Average Flow", "#FBB917") %>%
    #dySeries(c("LegendYear"), label = "Year", color="transparent", axis = "y2") %>%
    dyAxis("x", label = "Year") %>%
    dyAxis("y", label = "Flow Volume (million acre-feet)") %>%
    #dyAxis("y2", label = "", 
    #       valueFormatter="", 
    #       axisLabelFormatter=htmlwidgets::JS('function(x) return "";')) %>%
    dyLegend(labelsSeparateLines=TRUE, labelsDiv="legend_div") %>%
    dyShading(from = "2000-1-1", to = "2013-1-1")
  
  # potential dygraph enhancements
  # dyEvent(date = as.Date("2000-1-1"), "Y2K", labelLoc = 'bottom')
  # dyCSS("dygraph.css")
  
  # export dg to html. having trouble specifying fancy file locations - "file"
  # arg seems to only work if there aren't any folders in the file name, and
  # "libdir" seems to have to be a descendent of the folder where "file" is
  # located.
  oldwd <- setwd("temp/treeringdata")
  htmlwidgets::saveWidget(dg, "natural_flow_history.html", selfcontained = FALSE, libdir = "js")
  setwd(oldwd)
  
  # return dygraph for manual inspection if desired
  dg
}
dg <- plot_flow_data(flow_data)
dg
