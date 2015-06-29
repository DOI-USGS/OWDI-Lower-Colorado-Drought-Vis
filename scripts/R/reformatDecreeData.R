# arrange and aggregate LC Decree Acct. Data
library(xlsx)
library(reshape2)

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

reformatLBDec <- function(yrs = 2000:2014, rowsToRead = rbind(c(4,274),c(3,108),c(3,92)))
{
  allWUData <- c()
  # ignore the values that are computed in excel
  ignoreUsers <- c('CALIFORNIA TOTALS COMPUTED', 'Nevada Totals COMPUTED',
                   'ARIZONA TOTALS COMPUTED')
  
  # need to add loop arround this, and edit sheetName and rowIndex for 
  # each state
  states <- c('AZ','CA','NV')
  sheetNames <- c('ART V(B) Arizona', 'ART V(B) California', 'ART V(B) Nevada')
  
  for(stateI in 1:length(states)){
    print(paste('Starting:',states[stateI]))
    flush.console()
    zz <- read.xlsx('src_data/LBDecreeAccounting//DecreeAccting_2000_2014.xlsx', 
                    sheetName = sheetNames[stateI], 
                    rowIndex = rowsToRead[stateI,1]:rowsToRead[stateI,2],
                    colIndex = 1:(length(yrs) + 2),
                    colClasses = c(rep('character',2),rep('numeric',length(yrs))))
    zz$WATER.USER <- as.character(zz$WATER.USER)
    # column 2 has no name. rename it variable. it will be diversion, meas. returns,
    # unmeas. returns, or consumptive use
    names(zz)[2] <- 'Variable'
    
    # rename the years to only numbers
    yrsC <- as.character(yrs)
    names(zz)[3:(3+length(yrs)-1)] <- yrsC
    
    # remove any rows that are all NA
    keepRows <- rep(TRUE,nrow(zz))
    for(i in 1:nrow(zz)){
      tmp <- as.character(zz[i,])
      #tmp[!(tmp == 'NA' | is.na(tmp) | trim(tmp) == '')] <- '1'
      tmp[tmp == 'NA' | is.na(tmp) | trim(tmp) == ''] <- '0'
      tmp[tmp != '0'] <- '1'
      #tmp <- as.numeric(tmp)
      # repeating to get rid of new NAs
      #tmp[is.na(tmp)] <- 0
      if(sum(as.numeric(tmp)) == 0) {
        keepRows[i] <- FALSE
      }
    }
    zz <- zz[keepRows,]
    
    # get the water user names. water users are those names that are in
    # water user column, and have a blank in the variable column
    waterUsers <- zz$WATER.USER[is.na(zz$Variable)]
    # remove the unnecessary water users
    waterUsers <- waterUsers[!(waterUsers %in% ignoreUsers)]
    wuInd <- which(zz$WATER.USER %in% waterUsers)
    
    # loop over each water user and aggregate diversion, meas and unmeas returns
    # and CU
    
    colInd <- 3:(2+length(yrs)) # column index for data
    for(i in 1:length(wuInd)){
      print(paste('Water User:',waterUsers[i]))
      flush.console()
      # look at rows from the current WU to the next WU minus 1
      if(i == length(wuInd)){
        rLast <- nrow(zz)
      } else {
        rLast <- wuInd[i+1] - 1
      }
      
      zzTmp <- zz[wuInd[i]:rLast,]
      zzData <- zzTmp[,colInd]
      #zzData <- as.numeric(zzData)
      zzData[is.na(zzData)] <- 0
      # sum all Diversions
      divRows <- which(trim(as.character(zzTmp$Variable)) == 'DIVERSION')
      if(length(divRows) == 0){
        totDiv <- rep(0,ncol(zzData))
      } else{ 
        totDiv <- apply(zzData[divRows,],2,sum)
      }
      
      # sum the measured returns with the unmeasured returns
      retRows <- c(which(trim(as.character(zzTmp$Variable)) == 'MEAS. RETURNS'),
                   which(trim(as.character(zzTmp$Variable)) == 'UNMEAS. RETURNS'))
      if(length(retRows) == 0){
        retFlow <- rep(0,ncol(zzData))
      } else{ 
        retFlow <- apply(zzData[retRows,],2,sum)
      }
      
      # sum consumptive use
      cuRows <- which(trim(as.character(zzTmp$Variable)) == 'CONSUMPTIVE USE')
      if(length(cuRows) == 0){
        cu <- rep(0,ncol(zzData))
      } else{ 
        cu <- apply(zzData[cuRows,],2,sum)
      }
      
      wuData <- data.frame('Year' = yrs, 'Diversion' = totDiv, 
                           'ReturnFlow' = retFlow, 'ConsumptiveUse' = cu)
      wuData <- melt(wuData, id.vars = 'Year', measure.vars = c('Diversion',
                                                                'ReturnFlow',
                                                                'ConsumptiveUse'),
                     variable.name = 'Variable',value.name = 'Value')
      wuData$WaterUser <- trim(waterUsers[i])
      wuData$State <- states[stateI]
      allWUData <- rbind(allWUData, wuData)
    }
  }
  allWUData$WaterUser <- as.factor(allWUData$WaterUser)
  write.csv(allWUData,'src_data/LBDecreeAccounting/DecreeData.csv', row.names = F)
}
