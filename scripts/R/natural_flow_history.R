# dygraph of natural flow record for COlorado River at Lees Ferry, Arizona

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
  running_mean <- function(x,n=15,sides=1) {
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
    # mutate(TreeRings15YrRunMean = running_mean(TreeRings), TreeRingsAllYrMean = mean(TreeRings)) %>%
    select(Year, TreeRings, TreeRingsLwr, TreeRingsUpr) #TreeRings15YrRunMean, TreeRingsAllYrMean)
  
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
           TreeGage15YrRunMean = running_mean(MeanTreeGage),
           TreeGageAllYrMean = mean(MeanTreeGage),
           Min15YrMean = min(TreeGage15YrRunMean, na.rm=TRUE)) %>%
    select(-MeanTreeGage)
  
  flow_df <- flow_df %>% 
    mutate(Year = as.Date(paste0(Year, "-1-1")))
  flow_xts <- xts(flow_df %>% select(-Year) %>% as.matrix(), order.by=flow_df$Year)
  flow_xts
}
flow_data <- read_flow_data()

write_flow_data <- function(flow_data) {
  # http://dygraphs.com/data.html: '"CSV" is actually a bit of a misnomer: the
  # data can be tab-delimited, too. The delimiter is set by the delimiter
  # option. It default to ",". If no delimiter is found in the first row, it
  # switches over to tab.'
  write.table(flow_data, "public_html/data/natural_flow_history.tsv", sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE)
}
write_flow_data(flow_data)

#' Make the figure
#'    
#' @import dplyr
#' @import dygraphs
plot_flow_data <- function(flow_data) {
  # the figure
  dg <- dygraph(flow_data, main = 'Colorado River Natural Flow at Lees Ferry, AZ') %>%
    dyRangeSelector(dateWindow = as.Date(c("1812", "2012"), format="%Y")) %>% 
    dySeries(c("TreeRingsLwr", "TreeRings", "TreeRingsUpr"), label = "Tree Rings", color="#00CCFF") %>%
    dySeries(c("FlowGage"), label = "Observed", color="#3333FF") %>%
    dySeries(c("TreeGage15YrRunMean"), label = "15-Year Average", color="red") %>%
    dySeries(c("TreeGageAllYrMean"), label = "Average", "forestgreen") %>%
    dySeries(c("Min15YrMean"), label = "Lowest 15-Year Average in Record", color="gold") %>%
    dyAxis("y", label = "Flow (million acre-feet per year)") %>%
    dyAxis("x", label = "Year") %>%
    dyLegend(width = 400) %>%
    dyShading(from = "2000-1-1", to = "2013-1-1")
  
  # potential dygraph enhancements
  # dyEvent(date = as.Date("2000-1-1"), "Y2K", labelLoc = 'bottom')
  # dyCSS("dygraph.css")
  
  # export dg to html. having trouble specifying fancy file locations - "file"
  # arg seems to only work if there aren't any folders in the file name, and
  # "libdir" seems to have to be a descendent of the folder where "file" is
  # located.
  oldwd <- setwd("public_html/widgets/slide_3")
  htmlwidgets::saveWidget(dg, "natural_flow_history.html", selfcontained = FALSE, libdir = "js")
  setwd(oldwd)
  
  # return dygraph for manual inspection if desired
  dg
}
plot_flow_data(flow_data)
