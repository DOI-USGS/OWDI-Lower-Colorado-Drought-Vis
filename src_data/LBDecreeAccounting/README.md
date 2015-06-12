# Lower Basin Water Accounting Data
## Data Source and methods
The Bureau of Reclamation Lower Colorado River Water Accounting group produces annual Water Accounting Reports, which tabulate the measured diversions, measured returns, and consumptive use of each user taking water from the Lower Colorado River. The published reports are available [online](http://www.usbr.gov/lc/region/g4000/wtracct.html#decree) in pdf format. For this project, the [DecreeAccting_2000_2013_orig.xlsx](DecreeAccting_2000_2013_orig.xlsx) file was provided by the Water Accounting group. The Excel file was then manually edited to make processing easier and saved as [DecreeAccting_2000_2013.xlsx](DecreeAccting_2000_2013.xlsx). These changes are listed [below](#manual-changes-to-decreeaccting_2000_2013xlsx).

Finally, [reformatDecreeData](../../scripts/R/reformatDecreeData.R) was used to create the [DecreeData.csv](DecreeData.csv) file from [DecreeAccting_2000_2013.xlsx](DecreeAccting_2000_2013.xlsx).

## Manual Changes to DecreeAccting_2000_2013.xlsx
* For WATER EXCHANGED WITH SDCWA, changed 'CA CONSUMPTIVE USE' to 'CONSUMPTIVE USE'
* Filled in IID Consumptive Use for 2011-2013
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
  