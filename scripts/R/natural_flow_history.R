# dygraph of natural flow record for COlorado River at Lees Ferry, Arizona

library(dplyr)
library(xts)
library(dygraphs)

#' Read data
#' 
#' text file is in src_data, downloaded from 
#' ftp://ftp.ncdc.noaa.gov/pub/data/paleo/treering/reconstructions/northamerica/usa/upper-colorado-flow2007.txt
#' 
#' @section Issues:
#'   
#'   should 15-year average be the preceding 15 years rather than 7 before, 1
#'   during, and 7 after?
#'   
#'   more recent natural flow data available? have up through 2012
#'   
#' @import dplyr
#' @import xts
#' @return an xts object
read_flow_data <- function() {
  flow_file <- 'src_data/upper-colorado-flow2007.txt'
  lines <- readLines(flow_file)
  header_line <- grep("Year   Model  RecBCM  RMSE_BCM", lines)
  running_mean <- function(x,n=5) {
    stats::filter(x,rep(1/n,n), sides=2) %>%
      as.numeric()
  }
  flow_df <- read.csv(flow_file, skip=(header_line-1), sep="", stringsAsFactors = F) %>%
    mutate(TreeRings=RecBCM, TreeRingsLwr=TreeRings-RMSE_BCM, TreeRingsUpr=TreeRings+RMSE_BCM, 
           #FlowGage = suppressWarnings(as.numeric(ObsBCM)),
           TreeRings15YrRunMean = running_mean(TreeRings),
           TreeRingsAllYrMean = mean(TreeRings)) %>%
    select(Year, 
           TreeRings, TreeRingsLwr, TreeRingsUpr, 
           #FlowGage,
           TreeRings15YrRunMean,
           TreeRingsAllYrMean)
  
  # add more recent flow data (still only up to 2012)
  flow_file_recent <- 'src_data/NaturalFlow.csv'
  flow_df <- flow_df %>% full_join(
    read.csv(flow_file_recent) %>% 
      # these come in acre feet; convert to billion cubic meter
      mutate(FlowGage=Natural.Flow.above.Lees.Ferry/810713.182109) %>%
      select(Year, FlowGage), by="Year")
  
  flow_df <- flow_df %>% 
    mutate(Year = as.Date(paste0(Year, "-1-1")))
  flow_xts <- xts(flow_df %>% select(-Year) %>% as.matrix(), order.by=flow_df$Year)
  flow_xts
}
flow_data <- read_flow_data()

#' Make the figure
#' 
#' @section Issues:
#'   
#'   is this the right file structure to use?
#'   
#'   how to export to js or png or something?
#'   
#'   how to include exponents in y axis?
#'   
#'   year labels disappear when date range spans > 1000 years
#'   
#'   can you opt into seeing the averages or not, seeing the yearly data or not?
#'   it's pretty noisy.
#'   
#'   can you opt into seeing the numbers pop up for the averages or not?
#'   
#'   label for shaded drought years
#'   
#' @import dplyr
#' @import dygraphs
plot_flow_data <- function(flow_data) {
  # the figure
  dygraph(flow_data, main = 'Colorado River Natural Flow at Lees Ferry, AZ') %>%
    dyRangeSelector(dateWindow = as.Date(c("1812", "2012"), format="%Y")) %>% 
    dySeries(c("TreeRingsLwr", "TreeRings", "TreeRingsUpr"), label = "Tree Rings", color="navy") %>%
    dySeries(c("FlowGage"), label = "Flow Gage", color="skyblue") %>%
    dySeries(c("TreeRings15YrRunMean"), label = "15-Year Average", color="red") %>%
    dySeries(c("TreeRingsAllYrMean"), label = "Average", "forestgreen") %>%
    dyAxis("y", label = "Flow (10^9 m^3 y^-1)") %>%
    dyAxis("x", label = "Year") %>%
    dyLegend(width = 400) %>%
    dyShading(from = "2000-1-1", to = "2013-1-1")
  
  # potential dygraph enhancements
  # dyEvent(date = as.Date("2000-1-1"), "Y2K", labelLoc = 'bottom')
  # dyCSS("dygraph.css")
  
  # export dg to html/js/etc here
  
  # return
}
plot_flow_data(flow_data)
