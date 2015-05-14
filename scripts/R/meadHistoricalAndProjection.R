# creates the 24-MS figure for Mead elevation projections (Slide 10 from mockup presentation)
library(dplyr)
library(dygraphs)
library(htmlwidgets)

create24MSFigure <- function()
{
  hData <- read.csv('../src_data/PowellMeadHistorical.csv')
  modData <- read.csv('../src_data/PowellMead24MSResults_reformat.csv')
  meadData <- rbind(hData, modData)
  
  # limit to only Mead, Pool Elevation
  meadData <- dplyr::filter(meadData, Object.Name == 'Mead', Slot.Name == 'Pool Elevation')
  
  ## TO CHECK
  # I think this assumes the data is ordered in time already
  ## TO DO
  # modify so that the data selection is dynamic and can handle min/most/max proable
  
  # Get the 24-MS projected elevations
  simData <- dplyr::filter(meadData, Model == 'March Most Probable')
  startDate <- as.numeric(strsplit(as.character(simData$Timestep[1]),'/')[[1]])
  mead <- ts(simData$Value, frequency = 12, start = startDate[1:2])
  
  # combine with the historical data
  hData <- dplyr::filter(meadData, Model == 'Historical')
  startDate <- as.numeric(strsplit(as.character(hData$Timestep[1]),'/')[[1]])
  mead <- cbind(mead, ts(hData$Value, frequency = 12, start = startDate[1:2]))
  colnames(mead) <- c('March Most Probable','Historical')
  
  ## TO DO
  # Try to get historical and projected labels to show up on different lines
  # Compute the historical vs. projected event data
  
  jsFormatXAxis <- "function(x) {var monAbb = ['Jan', 'Feb','Mar','Apr','May','Jun','Jul',
                      'Aug','Sep','Oct','Nov','Dec'];
                      var yrStr = x.getFullYear().toString()
                      return monAbb[x.getMonth()] + \" \'\" + yrStr[2] + yrStr[3]}"
  
  # Used mid month instead of end of month
  hVsPDate <- '2015-02-14'
  meadDG <- dygraph(mead, main = 'Lake Mead Historical and Projected Elevations') %>%
    dyAxis('y', label = 'Elevation [feet]') %>%
    dyLegend(width = 400) %>%
    dyEvent(date = hVsPDate, "Historical<br/>Projected", labelLoc = 'bottom') %>%
    dyAxis('x', axisLabelFormatter = JS(jsFormatXAxis))
  
  meadDG
}