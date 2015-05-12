# dygraph of natural flow record for COlorado River at Lees Ferry, Arizona

library(dplyr)
library(xts)
library(dygraphs)

#' Read data
#' 
#' text file is in src_data, downloaded from 
#' ftp://ftp.ncdc.noaa.gov/pub/data/paleo/treering/reconstructions/northamerica/usa/upper-colorado-flow2007.txt
#' 
#' @import dplyr
#' @import xts
#' @return an xts object
read_flow_data <- function() {
  flow_file <- 'src_data/upper-colorado-flow2007.txt'
  lines <- readLines(flow_file)
  header_line <- grep("Year   Model  RecBCM  RMSE_BCM", lines)
  flow_df <- read.csv(flow_file, skip=(header_line-1), sep="", stringsAsFactors = F) %>%
    mutate(Year = as.Date(paste0(Year, "-1-1")),
           TreeRingsLwr=RecBCM-RMSE_BCM, TreeRingsUpr=RecBCM+RMSE_BCM, 
           ObsBCM = suppressWarnings(as.numeric(ObsBCM)),
           ObsMAF = suppressWarnings(as.numeric(ObsMAF))) %>% 
    select(Year, TreeRings=RecBCM, TreeRingsLwr, TreeRingsUpr, FlowGage=ObsBCM)
  flow_xts <- xts(flow_df %>% select(-Year) %>% as.matrix(), order.by=flow_df$Year)
  flow_xts
}
flow_data <- read_flow_data()

#' Make the figure
#' 
#' @section Issues:
#'   
#'   how to export to js or png or something?
#'   
#'   how to include exponents in y axis?
#'   
#'   years disappear when date range requires ticks < 899 AD
#'
#' @import dplyr
#' @import dygraphs
plot_flow_data <- function(flow_data) {
  dg <- dygraph(flow_data, main = 'Colorado River Natural Flow at Lees Ferry, AZ') %>%
    dyRangeSelector(dateWindow = as.Date(c("1805", "2005"), format="%Y")) %>% 
    dySeries(c("TreeRingsLwr", "TreeRings", "TreeRingsUpr"), label = "Tree Rings") %>%
    dySeries(c("FlowGage"), label = "Flow Gage") %>%
    dyAxis("y", label = "Flow (10^9 m^3)") %>%
    dyAxis("x", label = "Year") %>%
  dyLegend(width = 400) #%>%
  #dyEvent(date = as.Date("2000-1-1"), "Y2K", labelLoc = 'bottom')
  #dyCSS("dygraph.css")
  
  dg
}
plot_flow_data(flow_data)
