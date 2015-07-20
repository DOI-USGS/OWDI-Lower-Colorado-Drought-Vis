## Make sure we are starting in repository root

origin = getwd()
if(basename(origin) != 'OWDI-Lower-Colorado-Drought-Vis'){
	stop('Check your location, you should be at the root of the  OWDI-Lower-Colorado-Drought-Viz repo')
}

##Start running the update scripts for each figure. Run local=TRUE in an attempt 
##	to prevent scripts from stepping on each other's toes

# replaced this script with the followin build sVG script
# source('scripts/R/meadHistoricalAndProjection.R', local=TRUE)
source('scripts/R/build_mead_projected_svg.R', local = TRUE)

source('scripts/R/natural_flow_history.R', local=TRUE)

source('scripts/R/water_account.R', local=TRUE)

source('scripts/R/supply_vs_use_animation.R', local=TRUE)
