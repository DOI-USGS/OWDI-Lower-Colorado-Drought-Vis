#Source Data
===========
This directory contains un-modified source data and intermediate datasets. Each directory has a README.md file that includes data source and method information. Files within this src_data directory are described below.





*[BasinStudy_TR-C_HistoricalDataDump_Provisional.csv](../../src_data/BasinStudy_TR-C_HistoricalDataDump_Provisional.csv) is used to create  [Basin_Depletion_yearly_PROVISIONAL.tsv](../../src_data/Basin_Depletion_yearly_PROVISIONAL.tsv). 

*[full_text.en.xml](../../src_data/full_text.en.xml) contains the application text in English.
*[full_text.es.xml](../../src_data/full_text.es.xml) will contain the application text in Spanish (incomplete as of 12/15/2015).

*[Mead24MSResults.csv](../../src_data/Mead24MSResults.csv) contains the current version of end of month Lake Mead elevation projections, and is used in Lake Mead Projection svg figure. Data source: BOR. 

*[MeadHistorical.csv](../../src_data/MeadHistorical.csv) contains the historical end of month Lake Mead elevation, and is used in Lake Mead Projection svg figure. Data source: BOR. 

*The tree ring reconstruction figure and the historical flow figure use BOR natural flow data (A. Butler) from 2007-2012 from the [NaturalFlow.csv](../../src_data/NaturalFlow.csv) file. 

*[upper-colorado-flow2007.txt](../../src_data/upper-colorado-flow2007.txt) is used for the tree ring reconstruction figure. Attribution is as follows: Meko, D.M., et al. 2007. Upper Colorado River Flow Reconstruction. IGBP PAGES/World Data Center for Paleoclimatology. Data Contribution Series # 2007-052. NOAA/NCDC Paleoclimatology Program, Boulder CO, USA.

*[flow10yrProcessed.csv](../../src_data/flow10yrProcessed.csv) is tree ring-reconstructed flow data sourced from [upper-colorado-flow2007.txt](../../src_data/upper-colorado-flow2007.txt) and [NaturalFlow.csv](../../src_data/NaturalFlow.csv) by the scripts/R/economist_fig_flow_history.R script. 






