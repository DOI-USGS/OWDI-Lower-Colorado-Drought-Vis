
library(dplyr)

# Experiment with historical flow data
flow_file <- 'src_data/upper-colorado-flow2007.txt'
flow_data = read.table(flow_file, header=TRUE, skip=173)

running_mean <- function(x,n=10,sides=1) {
	stats::filter(x, rep(1/n,n), sides=1) %>% as.numeric()
}

perc.rank <- function(x) 100*trunc(rank(x))/length(x)

flow_df = mutate(flow_data, TreeRings=RecBCM, TreeRingsLwr=TreeRings-RMSE_BCM, TreeRingsUpr=TreeRings+RMSE_BCM) %>%
	# these come in billion cubic meter (/yr); convert to millions of acre feet
	# (/yr). 1233.48184 cubic meters per acre feet, 1000 million per billion,
	# means (1000 million acre feet)/(1233.48184 billion cubic meters) = 0.8107132
	mutate(TreeRings=TreeRings*0.8107132, TreeRingsLwr=TreeRingsLwr*0.8107132, TreeRingsUpr=TreeRingsUpr*0.8107132) %>%
	# could compute running averages here: 
	# mutate(TreeRings16YrRunMean = running_mean(TreeRings), TreeRingsAllYrMean = mean(TreeRings)) %>%
	select(Year, TreeRings, TreeRingsLwr, TreeRingsUpr) #TreeRings16YrRunMean, TreeRingsAllYrMean)

# add more recent flow data (up to 2014)
flow_file_recent <- 'src_data/NaturalFlow.csv'
flow_natural <- read.csv(flow_file_recent)

flow_df <- flow_df %>% full_join(
	 flow_natural %>% 
		# these come in acre feet; convert to million acre feet
		mutate(FlowGage=Natural.Flow.above.Lees.Ferry/1000000) %>%
		select(Year, FlowGage), by="Year")

flow_df <- flow_natural %>% 
	# these come in acre feet; convert to million acre feet
	mutate(FlowGage=Natural.Flow.above.Lees.Ferry/1000000) %>%
	select(Year, FlowGage)

# compute running means on the average of TreeRings and FlowGage (or just one, when only one is available)
# flow_df <- flow_df %>%
# 	mutate(MeanTreeGage = rowMeans(cbind(TreeRings, FlowGage), na.rm=TRUE),
# 				 TreeGage16YrRunMean = running_mean(MeanTreeGage),
# 				 TreeGageAllYrMean = mean(MeanTreeGage),
# 				 Min16YrMean = min(TreeGage16YrRunMean, na.rm=TRUE)) %>%
# 	select(-MeanTreeGage)


#Create a vector of merged flow gage and tree ring data. Select flow gage data preferrentially
#flow_df$GageTreeData = apply(flow_df[,c('FlowGage', 'TreeRings')], 1, function(df){ifelse(!is.na(df[1]), df[1], df[2])})
#calculate percentiles for the whole timeseries
historical_pctile <- flow_df %>%
	transmute(Year=Year, HistoricalPercentile = perc.rank(running_mean(FlowGage)))


# compute running means on just the FlowGage data 
flow_df <- flow_df %>%
	mutate(Gage10YrRunMean = running_mean(FlowGage),
				 GageAllYrMean = mean(FlowGage, na.rm=TRUE),
				 Min10YrMean = min(Gage10YrRunMean, na.rm=TRUE)) 



flow_df$below_mean = flow_df$Gage10YrRunMean < flow_df$GageAllYrMean
flow_df$drought_length = (flow_df$below_mean) * unlist(lapply(rle(flow_df$below_mean)$lengths, seq_len))

flow_df$Gage10yrPct = 100*flow_df$GageAllYrMean

flow_df$RawGagePct = 100*flow_df$FlowGage/flow_df$GageAllYrMean

to_write = select(flow_df, Year, Gage10YrRunMean, FlowGage, below_mean, drought_length)
to_write = subset(to_write, Year >= 1906)

to_write = merge(to_write, historical_pctile)

write.csv(to_write, 'src_data/flow10yrProcessed.csv', row.names=FALSE)

