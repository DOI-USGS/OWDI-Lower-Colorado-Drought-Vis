Scripts
=======

This is a common scripts directory for any code that needs to be run for 
this visualization.  Individual sections may want to have scripts in a 
separate location alongside the source data, but anything that cuts 
across sections will find a home here.

### Important Notes

#### Working Directory

All scripts should assume they are starting with their working directory 
set to the root of the repository. 

#### run_all.R

To keep the website updated, scripts that update datasets and figures will 
be periodically run into the future. So we don't have to do this manually, 
an uber-script (`update_all.R`) will be called to initiate an update. 

### Data Source and methods

#### Maps

##### Basin Boundaries 
[water_account](R/water_account.R) is used to create the Colorado River Basin Boundary. For the Lower Basin, [lc_huc_simp-clean ](../src_data/CO_WBD/lc_huc_simp-clean.shp) is created from [LC_HUCs_wMexico_20140820](../src_data/CO_WBD/LC_UC_HUCs_wMexico_20140820.shp). This file was created as follows:
1. Started with 12-digit, 6th level HUCs from [NRCS](http://www.nrcs.usda.gov/wps/portal/nrcs/detail/national/water/watersheds/?cid=nrcs143_021630)
1. HU2 was selected to include Name = Lower Colorado Region and Name = Upper Colorado Region. 
1. From that remaining data set, HU4 was used to exclude Name = Sonora. 
1. From that remaining data set, HU10 was used to exclude HUC10 = 1503010805 and HUC10 = 1503010806 (which is the most south-easterly portion of HU4, Name = Lower Colorado)
See [LC_HUCs_wMexico_20140820.shp.xml](../src_data/CO_WBD/LC_UC_HUCs_wMexico_20140820.shp.xml) for more details.

For the Upper Basin boundary, the Upper Colorado Region from the [NRCS HUC data](http://www.nrcs.usda.gov/wps/portal/nrcs/detail/national/water/watersheds/?cid=nrcs143_021630) was used.

##### Lower Colorado River Contract Service Area

The service areas for Lower Colorado contractors were provided by Reclamation's [Water Administration Group](http://www.usbr.gov/lc/region/g4000/contracts/entitlements.html). These data are considered **provisional** by Reclamation. 

[LC_Contracts_update2014](../src_data/LCContractSvcAreas) contain the contract service Areas for water contracts in the Lower Colorado Region. This database was developed based on the exisitng water contracts between Reclamation and the individual water users on the River. The Service Areas of present perfected rights are also included in this database.

[water_account](R/water_account.R) use these boundaries to depict where use is occuring in the Lower Basin.

***Still Need Documentation*** 
* LowerCO
* WBDHU2
* WBDHU4
* Rivers
* Others?

#### Natural Flow Data

##### Observed

The observed natural flow data are a computed data set maintained by [Reclamtion](http://www.usbr.gov/lc/region/g4000/NaturalFlow/current.html). The natural flow at Lees Ferry represents the total flow originating in the Upper Basin, while the natural flow at Imperial represents the total flow in the Colorado River Basin. 

[NaturalFlows.csv](../src_data/NaturalFlow.csv) contains the total annual natural flow at Lees Ferry and Imperial, which is a subset of the [posted data](http://www.usbr.gov/lc/region/g4000/NaturalFlow/current.html) available from Reclamation.

[natural_flow_history](R/natural_flow_history.R) uses the natural flow at Lees Ferry to compare to the Paleo reconstructed natural flows in the "Colorado River Natural Flow at Lees Ferry, AZ" figure.

[supply_vs_use_animation](R/supply_vs_use_animation.R) uses the natural flow at Imperial to compare to the total Basin use in the "Water supply and consumptive use in the Colorado River Basin" figure.

##### Paleo

The paleo reconstructed natural flow at Lees Ferry data are available and documented from NOAA at [http://www.ncdc.noaa.gov/paleo/pubs/meko2007/meko2007.html](http://www.ncdc.noaa.gov/paleo/pubs/meko2007/meko2007.html).

[natural_flow_history](R/natural_flow_history.R) uses paleo reconstructed natural flow at Lees Ferry to compare to observed natural flows in the "Colorado River Natural Flow at Lees Ferry, AZ" figure.

#### Water Use Data

##### Basin-wide Historical Use

The Basin-wide historical use data are used in the "Water supply and consumptive use in the Coloardo River Basin" figure. These data were compiled for the Colorado River Basin Water Supply and Demand Study and are documented in [Technical Report C](http://www.usbr.gov/lc/region/programs/crbstudy/finalreport/techrptC.html). Source data include the [Lower Basin Decree Accounting Reports](http://www.usbr.gov/lc/region/g4000/wtracct.html#decree), [Upper Basin Consumptive Uses and Losses Reports](http://www.usbr.gov/uc/library/envdocs/reports/crs/crsul.html), and [Microfiche records](http://www.usbr.gov/lc/region/g4000/NaturalFlow/supportNF.html).

Source data from the Basin Study were obtained from Reclamation ([BasinStudy_TR-C_HistoricalDataDump_Provisional.csv](../src_data/BasinStudy_TR-C_HistoricalDataDump_Provisional.csv)). [reform_usage_data](reform_usage_data.R) is used to aggregate the source data into the total use (Upper Basin, Lower Basin, and Mexico) for each year and creates [Basin_Depletion_yearly_PROVISIONAL.tsv](../src_data/Basin_Depletion_yearly_PROVISIONAL.tsv). [supply_vs_use_animation](R/supply_vs_use_animation.R) uses the Basin_Depletion_yearly_PROVISIONAL.tsv file to create the  "Water supply and consumptive use in the Coloardo River Basin" figure.

##### Lower Basin Water Accounting Data

The Bureau of Reclamation Lower Colorado River Water Accounting group produces annual Water Accounting Reports, which tabulate the measured diversions, measured returns, and consumptive use of each user taking water from the Lower Colorado River. The published reports are available [online](http://www.usbr.gov/lc/region/g4000/wtracct.html#decree) in pdf format. For this project, the [DecreeAccting_2000_2013_orig.xlsx](../src_data/LBDecreeAccounting/DecreeAccting_2000_2013_orig.xlsx) file was provided by the Water Accounting group. The Excel file was then manually edited to make processing easier and saved as [DecreeAccting_2000_2013.xlsx](../src_data/LBDecreeAccounting/DecreeAccting_2000_2013.xlsx). These changes are documented [here](../src_data/LBDecreeAccounting/).

Finally, [reformatDecreeData](R/reformatDecreeData.R) was used to create the [DecreeData.csv](../src_data/LBDecreeAccounting/DecreeData.csv) file from [DecreeAccting_2000_2013.xlsx](../src_data/LBDecreeAccounting/DecreeAccting_2000_2013.xlsx).
