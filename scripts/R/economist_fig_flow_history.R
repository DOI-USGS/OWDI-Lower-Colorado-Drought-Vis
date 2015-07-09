
library(dplyr)

# Experiment with historical flow data
flow_file <- 'src_data/upper-colorado-flow2007.txt'
flow_data = read.table(flow_file, header=TRUE, skip=173)

running_mean <- function(x,n=15,sides=1) {
	stats::filter(x, rep(1/n,n), sides=1) %>% as.numeric()
}

flow_df = mutate(flow_data, TreeRings=RecBCM, TreeRingsLwr=TreeRings-RMSE_BCM, TreeRingsUpr=TreeRings+RMSE_BCM) %>%
	# these come in billion cubic meter (/yr); convert to millions of acre feet
	# (/yr). 1233.48184 cubic meters per acre feet, 1000 million per billion,
	# means (1000 million acre feet)/(1233.48184 billion cubic meters) = 0.8107132
	mutate(TreeRings=TreeRings*0.8107132, TreeRingsLwr=TreeRingsLwr*0.8107132, TreeRingsUpr=TreeRingsUpr*0.8107132) %>%
	# could compute running averages here: 
	# mutate(TreeRings15YrRunMean = running_mean(TreeRings), TreeRingsAllYrMean = mean(TreeRings)) %>%
	select(Year, TreeRings, TreeRingsLwr, TreeRingsUpr) #TreeRings15YrRunMean, TreeRingsAllYrMean)

# add more recent flow data (up to 2014)
flow_file_recent <- 'src_data/NaturalFlow.csv'
flow_df <- flow_df %>% full_join(
	read.csv(flow_file_recent) %>% 
		# these come in acre feet; convert to million acre feet
		mutate(FlowGage=Natural.Flow.above.Lees.Ferry/1000000) %>%
		select(Year, FlowGage), by="Year")

# compute running means on the average of TreeRings and FlowGage (or just one, when only one is available)
# flow_df <- flow_df %>%
# 	mutate(MeanTreeGage = rowMeans(cbind(TreeRings, FlowGage), na.rm=TRUE),
# 				 TreeGage15YrRunMean = running_mean(MeanTreeGage),
# 				 TreeGageAllYrMean = mean(MeanTreeGage),
# 				 Min15YrMean = min(TreeGage15YrRunMean, na.rm=TRUE)) %>%
# 	select(-MeanTreeGage)


# compute running means on just the FlowGage data 
flow_df <- flow_df %>%
	mutate(TreeGage15YrRunMean = running_mean(FlowGage),
				 TreeGageAllYrMean = mean(FlowGage, na.rm=TRUE),
				 Min15YrMean = min(TreeGage15YrRunMean, na.rm=TRUE)) 



flow_df$below_mean = flow_df$TreeGage15YrRunMean < flow_df$TreeGageAllYrMean
flow_df$drought_length = (flow_df$below_mean) * unlist(lapply(rle(flow_df$below_mean)$lengths, seq_len))
flow_df$TreeGage15yrPct = 100*flow_df$TreeGage15YrRunMean/flow_df$TreeGageAllYrMean

to_write = select(flow_df, Year, TreeGage15yrPct, below_mean, drought_length)
to_write = na.omit(to_write)

write.csv(to_write, 'src_data/treeringFlow15yrProcessed.csv', row.names=FALSE)


## make examplefigure
png('~/economist_flow_fig.png', width=2100, height=1500, res=300)
plot(c(1900, 2010),c(NA,NA), ylim=c(80, 120), xlab='Year', ylab='Percent of Mean')

flow_df = subset(flow_df, Year >= 1900)

col = rgb(0.5,0.5,0.5,0.5)
cutoff = 10  #10 year drought duration cutoff

for(i in 1:nrow(flow_df)){
	if(!is.na(flow_df$drought_length[i]) && flow_df$drought_length[i] > cutoff){
		if(i+1 <=nrow(flow_df) && flow_df$drought_length[i+1] > 0){next}
		
		rect(xleft=flow_df$Year[i]-flow_df$drought_length[i], xright=flow_df$Year[i], ytop=200, ybottom=0, col=col, border=col)
	}
}

lines(flow_df$Year, 100*flow_df$TreeGage15YrRunMean/flow_df$TreeGageAllYrMean, type='l')
#plot(TreeRings~Year, flow_df, type='l')
abline(h=100)

pre_drought = subset(flow_df, Year <= 2000)
min20th_century = min(100*pre_drought$TreeGage15YrRunMean/pre_drought$TreeGageAllYrMean)

abline(h=min20th_century, col='red')

dev.off()
