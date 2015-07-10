# Lower Basin Water Accounting Data
## Data Source and methods
The Bureau of Reclamation Lower Colorado River Water Accounting group produces annual Water Accounting Reports, which tabulate the measured diversions, measured returns, and consumptive use of each user taking water from the Lower Colorado River. The published reports are available [online](http://www.usbr.gov/lc/region/g4000/wtracct.html#decree) in pdf format. For this project, the [DecreeAccting_2000_2013_orig.xlsx](DecreeAccting_2000_2013_orig.xlsx) file was provided by the Water Accounting group. The Excel file was then manually edited to make processing easier and saved as [DecreeAccting_2000_2013.xlsx](DecreeAccting_2000_2013.xlsx). These changes are listed [below](#manual-changes-to-decreeaccting_2000_2013xlsx).

Finally, [reformatDecreeData](../../scripts/R/reformatDecreeData.R) was used to create the [DecreeData.csv](DecreeData.csv) file from [DecreeAccting_2000_2013.xlsx](DecreeAccting_2000_2013.xlsx).

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
  
## Mapping Users Between Decree and LC Contracts Shapefile

Notes for mapping the src_data/LCContractSvcAreas contracts to the users from the decree data spreadsheet and decree data csv:

* The "Boulder Canyon Project - Diversion at Hoover Dam" shows up as "Boulder Canyon Project" in the decree data and "Bureau of Reclamation" in the Shapefile.
* The "LOWER COLORADO RIVER DAMS PROJECT" user in the Decree data is the LCR Dams Project Diversion at Davis Dam. There does not appear to be any area in the shapefile to map to this user.
* The "PARKER DAM AND GOVERNMENT CAMP" user in the Decree data is the Reclamation and Government Camp diversion at Parker Dam. There deos not appear to be any area in the shapefile to map to this user.
* Cannot find any contractor in the shapefile that corresponds with "ALEC CAMILLE JR". If we are only using last 5-years of data, it's probably ok since that user is only non-zero in 2000-2005.
* Cannot find area in shapefile that corresponds with "MOHAVE GENERATING STATION (SO. CAL. EDISON)".  If we are only using the last 5-years of data, this is only a minor use (370 AF in 2010, 97 AF in 2011, and 0 AF in 2012-2014).
* "Union Pacific Railroad"" from the shapefile is mapped to "SOUTHERN PACIFIC COMPANY" from the decree as Union Pacific now owns Southern Pacific Company and the more recent decree reports list it as Union Pacific. 
* "YUMA PROJECT, RES. DIV. BARD UNIT" does not show up in shapefile. Could potentially combine with Fort Yuma Indian Reservation (CA) which is mapped to "YUMA PROJECT, RES. DIV. INDIAN UNIT"
* "BIG BEND CONSERVATION AREA" does not show up in the shapefile. This is a minor user (4 AF in 2011 and 3 AF in 2012).
* "YUMA AREA OFFICE, USBR" does not show up in shapefile. Uses are < 500 AF in the last 5 years.
