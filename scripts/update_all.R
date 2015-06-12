## Make sure we are starting in repository root

origin = getwd()
if(basename(origin) != 'OWDI-Lower-Colorado-Drought-Vis'){
	stop('Check your location, you should be at the root of the  OWDI-Lower-Colorado-Drought-Viz repo')
}


source('scripts/R/meadHistoricalAndProjection.R', local=TRUE)


source('scripts/R/natural_flow_history.R', local=TRUE)

source('scripts/R/water_account.R', local=TRUE)


