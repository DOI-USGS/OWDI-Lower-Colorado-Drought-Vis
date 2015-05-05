# creates the 24-MS figure for Mead elevation projections (Slide 10 from mockup presentation)
library(dplyr)
library(dygraphs)

create24MSFigure <- function()
{
  hData <- read.csv('../src_data/PowellMeadHistorical.csv')
  modData <- read.csv('../src_data/PowellMead24MSResults_reformat.csv')
  meadData <- rbind(hData, modData)
  
  # limit to only Mead, Pool Elevation
  meadData <- dplyr::filter(meadData, Object.Name == 'Mead', Slot.Name == 'Pool Elevation')
  
  ## TO CHECK
  # I think this assumes the data is ordered in time already
  startDate <- as.numeric(strsplit(as.character(meadData$Timestep[1]),'/')[[1]])
  mead <- ts(meadData$Value, frequency = 12, start = startDate[1:2])
  
  dygraph(mead)
    
}