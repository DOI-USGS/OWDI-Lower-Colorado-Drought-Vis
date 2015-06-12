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





