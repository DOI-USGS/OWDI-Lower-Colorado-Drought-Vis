# arrange and aggregate LC Decree Acct. Data
library(xlsx)
library(reshape2)
library(dplyr)

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

# rowsToRead default to the rows in the AZ, CA, and NV worksheets that contain the data
# we need. 
reformatLBDec <- function(yrs = 2000:2014, rowsToRead = rbind(c(4,274),c(3,108),c(3,92)))
{
  allWUData <- c()
  # ignore the values that are computed in excel
  ignoreUsers <- c('CALIFORNIA TOTALS COMPUTED', 'Nevada Totals COMPUTED',
                   'ARIZONA TOTALS COMPUTED')
  
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
    colInd <- 3:(2+length(yrs)) # column index for data
    
    if(states[stateI] == 'CA'){
      # break out the Yuma Project Reservation Division consumptive use (CU) into CU
      # for the Bard Unit, and CU for the Indian Unit (Ft Yuma Reservation). Do this 
      # by splitting the "Unassigned returns from Yuma Project, Reservation Unit" into
      # a Bard Unit and a Indian Unit portion. The split is computed on a pro-rated basis
      # based on the Indian (Bard) Units diversion as a percent of the total yuma project
      # diversion
      
      # Indian Unit data
      i <- which(waterUsers == 'YUMA PROJECT, RES. DIV. INDIAN UNIT')
      iu <- zz[wuInd[i]:(wuInd[i+1]-1),] 
      iu[,2] <- trim(as.character(iu[,2]))
      iu[,3:ncol(iu)] <- apply(iu[,3:ncol(iu)],2,as.numeric)
      # Bard Unit data
      i <- which(waterUsers == 'YUMA PROJECT, RES. DIV. BARD UNIT')
      bu <- zz[wuInd[i]:(wuInd[i+1]-1),] 
      bu[,2] <- trim(as.character(bu[,2]))
      bu[,3:ncol(iu)] <- apply(bu[,3:ncol(iu)],2,as.numeric)
      # compute the total diversion for indian unit, and for the total reservation division
      tv <- data.frame(matrix(apply(iu[which(iu[,2]=='DIVERSION'),colInd],2,sum, na.rm = T),nrow = 1))
      tv <- cbind(data.frame(matrix(c('','Total Diversion'),nrow=1)),tv)
      names(tv) <- names(iu)
      iu <- rbind(iu,tv)
      totDiv <- as.numeric(iu[which(iu[,2] == 'Total Diversion'),colInd]) + bu[which(bu[,2] == 'DIVERSION'),colInd]
      # split the unassigned measured return flows into different units by computing unit div/
      # total diversion times the unassigned returns
      umr <- bu[which(bu[,1]=='UNASSIGNED RETURNS FROM YUMA PROJECT, RESERVATION DIVISION'),colInd]
      umr.iu <- umr * iu[which(iu[,2] == 'Total Diversion'),colInd]/totDiv
      umr.bu <- umr * bu[which(bu[,2] == 'DIVERSION'),colInd]/totDiv
      # add the proportional unassigned measured returns into the measured returns for each unit
      i <- which(iu[,2] == 'MEAS. RETURNS')
      iu[i,colInd] <- iu[i,colInd] + umr.iu
      i <- which(bu[,2] == 'MEAS. RETURNS')[1] # first entry is Bard Unit by itself.
      bu[i,colInd] <- bu[i,colInd] + umr.bu
      # compute the consumptive use for each unit
      i1 <- which(iu[,2] == 'CONSUMPTIVE USE')
      i2 <- which(iu[,2] == 'Total Diversion')
      i3 <- which(iu[,2] == 'MEAS. RETURNS')
      i4 <- which(iu[,2] == 'UNMEAS. RETURNS')
      # make sure na is = 0
      r0 <- iu[,colInd]
      r0[is.na(r0)] <- 0
      iu[,colInd] <- r0
      iu[i1,colInd] <- iu[i2,colInd] - iu[i3,colInd] - iu[i4,colInd]
      i1 <- which(bu[,2] == 'CONSUMPTIVE USE')[1] # the first entry is Bard by itself
      i2 <- which(bu[,2] == 'DIVERSION')
      i3 <- which(bu[,2] == 'MEAS. RETURNS')[1] # the first entry is Bard by itself
      i4 <- which(bu[,2] == 'UNMEAS. RETURNS')
      r0 <- bu[,colInd]
      r0[is.na(r0)] <- 0
      bu[,colInd] <- r0
      bu[i1,colInd] <- bu[i2,colInd] - bu[i3,colInd] - bu[i4,colInd]
      # remove the total diversion I added in
      iu <- iu[-c(which(iu[,2] == 'Total Diversion')),]
      # zero out the total meas. returns and total cu that shows up under the bard unit so that
      # when it is aggregated below, it does not get double counted
      bu[which(bu[,1] == 'UNASSIGNED RETURNS FROM YUMA PROJECT, RESERVATION DIVISION'),colInd] <- 0
      bu[which(bu[,1] == 'SUM, YUMA PROJECTS, RES. DIV. USE'),colInd] <- 0
      # Rename the indian Unit to FORT YUMA INDIAN RESERVATION so that it matches and will
      # sum with the AZ portion.
      iu[1,1] <- 'FORT YUMA INDIAN RESERVATION'
      # replace the original data with the computed data from this section
      i <- which(waterUsers == 'YUMA PROJECT, RES. DIV. INDIAN UNIT')
      zz[wuInd[i]:(wuInd[i+1]-1),] <- iu
      # Bard Unit data
      i <- which(waterUsers == 'YUMA PROJECT, RES. DIV. BARD UNIT')
      zz[wuInd[i]:(wuInd[i+1]-1),] <- bu
    }
    # loop over each water user and aggregate diversion, meas and unmeas returns
    # and CU
    
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
  
  
  # remove users that have 0 diversion and 0 consumptive use for all years
  remUsers <- allWUData %>%
    dplyr::group_by(Variable, WaterUser, State) %>%
    dplyr::summarise(Tot = sum(Value)) %>%
    dplyr::filter((Tot == 0 & Variable == 'ConsumptiveUse') | (Tot == 0 & Variable == 'Diversion'))
  r1 <- remUsers %>%
    dplyr::filter(Variable == 'ConsumptiveUse') %>%
    dplyr::select(WaterUser)
  r2 <- remUsers %>%
    dplyr::filter(Variable == 'Diversion') %>%
    dplyr::select(WaterUser)
  remUsers <- r1 %>% dplyr::select(WaterUser) %>%
    dplyr::filter(WaterUser %in% r2$WaterUser)
  allWUData <- allWUData %>%
    dplyr::filter(!(WaterUser %in% remUsers$WaterUser))
  
  # add in the ContractorID field (unique ID to map use data with contractor service area polygons)
  cmap <- read.csv('src_data/LBDecreeAccounting/ContractorMap.csv')
  cmap <- dplyr::select(cmap, OBJECTID_1, Contractor.Decree) %>%
    dplyr::filter(Contractor.Decree != '') 
  allWUData <- dplyr::full_join(allWUData, cmap, by = c("WaterUser" = "Contractor.Decree"))
  allWUData <- dplyr::rename(allWUData, ContractorID = OBJECTID_1)
  
  allWUData$WaterUser <- as.factor(allWUData$WaterUser)
  
  write.csv(allWUData,'src_data/LBDecreeAccounting/DecreeData.csv', row.names = F)
}
