# Lower Basin Water Accounting Data
## Data Source and methods
The Bureau of Reclamation Lower Colorado River Water Accounting group produces annual Water Accounting Reports, which tabulate the measured diversions, measured returns, and consumptive use of each user taking water from the Lower Colorado River. The published reports are available [online](http://www.usbr.gov/lc/region/g4000/wtracct.html#decree) in pdf format. For this project, the [DecreeAccting_2000_2013_orig.xlsx](DecreeAccting_2000_2013_orig.xlsx) file was provided by the BOR Water Accounting group. The Excel file was then manually edited to make processing easier and saved as [DecreeAccting_2000_2014.xlsx](DecreeAccting_2000_2014.xlsx). These changes are listed [below](#manual-changes-to-decreeaccting_2000_2013xlsx).

Finally, [reformatDecreeData](../../scripts/R/reformatDecreeData.R) was used to create the [DecreeData.csv](DecreeData.csv) file from [DecreeAccting_2000_2014.xlsx](DecreeAccting_2000_2014.xlsx).

## Manual Changes to DecreeAccting_2000_2013.xlsx
* For WATER EXCHANGED WITH SDCWA:
  * changed 'CA CONSUMPTIVE USE' to 'CONSUMPTIVE USE'
  * Moved the "Water Exchanged with SDCWA" up one row so code read's it as an individual user
* Filled in IID Consumptive Use for 2011-2014
  * Computed As Total Consumptive Use minus Consumptive Use as delivery from Brock.
* For Chemehuevi Indian Reservation, set the 2000-2002 Consumptive Use equal to the Diversion.
* For CITY OF WINTERHAVEN, set the 2000-2002 Consumptive Useequal to the Diversion.
* For OTHER USERS PUMPING FROM COLORADO, set the 2000-2002 Consumptive Useequal to the Diversion.
* For LAKE MEAD NAT'L RECREATION, AZ. and LAKE MEAD NAT'L RECREATION, AZ.,MOHAVE WATER CONSERVATION DIST., BROOKE WATER LLC. Aka Consolidated Utilities, Graham Utilities Inc. and Holiday Harbor,MOHAVE VALLEY I.D.D., GOLDEN SHORES WATER CONSERVATION DIST, LAKE HAVASU I.D.D.  (CITY),CENTRAL ARIZONA PROJECT, EHRENBURG IMPROVEMENT ASSN., CIBOLA VALLEY IRRIGATION DISTRICT,CIBOLA NATIONAL WILDLIFE REFUGE, IMPERIAL NATIONAL WILDLIFE REFUGE,SOUTHERN PACIFIC COMPANY, YUMA MESA FRUIT GROWERS ASSN.,UNIVERSITY OF ARIZONA, YUMA UNION HIGH SCHOOL, DESERT LAWN MEMORIAL,ALEC CAMILLE JR, OTHER USERS PUMPING FROM THE COLORADO, set the 2000-2002 Consumptive Use equal to the Diversion.
* Edited MOHAVE COUNTY WATER AUTHORITY under Cibola Valley IDD to say MOHAVE COUNTY WATER AUTHORITY (CVIDD) so that can distinguish this from the MOHAVE COUNTY WATER AUTHORITY main user that only has data in 2013
  * same with Hopi, AZ Game and Fish, and az recreational facilities.
* Moved the "Nevada Totals COMPUTED" label up one row.
* Moved LAS VEGAS WASH RETURN FLOWS, "RETURNS", to be line item under
  * changed "RETURNS" to "MEAS. RETURNS"
  * changed Robert G. Griffith Consumptive Use to be equal to Diversion at Saddle Island minus the Las Vegas Wash Return Flows.
* combined row 70 and 71 "unassigned returns from Yuma Project" in CA user to be on the same line
* Removed the small water users and injected storage from the NV sheet.
* IID includes water exchanged w/SDCWA for Salt Sea Mitigation
  * this may necessitate a note if IID water use is shown on any figures.
* For the Yuma Project, Reservation Division, consumptive use is normally reported as a total for the Reservation Division, while diversions are reported for the Indian Unit and Bard Unit seperately. For the purpose of this visualization, it was desirable to show the consumptive use for the Indian Unit and the Bard Unit seperately. It was assumed that the UNASSIGNED RETURNS FROM YUMA PROJECT, RESERVATION DIVISION Measured Returns could be proportional split to the Indian and Bard Units based on each units diversion to total Reservation Dvision diversion. 
  * In the California Users, YUMA PROJECT, RES. DIV. INDIAN UNIT was renamed FORT YUMA INDIAN RESERVATION so that the Fort Yuma Indian Reservation uses would be their total use in Arizona and California.
  
## Mapping Users Between Decree and LC Contracts Shapefile

Notes for mapping the src_data/LCContractSvcAreas contracts to the users from the decree data spreadsheet and decree data csv:

* The "Boulder Canyon Project - Diversion at Hoover Dam" shows up as "Boulder Canyon Project" in the decree data and "Bureau of Reclamation" in the Shapefile.
* The "PARKER DAM AND GOVERNMENT CAMP" user in the Decree data is the Reclamation and Government Camp diversion at Parker Dam. There deos not appear to be any area in the shapefile to map to this user.
* "ALEC CAMILLE JR" was previously "Yuma Mesa Grapefruit Company"
* "MOHAVE GENERATING STATION (SO. CAL. EDISON)" does not show up in the shapefile and will not be added as it no longer uses water.
* "Union Pacific Railroad"" from the shapefile is mapped to "SOUTHERN PACIFIC COMPANY" from the decree as Union Pacific now owns Southern Pacific Company and the more recent decree reports list it as Union Pacific. 
* "YUMA AREA OFFICE, USBR" does not show up in shapefile. 
* The following users do not show up in the current shapefile, but will by mid-July 2015:
  * "YUMA PROJECT, RES. DIV. BARD UNIT"
  * LOWER COLORADO RIVER DAMS PROJECT
  * BIG BEND CONSERVATION AREA

