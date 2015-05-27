#!/bin/bash

# Steps leading up to running this script (commented out due to expense)
# wget ftp://rockyftp.cr.usgs.gov/vdelivery/Datasets/Staged/WBD/Shape/WBD_National.zip
# unzip WBD_National.zip

OUTFILE=LowerCO.json

if [[ -e $OUTFILE ]]; then
	rm $OUTFILE
fi

ogr2ogr -f "GeoJSON" $OUTFILE WBDHU2.shp -where "HUC2='14' OR HUC2='15'" -simplify 0.002
