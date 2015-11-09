$(document).ready(function() {
	"use strict";
	window.owdiDrought = window.owdiDrought || {};
	window.owdiDrought.waterAccounting = {};

	owdiDrought.waterAccounting.map = L.map('map');

	owdiDrought.waterAccounting.group = new L.featureGroup;

	// data layers
	owdiDrought.waterAccounting.layers = {}

	owdiDrought.waterAccounting.styles = {
		watershed: {
			"fillOpacity": 0.55,
			"color": "#9d9d9d",
			"weight": 2,
			"fillColor": "#9d9d9d"
		},
		hucStyle: function(feature) {
			return {
				weight: 2,
				color: 'white',
				dashArray: '3',
				fillOpacity: 0.4,
				fillColor: owdiDrought.waterAccounting.getColor(feature.properties.FiveYrAvg_)
			};
		}
	}

	owdiDrought.waterAccounting.resetHighlight = function(e) {
		owdiDrought.waterAccounting.geojson.resetStyle(e.target);
		owdiDrought.waterAccounting.info.update();
	}

	owdiDrought.waterAccounting.zoomToFeature = function(e) {
		owdiDrought.waterAccounting.map.fitBounds(e.target.getBounds());
	}

	owdiDrought.waterAccounting.onEachFeature = function(feature, layer) {
		layer.on({
			mouseover: owdiDrought.waterAccounting.highlightFeature,
			mouseout: owdiDrought.waterAccounting.resetHighlight,
			click: owdiDrought.waterAccounting.zoomToFeature
		});
	}

	// get color depending on five year mean value
	owdiDrought.waterAccounting.getColor = function(d) {
		var color;

		if (d > 2500000) {
			color = "#3c4dfd";
		} else if (d > 400000) {
			color = "#6f7bfe";
		} else if (d > 600) {
			color = "#a1a9fe";
		} else if (d > 120) {
			color = "#d4d7ff"
		} else {
			color = "#eeefff"
		}

		return color;
	}

	owdiDrought.waterAccounting.highlightFeature = function(e) {
		var layer = e.target;

		layer.setStyle({
			weight: 5,
			color: '#FFFF00',
			dashArray: '',
			fillOpacity: 0.7
		});

		if (!L.Browser.ie && !L.Browser.opera) {
			layer.bringToFront();
		}

		owdiDrought.waterAccounting.info.update(layer.feature.properties);
	}

	owdiDrought.waterAccounting.getValue = function(x) {
		var value;

		if (x > 2500000) {
			value = 0;
		} else if (x >= 400000) {
			value = 33;
		} else if (x >= 600) {
			value = 20;
		} else if (x >= 120) {
			value = 7;
		} else {
			value = 0;
		}
		return value;
	}
	
	function numberWithCommas(x) {
		
		return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}
	
	// Info control
	owdiDrought.waterAccounting.info = L.control();
	owdiDrought.waterAccounting.info.onAdd = function(map) {
		this._div = L.DomUtil.create('div', 'info');
		this.update();
		return this._div;
	};
	owdiDrought.waterAccounting.info.update = function(props) {
		this._div.innerHTML = '<h2>Information on Lower Colorado River Water Entitlement Holders</h2>' + (props ?
			'<b>' + props.Contractor + '</b><br />' + numberWithCommas(Math.round(props.FiveYrAvg_)) + ' acre feet' : 'Hover over a district');
	};
	owdiDrought.waterAccounting.info.addTo(owdiDrought.waterAccounting.map);

	// Legend
	owdiDrought.waterAccounting.legend = L.control({
		position: 'bottomright'
	});
	owdiDrought.waterAccounting.legend.onAdd = function(map) {
		var div = L.DomUtil.create('div', 'info legend'),
			gradeLabels = ["0", "120", "600", "400,000", "2,500,000"],
			grades = [0, 120, 600, 400000, 2500000],
			labels = ["<h4>Five Year Average (2010-2014)</h4><br/><b>Acre Feet</b><br /><em>Shaded areas on map represent District boundaries,<br/> not water use locations.</em>"],
			from, to;

		for (var i = 0; i < grades.length; i++) {
			from = gradeLabels[i];
			to = gradeLabels[i + 1];

		labels.push(
				'<i style="background:' + owdiDrought.waterAccounting.getColor(grades[i] + 1) + '"></i> ' +
				from + (to ? '&ndash;' + to : '+'));
		}
		labels.push(
			'<br/><i style="background:' + '#9d9d9d' + '"></i>Colorado River Basin<br/><br/><a href="http://www.usbr.gov/lc/region/g4000/wtracct.html#Decree" target="_blank">Review Water Accounting Reports 1964-Present</a>');

		div.innerHTML = labels.join('<br>');
		return div;
	};
	owdiDrought.waterAccounting.legend.addTo(owdiDrought.waterAccounting.map);

	// scale bar
	L.control.scale().addTo(owdiDrought.waterAccounting.map);

	// base layers
	owdiDrought.waterAccounting.basemaps = {
		"OpenStreetMap": L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
			"attribution": "&copy; <a href=\"http://openstreetmap.org/copyright\", target=\"_blank\">OpenStreetMap contributors</a>"
		}),
		"ESRI World Topo": L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}', {
			"attribution": "Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ, TomTom, Intermap, iPC, \n    USGS, FAO, NPS, NRCAN, GeoBase, Kadaster NL, Ordnance Survey, Esri Japan, METI, \n    Esri China (Hong Kong), and the GIS User Community"
		})
	};
	owdiDrought.waterAccounting.basemaps.OpenStreetMap.addTo(owdiDrought.waterAccounting.map);
	owdiDrought.waterAccounting.basemaps["ESRI World Topo"].addTo(owdiDrought.waterAccounting.map);

	// Layer selection control
	L.control.layers(owdiDrought.waterAccounting.basemaps).addTo(owdiDrought.waterAccounting.map);

	owdiDrought.waterAccounting.addDataToMap = function(data, style, layer, lc) {
		owdiDrought.waterAccounting.layers[layer] = L.geoJson(data, {
			style: style
		});
		owdiDrought.waterAccounting.layers[layer].addTo(owdiDrought.waterAccounting.map);
		owdiDrought.waterAccounting.group.addLayer(owdiDrought.waterAccounting.layers[layer])
		owdiDrought.waterAccounting.map.fitBounds(owdiDrought.waterAccounting.group.getBounds());

		// layer control
		if (lc != undefined) {
			L.control
				.layers(owdiDrought.waterAccounting.baseMaps, owdiDrought.waterAccounting.layers)
				.addTo(owdiDrought.waterAccounting.map);
		};
	};

	// Make calls to get the geojson data for hucs and water accounting.
	// then use that geojson to create layers on the map
	$.when(
		$.getJSON("../data/wbd1415.geojson"),
		$.getJSON("../data/wat_acc_cont.geojson")
	).done(function(d1, d2) {
		owdiDrought.waterAccounting.addDataToMap(d1, owdiDrought.waterAccounting.styles.watershed, "Colorado River Basin");
		owdiDrought.waterAccounting.addDataToMap(d2, owdiDrought.waterAccounting.styles.hucStyle, "Entitlement Holders");

		owdiDrought.waterAccounting.geojson = L.geoJson(d2, {
			style: owdiDrought.waterAccounting.styles.hucStyle,
			onEachFeature: owdiDrought.waterAccounting.onEachFeature
		}).addTo(owdiDrought.waterAccounting.map);
	});

});