//-----------------------------
// CONTROLING JS FOR BLUE DRAGON STORY MAP SLIDES
//-----------------------------

//-----------------------------
// define actions for setting up map
// executed once on startup, after map is created and before slides are created
// example:
story_api.actionMapSetup = function() {

    //.............................
    // set dam coords
    story_api.data = {};
    story_api.data.coords_hoover   = [36.0156, -114.7378];
    story_api.data.coords_davis    = [35.1994, -114.5707];
    story_api.data.coords_parker   = [34.2966, -114.1392];
    story_api.data.coords_imperial = [32.8831, -114.4650];
    story_api.data.coords_morelos  = [32.7056, -114.7292];

    //.............................
    // set map levels and bounds

    // set map zoom levels
    story_api.map.options.minZoom =  7; // farthest out  allowed
    story_api.map.options.maxZoom = 17; // farthest in   allowed
    
    // set allowed pan-zoom bounds (map bounces back if try to navigate outside these bounds)
    story_api.map.setMaxBounds([
        [31.0999,-123.1677], // southwest
        [37.4486,-109.9841]  // northEast
    ]);
    
    //.............................
    // add optional map controls

    // basemap picker
    story_api.addMapLayersPicker(
        [ // basemaps
            { "name":"esri_imagery2", "label":"Imagery"     },
            { "name":"esri_topo",     "label":"Topographic" },
            { "name":"openstreets",   "label":"Streets"     }
        ],
        [ // overlays
            { "name":"esri_reference",      "label":"Boundaries & Waterbodies", "check":0 },
            { "name":"esri_transportation", "label":"Transportation",           "check":0 }
        ],
        { // opts
            "position"            : "topright",
            "buttonLabel"         : "Basemaps",
            "basemapsInitOpacity" : 0.7,
            "overlaysInitOpacity" : 1.0
        }
    );

    // zoom with home button
    story_api.addZoomHome({
        "position"      : "topright",
        "zoomHomeTitle" : "Zoom to slide content"
    });

    // mouse coordinates
    story_api.addMouseCoords({"position":"bottomleft"});

    // map scale bar
    story_api.addScale({"position":"bottomleft"});

    // inset map
    story_api.addInsetMap({
        "position" : "bottomright",
        "width"    : 250,
        "height"   : 180
    });
};

//-----------------------------
// define actions to perform for ALL slides, BEFORE the slide's individual actions are executed
story_api.actionBeforeSlide = function () {
    // ...code goes here...
};

//-----------------------------
// define actions to do for each individual slide
// array of functions, 1 function for each slide
// example:
story_api.actionEachSlide = [
    //.............................
    // slide 0 actions: OVERVIEW
    function () {
        // info markers at each dam:
        story_api.addInfoMarker( story_api.data.coords_hoover,   "Hoover Dam"   );
        story_api.addInfoMarker( story_api.data.coords_davis,    "Davis Dam"    );
        story_api.addInfoMarker( story_api.data.coords_parker,   "Parker Dam"   );
        story_api.addInfoMarker( story_api.data.coords_imperial, "Imperial Dam" );
        story_api.addInfoMarker( story_api.data.coords_morelos,  "Morelos Dam"  );
        
        // zoom map to all markers with padding for slides_container on left
        story_api.zoomMarkers({ "paddingTopLeft" : [ $("#slides_container").width(), 0 ] });
    },

    //.............................
    // slide 1 actions: HOOVER DAM
    function () {
        // info marker:
        var htmlInfo =
            "Hoover Dam" +
            "<table class='popup-table'>" +
                "<tr>" +
                    "<td>Date Built</td>" +
                    "<td>1931-1936</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Max Water-Surface Elevation</td>" +
                    "<td>1,232 ft</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Purpose</td>" +
                    "<td>Power, flood control, water storage, regulation, recreation (Wikipedia)</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Total Water Storage (at elevation)</td>" +
                    "<td>28,945,000 acre-ft at 1,221.4 ft</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Elevation</td>" +
                    "<td>1076.52 ft (Lake Mead elevation)</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Discharge</td>" +
                    "<td>11.858.00 cfs (Hoover Dam release)</td>" +
                "</tr>" +
            "</table>";
        story_api.addInfoMarker( story_api.data.coords_hoover, htmlInfo );
        
        // // zoom map to all markers with padding for slides_container on left
        // story_api.zoomMarkers({ "paddingTopLeft" : [ $("#slides_container").width(), 0 ] }); // accounts for slides panel but zooms all in
        // story_api.map.setView( story_api.data.coords_hoover, 15, {"animate":true} );         // does not zoom all in but does not account for slides panel
        // story_api.map.fitBounds([[36.0034,-114.7722],[36.0277,-114.7207]]);                  // manual - goto desired extent and execute: JSON.stringify( story_api.map.getBounds() )
        
        // // try to animate: zoom in to marker 2 levels before max zoom pad left for slides panel
        // var maxZoom = story_api.map.getMaxZoom(); story_api.map.options.maxZoom = maxZoom - 2;
        // story_api.map.setZoom(maxZoom - 2); story_api.zoomMarkers({ "paddingTopLeft" : [ $("#slides_container").width(), 0 ], "pan":{"duration":1} });
        // story_api.map.options.maxZoom = maxZoom;
        
        // zoom in to marker 2 levels before max zoom pad left for slides panel
        var maxZoom = story_api.map.getMaxZoom(); story_api.map.options.maxZoom = maxZoom - 2;
        story_api.zoomMarkers({ "paddingTopLeft" : [ $("#slides_container").width(), 0 ] });
        story_api.map.options.maxZoom = maxZoom;
    },

    //.............................
    // slide 2 actions: DAVIS DAM
    function () {
        // info marker:
        var htmlInfo =
            "Davis Dam" +
            "<table class='popup-table'>" +
                "<tr>" +
                    "<td>Date Built</td>" +
                    "<td>1942-1950</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Max Water-Surface Elevation</td>" +
                    "<td>647 ft</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Purpose</td>" +
                    "<td>Regulate releases from Hoover Dam upstream, and facilitate the delivery of Colorado River water to Mexico (Wikipedia)</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Total Water Storage (at elevation)</td>" +
                    "<td>1.8 million acre-feet</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Elevation</td>" +
                    "<td>643.01 ft (Lake Mojave elevation)</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Discharge</td>" +
                    "<td>18,150.00 cfs (Davis Dam release)</td>" +
                "</tr>" +
            "</table>";
        story_api.addInfoMarker( story_api.data.coords_davis, htmlInfo );
        
        // zoom in to marker 2 levels before max zoom pad left for slides panel
        var maxZoom = story_api.map.getMaxZoom(); story_api.map.options.maxZoom = maxZoom - 2;
        story_api.zoomMarkers({ "paddingTopLeft" : [ $("#slides_container").width(), 0 ] });
        story_api.map.options.maxZoom = maxZoom;
    },

    //.............................
    // slide 3 actions: PARKER DAM
    function () {
        // info marker:
        var htmlInfo =
            "Parker Dam" +
            "<table class='popup-table'>" +
                "<tr>" +
                    "<td>Date Built</td>" +
                    "<td>1934-1938</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Max Water-Surface Elevation</td>" +
                    "<td>450 ft</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Purpose</td>" +
                    "<td>Provide reservoir storage from which water can be pumped into the Colorado River (California) and Central Arizona Project Aqueducts (BOR)</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Total Water Storage (at elevation)</td>" +
                    "<td>646,200 acre-ft at 450 ft</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Elevation</td>" +
                    "<td>448.88 ft (Lake Mojave elevation)</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Discharge</td>" +
                    "<td>9,087.00 cfs (Davis Dam release)</td>" +
                "</tr>" +
            "</table>";
        story_api.addInfoMarker( story_api.data.coords_parker, htmlInfo );
        
        // zoom in to marker 2 levels before max zoom pad left for slides panel
        var maxZoom = story_api.map.getMaxZoom(); story_api.map.options.maxZoom = maxZoom - 2;
        story_api.zoomMarkers({ "paddingTopLeft" : [ $("#slides_container").width(), 0 ] });
        story_api.map.options.maxZoom = maxZoom;
    },

    //.............................
    // slide 4 actions: IMPERIAL DAM
    function () {
        // info marker:
        var htmlInfo =
            "Imperial Dam" +
            "<table class='popup-table'>" +
                "<tr>" +
                    "<td>Date Built</td>" +
                    "<td>1936-1938</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Max Water-Surface Elevation</td>" +
                    "<td>N/A</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Purpose</td>" +
                    "<td>Irrigation, provide controlled gravity flow of water into the All-American and Gila Gravity Main Canals (BOR)</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Total Water Storage (at elevation)</td>" +
                    "<td>N/A</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Elevation</td>" +
                    "<td>180.19 ft (Imperial Diversion Dam)</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Discharge</td>" +
                    "<td>N/A</td>" +
                "</tr>" +
            "</table>";
        story_api.addInfoMarker( story_api.data.coords_imperial, htmlInfo );
        
        // zoom in to marker 2 levels before max zoom pad left for slides panel
        var maxZoom = story_api.map.getMaxZoom(); story_api.map.options.maxZoom = maxZoom - 2;
        story_api.zoomMarkers({ "paddingTopLeft" : [ $("#slides_container").width(), 0 ] });
        story_api.map.options.maxZoom = maxZoom;
    },

    //.............................
    // slide 5 actions: MORELOS DAM
    function () {
        // info marker:
        var htmlInfo =
            "Morelos Dam" +
            "<table class='popup-table'>" +
                "<tr>" +
                    "<td>Date Built</td>" +
                    "<td>1948-1950</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Max Water-Surface Elevation</td>" +
                    "<td>N/A</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Purpose</td>" +
                    "<td>Irrigation, divert water to irrigate the Mexicali Valley</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Total Water Storage (at elevation)</td>" +
                    "<td>N/A</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Elevation</td>" +
                    "<td>N/A</td>" +
                "</tr>" +
                "<tr>" +
                    "<td>Real-Time Discharge</td>" +
                    "<td>N/A</td>" +
                "</tr>" +
            "</table>";
        story_api.addInfoMarker( story_api.data.coords_morelos, htmlInfo );
        
        // zoom in to marker 2 levels before max zoom pad left for slides panel
        var maxZoom = story_api.map.getMaxZoom(); story_api.map.options.maxZoom = maxZoom - 2;
        story_api.zoomMarkers({ "paddingTopLeft" : [ $("#slides_container").width(), 0 ] });
        story_api.map.options.maxZoom = maxZoom;
    }
];

//-----------------------------
// define actions to perform for ALL slides, AFTER the slide's individual actions are executed
story_api.actionAfterSlide = function () {
    // ...code goes here...
};

//-----------------------------
// define additional custom functions for the story map not provided by the story_api
// example: (none required)

//-----------------------------
// END
//-----------------------------
