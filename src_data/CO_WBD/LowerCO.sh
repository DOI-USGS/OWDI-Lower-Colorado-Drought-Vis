#!/bin/bash

OUTFILE=LowerCO.json

if [[ -e $OUTFILE ]]; then
	rm $OUTFILE
fi

ogr2ogr -f "GeoJSON" $OUTFILE WBDHU2.shp -where "HUC2='14' OR HUC2='15'" -simplify 0.002
