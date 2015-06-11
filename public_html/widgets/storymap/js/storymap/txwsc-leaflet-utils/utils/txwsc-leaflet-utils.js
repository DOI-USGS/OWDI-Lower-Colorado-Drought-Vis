//===========================================================
// txwsc-leaflet-utils.js
//   custom leaflet map utilities
//
//-----------------------------------------------------------
// REFERENCING THIS MODULE:
//
//   when loaded, all ltxwsc-leaflet-utils functionality is accessed from the global "U" object
//   the U object should not be used until txwsc-leaflet-utils is completely loaded
//
//   <script type="text/javascript" src="[PATH]/txwsc-leaflet-utils/utils/txwsc-leaflet-utils.js"></script>
//   <script type="text/javascript">
//       U.ready = function() {
//          // U should not be used until fully loaded
//          alert("txwsc-leaflet-utils READY!");
//       }
//   </script>
//
//-----------------------------------------------------------
// DEPENDANCIES:
//
// all required dependencies (including leaflet, jQuery, and jQuery UI) are dynamically loaded by the module
//
//-----------------------------------------------------------
// TODO:
// ...add todo items here...
//
// !!! LOOK AT AVAILABLE LEAFLET PLUGINS:  http://leafletjs.com/plugins.html
// LEAFLET PLUGINS OF INTEREST:
// ...data layers...
// SEE: Leaflet.Shapefile - Put a shapefile onto your map as a layer. https://github.com/calvinmetcalf/leaflet.shapefile
// SEE: Leaflet.FileGDB - Put an ESRI File GeoDatabase onto your map as a layer  https://github.com/calvinmetcalf/leaflet.filegdb
// SEE: Leaflet Realtime - Put realtime data on a Leaflet map: live tracking GPS units, sensor data or just about anything   https://github.com/perliedman/leaflet-realtime
// ...markers & labels...
// SEE: Leaflet.markercluster   https://github.com/Leaflet/Leaflet.markercluster
// SEE: Overlapping Marker Spiderfier   https://github.com/jawj/OverlappingMarkerSpiderfier-Leaflet
// SEE: Leaflet.label -  Adds text labels to map markers and vector layers  https://github.com/Leaflet/Leaflet.label
// ...map selecting...
// SEE Leaflet.AreaSelect - A fixed positioned, resizable rectangle for selecting an area on the map.  https://github.com/heyman/leaflet-areaselect/
// SEE: Leaflet.zoomslider - zoom slider  http://kartena.github.io/Leaflet.zoomslider/
//
// !!!
// addLayer ESRI funcs - need wait until layer is loaded before return result - how do this ???
//
// !!!
// BASEMAP PICKER IS ANNOYING THAT IT OPENS ON HOVER
// "GAT" style picker would be better, and can position anywhere
// if do this, also make func to add generic one, with updateContent function for updating content.
// EG: these can be used for "Info", "Legend" (content probably does not update) and "Data" (or something) where content updates with each slide
//
//
// BUGS:
// ...add bugs here...
//
//===========================================================
// "use strict"; // !!! DO NOT USE FOR PROD

// create module object
window.U = new Object();

// handle unavailable console logging - some browsers error if console not supported / unavailable
if (typeof window.console === "undefined") {
    window.console = {};
    window.console.log   = function (s) { return null; };
    window.console.warn  = function (s) { return null; };
    window.console.error = function (s) { return null; };
    window.console.clear = function (s) { return null; };
}

// NOTE: all "private" things not intended to be publically used are placed in "U._private"

// get the path to the module directory (needed for css, js, and image files)
if (U._private === undefined) { U._private = {}; }
U.getScriptPath = function () {
    var scripts = document.getElementsByTagName("script");     // all scripts
    var path    = scripts[scripts.length-1].src.split("?")[0]; // get last one (this one) and remove any ?query
    var mydir   = path.split("/").slice(0, -1).join("/")+"/";  // remove last filename part of path
    return mydir;
}
U._private.rootPath = U.getScriptPath();

// required css & js for this module - will be loaded in the order below
U._private.dependancyUrls = [];
// ...jQuery...
if (typeof jQuery === "undefined") {
    U._private.dependancyUrls.push( U._private.rootPath + "../jquery/jquery-1.11.1.min.js" ); // minified
}
// ...jQuery UI...
if ((typeof jQuery === "undefined") || (jQuery.ui === undefined)) {
    U._private.dependancyUrls.push(
        U._private.rootPath + "../jquery-ui/jquery-ui-1.10.4.custom.min.css", // minified
        U._private.rootPath + "../jquery-ui/jquery-ui-1.10.4.custom.min.js"   // minified
    );
}
// ...leaflet...
if (typeof L === "undefined") {
    U._private.dependancyUrls.push(
        U._private.rootPath + "../leaflet/leaflet-0.7.3/leaflet.min.css", // minified
        U._private.rootPath + "../leaflet/leaflet-0.7.3/leaflet.min.js"   // minified
    );
}
// ...leaflet: esri...
if ((typeof L === "undefined") || (L.esri === undefined)) {
    U._private.dependancyUrls.push(
         U._private.rootPath + "../leaflet/esri-leaflet-v1.0.0-rc.5/esri-leaflet.js" // minified
    );
}
// ...leaflet: zoom with home...
if ((typeof L === "undefined") || (L.Control.ZoomHome === undefined)) {
    U._private.dependancyUrls.push(
        U._private.rootPath + "../leaflet/leaflet-zoom-home/L.Control.ZoomHome.min.css", // minified
        U._private.rootPath + "../leaflet/leaflet-zoom-home/L.Control.ZoomHome.min.js"   // minified
    );
}
// ...leaflet: lat-lng mouse position...
if ((typeof L === "undefined") || (L.control.coordinates === undefined)) {
    U._private.dependancyUrls.push(
        U._private.rootPath + "../leaflet/Leaflet.Coordinates/Leaflet.Coordinates-0.1.4.css",   // minified
        U._private.rootPath + "../leaflet/Leaflet.Coordinates/Leaflet.Coordinates-0.1.4.min.js" // minified
    );
}
// ...leaflet: inset map...
if ((typeof L === "undefined") || (L.Control.MiniMap === undefined)) {
    U._private.dependancyUrls.push(
        U._private.rootPath + "../leaflet/Leaflet-MiniMap-master/Control.MiniMap.min.css", // minified
        U._private.rootPath + "../leaflet/Leaflet-MiniMap-master/Control.MiniMap.min.js"   // minified
    );
}
// ...leaflet: fullscreen map...
if ((typeof L === "undefined") || (L.Control.Fullscreen === undefined)) {
    U._private.dependancyUrls.push(
        U._private.rootPath + "../leaflet/Leaflet.fullscreen-gh-pages/leaflet.fullscreen.css",
        U._private.rootPath + "../leaflet/Leaflet.fullscreen-gh-pages/Leaflet.fullscreen.min.js"
    );
}
// ...leaflet: awesome markers...
if ((typeof L === "undefined") || (L.AwesomeMarkers === undefined)) {
    U._private.dependancyUrls.push(
        U._private.rootPath + "../leaflet/Leaflet.awesome-markers-2.0-develop/font-awesome-4.3.0/css/font-awesome.min.css", // minified
        U._private.rootPath + "../leaflet/Leaflet.awesome-markers-2.0-develop/leaflet.awesome-markers.css", // minified
        U._private.rootPath + "../leaflet/Leaflet.awesome-markers-2.0-develop/leaflet.awesome-markers.js"   // minified
    );
}
// ...this module...
U._private.dependancyUrls.push(
    U._private.rootPath + "txwsc-leaflet-utils.css"
);


//===========================================================
// PRIVATE FUNCTIONS
//===========================================================

//-----------------------------------------------------------
// init
//   initialize and configure after all dependencies loaded
U._private.init = function () {
    var funcName = "U [init]: ";
    console.log(funcName + "");
    
    //-------------------------------
    // built-in basemap urls
    // urls are defined as arrays so multiple layers can be grouped together and handled as a single layerGroup (eg: base + labels)
    // naming convention:
    //   1 suffix =   no labels
    //   2 suffix = with labels
    // if add to this list, need to also create ./img/thumb_basemap_XXX.png and add ".picker-thumb.XXX" entry to .css
    U._private.baseUrls = {
        // USGS
        // ...basemaps...
        "nationalmap_hydro"        : ["http://basemap.nationalmap.gov/arcgis/rest/services/USGSHydroNHD/MapServer/tile/{z}/{y}/{x}"        ], // zoom levels: 0-15
        "nationalmap_imagery"      : ["http://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryOnly/MapServer/tile/{z}/{y}/{x}"     ], // zoom levels: 0-15
        "nationalmap_imagery_topo" : ["http://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryTopo/MapServer/tile/{z}/{y}/{x}"     ], // zoom levels: 0-15
        "nationalmap_relief"       : ["http://basemap.nationalmap.gov/arcgis/rest/services/USGSShadedReliefOnly/MapServer/tile/{z}/{y}/{x}"], // zoom levels: 0-XX
        "nationalmap_topo"         : ["http://basemap.nationalmap.gov/ArcGIS/rest/services/USGSTopo/MapServer/tile/{z}/{y}/{x}"], // zoom levels: 0-XX
        // ...reference...
        "nationalmap_contours" : ["http://basemap.nationalmap.gov/arcgis/rest/services/TNM_Contours/MapServer/tile/{z}/{y}/{x}"          ], // zoom levels: 11-13
        "nationalmap_fills"    : ["http://basemap.nationalmap.gov/arcgis/rest/services/TNM_Vector_Fills_Small/MapServer/tile/{z}/{y}/{x}"], // zoom levels: 2-XX
        "nationalmap_small"    : ["http://basemap.nationalmap.gov/arcgis/rest/services/TNM_Vector_Small/MapServer/tile/{z}/{y}/{x}"      ], // zoom levels: 0-XX
        // ...more...
        // openstreetmap
        "openstreets" : ["http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"], // zoom levels: 0-XX
        // ...more...
        // carto
        "carto_base_light"  : ["http://{s}.api.cartocdn.com/base-light/{z}/{x}/{y}.png"         ], // zoom levels: XX-19
        "carto_positron1"   : ["http://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png"], // zoom levels: XX-19
        "carto_positron2"   : ["http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"     ], // zoom levels: XX-19
        "carto_darkMatter1" : ["http://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}.png" ], // zoom levels: XX-19
        "carto_darkMatter2" : ["http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png"      ], // zoom levels: XX-19
        // ...more...
        // esri
        // ...basemaps...
        "esri_streets"   : [ "http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}" ], // has labels  zoom levels: XX-XX
        "esri_natgeo"    : [ "http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer/tile/{z}/{y}/{x}" ], // has labels  zoom levels: XX-XX
        "esri_ocean"     : [ "http://services.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}"    ], // has labels  zoom levels: XX-XX
        "esri_topo"      : [ "http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}"   ], // has labels  zoom levels: XX-XX
        "esri_usatopo"   : [ "http://services.arcgisonline.com/ArcGIS/rest/services/USA_Topo_Maps/MapServer/tile/{z}/{y}/{x}"    ], // has labels (note: uses physical for far out zoom levels)  zoom levels: XX-XX
        "esri_imagery1"  : [ "http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}" ],
        "esri_imagery2"  : [
                             "http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                             "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}" // light labels
                           ], // zoom levels: XX-XX
        "esri_physical1" : [ "http://services.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}" ],
        "esri_physical2" : [
                             "http://services.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}",
                             "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places_Alternate/MapServer/tile/{z}/{y}/{x}" // dark labels
                           ], // zoom levels: XX-XX
        "esri_relief1"   : [ "http://services.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}" ],
        "esri_relief2"   : [
                             "http://services.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}",
                             "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places_Alternate/MapServer/tile/{z}/{y}/{x}" // dark labels
                           ], // zoom levels: XX-XX
        "esri_terrain1"  : [ "http://services.arcgisonline.com/ArcGIS/rest/services/World_Terrain_Base/MapServer/tile/{z}/{y}/{x}" ], // zoom levels: XX-XX
        "esri_terrain2"  : [
                             "http://services.arcgisonline.com/ArcGIS/rest/services/World_Terrain_Base/MapServer/tile/{z}/{y}/{x}",
                             "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places_Alternate/MapServer/tile/{z}/{y}/{x}" // dark labels
                           ], // zoom levels: XX-XX
        // ...reference...
        "esri_cites_borders_light": [ "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}"           ], // reference layer: cities and boundaries - light labels  zoom levels: XX-XX
        "esri_cites_borders_dark" : [ "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places_Alternate/MapServer/tile/{z}/{y}/{x}" ], // reference layer: cities and boundaries - dark  labels  zoom levels: XX-XX
        "esri_reference"          : [ "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Reference_Overlay/MapServer/tile/{z}/{y}/{x}"               ], // reference layer: lots of stuff                         zoom levels: XX-XX
        "esri_transportation"     : [ "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Transportation/MapServer/tile/{z}/{y}/{x}"                  ]  // reference layer: roads                                 zoom levels: XX-XX
    };

    // function to get base urls by name
    U._private.getBaseUrls = function ( baseName ) {
        // list available baseNames if not input
        if (baseName === undefined) {
            console.log("[getBaseUrls]: Available basemap names:");
            $.each( U._private.baseUrls, function( LUbaseName, LUbaseUrls ) {
                console.log( LUbaseName );
            });
            return 0;
        }
        // lookup urls for input baseName - do matching case insensitive, only on alpha-numeric characters
        var baseNameMatch = baseName.replace(/[^A-Za-z0-9]/g,"");
        var baseUrls = U._private.baseUrls["openstreets"]; // default if not found
        var foundIt  = false;
        $.each( U._private.baseUrls, function( LUbaseName, LUbaseUrls ) {
            LUbaseName = LUbaseName.replace(/[^A-Za-z0-9]/g,"");
            if (baseNameMatch.toLowerCase() === LUbaseName.toLowerCase()) { // found it
                baseUrls = LUbaseUrls;
                foundIt  = true;
                return foundIt;
            }
        });
        if (foundIt === false) { console.warn("[getBaseUrls]: Could not find URLs for '" + baseName + "' - 'openstreets' returned"); }
        return baseUrls;
    }
    
    //-------------------------------
    // map options
    U.mapOpts = {
        // ...map state options...
        "maxBounds" : null,           // [LatLngBounds, null] when set, map restricted to the given geographical bounds, bouncing the user back when he tries to pan outside
        "minZoom"   : 3,              // [Number,       null] minimum zoom level of the map. Overrides any minZoom set on map layers
        "maxZoom"   : 18,             // [Number,       null] maximum zoom level of the map. This overrides any maxZoom set on map layers
        "zoom"      : 4,              // [Number,       null] initial map zoom
        "center"    : [39,-97],       // [LatLng,       null] initial geographical center of the map
        "layers"    : null,           // [ILayer[],     null] initial layers to add to the map
        "crs"       : L.CRS.EPSG3857, // [CRS,          L.CRS.EPSG3857] Coordinate Reference System to use - don't change this if you're not sure what it means
        // ...interaction options...
        "dragging"           : true,  // [Boolean, true ] whether the map be draggable with mouse/touch or not
        "touchZoom"          : true,  // [Boolean, true ] whether the map can be zoomed by touch-dragging with two fingers
        "scrollWheelZoom"    : true,  // [Boolean, true ] whether the map can be zoomed by using the mouse wheel. If passed 'center', it will zoom to the center of the view regardless of where the mouse was
        "doubleClickZoom"    : true,  // [Boolean, true ] whether the map can be zoomed in by double clicking on it and zoomed out by double clicking while holding shift. If passed 'center', double-click zoom will zoom to the center of the view regardless of where the mouse was
        "boxZoom"            : true,  // [Boolean, true ] whether the map can be zoomed to a rectangular area specified by dragging the mouse while pressing shift
        "tap"                : true,  // [Boolean, true ] enables mobile hacks for supporting instant taps (fixing 200ms click delay on iOS/Android) and touch holds (fired as contextmenu events)
        "tapTolerance"       : 15,    // [Number,  15   ] the max number of pixels a user can shift his finger during touch for it to be considered a valid tap
        "trackResize"        : true,  // [Boolean, true ] whether the map automatically handles browser window resize to update itself
        "worldCopyJump"      : true,  // [Boolean, false] with this option enabled, the map tracks when you pan to another "copy" of the world and seamlessly jumps to the original one so that all overlays like markers and vector layers are still visible
        "closePopupOnClick"  : false, // [Boolean, true ] set it to false if you don't want popups to close when user clicks the map
        "bounceAtZoomLimits" : true,  // [Boolean, true ] set it to false if you don't want the map to zoom beyond min/max zoom and then bounce back when pinch-zooming
        // ...keyboard navigation options...
        "keyboard"           : true,  // [Boolean, true] makes the map focusable and allows users to navigate the map with keyboard arrows and +/- keys
        "keyboardPanOffset"  : 80,    // [Number, 80   ] amount of pixels to pan when pressing an arrow key
        "keyboardZoomOffset" : 1,     // [Number, 1    ] number of zoom levels to change when pressing + or - key
        // ...panning inertia options...
        "inertia"             : true, // [Boolean, true   ] if enabled, panning of the map will have an inertia effect where the map builds momentum while dragging and continues moving in the same direction for some time. Feels especially nice on touch devices
        "inertiaDeceleration" : 3000, // [Number,  3000   ] the rate with which the inertial movement slows down, in pixels/second2
        "inertiaMaxSpeed"     : 1500, // [Number,  1500   ] max speed of the inertial movement, in pixels/second
        //"inertiaThreshold"  : XXX,  // [Number,  depends] number of milliseconds that should pass between stopping the movement and releasing the mouse or touch to prevent inertial movement. 32 for touch devices and 14 for the rest by default
        // ...control options...
        "zoomControl"        : false, // [Boolean, true] whether the zoom control is added to the map by default
        "attributionControl" : false, // [Boolean, true] whether the attribution control is added to the map by default
        // ...animation options...
        //"fadeAnimation"        : XXX, // [Boolean, depends] whether the tile fade animation is enabled. By default it's enabled in all browsers that support CSS3 Transitions except Android
        //"zoomAnimation"        : XXX, // [Boolean, depends] whether the tile zoom animation is enabled. By default it's enabled in all browsers that support CSS3 Transitions except Android
        //"markerZoomAnimation"  : XXX, // [Boolean, depends] whether markers animate their zoom with the zoom animation, if disabled they will disappear for the length of the animation. By default it's enabled in all browsers that support CSS3 Transitions except Android
        "zoomAnimationThreshold" : 4    // [Number,  4      ] won't animate zoom if the zoom difference exceeds this value
    };
    
    
    // popup options
    U._private.popupOpts = {
        "maxWidth"       : 500,     // [Number,  300   ] Max width of the popup
        "minWidth"       : 100,     // [Number,  50    ] Min width of the popup
        "maxHeight"      : null,    // [Number,  null  ] If set, creates a scrollable container of the given height inside a popup if its content exceeds it
        "autoPan"        : true,    // [Boolean, true  ] Set it to false if you don't want the map to do panning animation to fit the opened popup
        "keepInView"     : false,   // [Boolean, false ] Set it to true if you want to prevent users from panning the popup off of the screen while it is open
        "closeButton"    : true,    // [Boolean, true  ] Controls the presense of a close button in the popup
        "offset"         : [0,-10], // [Point,   [0,6] ] The offset of the popup position. Useful to control the anchor of the popup when opening it on some overlays
        "autoPanPadding" : [10,10], // [Point,   [5,5] ] Equivalent of setting both top left and bottom right autopan padding to the same value
        "zoomAnimation"  : true,    // [Boolean, true  ] Whether to animate the popup on zoom. Disable it if you have problems with Flash content inside popups
        "closeOnClick"   : null,    // [Boolean, null  ] Set it to false if you want to override the default behavior of the popup closing when user clicks the map (set globally by the Map closePopupOnClick option)
        "className"      : ""       // [String,  ""    ] A custom class name to assign to the popup
    }
    
    // image marker icon
    U._private.imgMarkerIcon = L.icon({
            "iconUrl"     : U._private.rootPath + "img/marker-img-icon.png",
            "iconSize"     : [28, 22],
            "iconAnchor"   : [14, 11],
            "popupAnchor"  : [ 0,-15]
    });
    
    //-------------------------------
    // misc
    
    // flags for userAlert() dialog "do not show again" option
    // assign a flag for a userAlert() you want the "do no not show" option shown, and input that flag in userAlet()
    U._private.noShowDlgFlags = {
        // "XXX"        : false, // when XXX
        // ...more...
    };
    
    // jQuery animation duration [milli-sec]
    U._private.animateMs = 400;
    
    //-----------------------------------
    // execute ready function
    if (typeof U.ready === "function") {
        console.log(funcName + "executing 'ready' function");
        U.ready();
    } else {
        console.log(funcName + "no 'ready' function defined");
    }
    
}; // init


//===========================================================
// PUBLIC FUNCTIONS
//===========================================================

//-----------------------------------------------------------
// MAP CONTROLS
//-----------------------------------------------------------

//-----------------------------------------------------------
// addLogos
//   add logo to map
//   default adds USGS logo
//   call multiple times to add more logos
//   control object created as U.controls.logos
//
//   opts - (optional) options, see below for available
//
// EXAMPLES:
// U.map = map;
// U.addLogos();                             // add USGS logo
// U.addLogos({"imgUrl":"./coop_logo.png"}); // append cooperator logo to left of USGS
U.addLogos = function (opts) {
    var funcName = "U [addLogos]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map         === undefined) { opts.map         = U.map;                                           } // leaflet map
    if (opts.position    === undefined) { opts.position    = "topright";                                      } // position on map: "topleft", "topright", "bottomleft", "bottomright"
    if (opts.imgUrl      === undefined) { opts.imgUrl      = U._private.rootPath + "img/logo_USGS.png";       } // logo image URL
    if (opts.imgWidthPx  === undefined) { opts.imgWidthPx  = 184;                                             } // logo image width to use [px]
    if (opts.imgAlt      === undefined) { opts.imgAlt      = "USGS Logo";                                     } // ALT to use for logo image
    if (opts.imgTitle    === undefined) { opts.imgTitle    = "Go to U.S. Geological Survey (USGS) home page"; } // TITLE to use for image (tooltip)
    if (opts.imgClickUrl === undefined) { opts.imgClickUrl = "http://www.usgs.gov/";                          } // URL to launch in new browser window when logo clicked - set "" to not launch URL
    if (opts.fadeInMs    === undefined) { opts.fadeInMs    = 2000;                                            } // fade in duration when adding to map [milli-sec]
    U.map = opts.map;
    
    // reset some defaults if not USGS image and USGS defaults still set
    if (opts.imgUrl !== U._private.rootPath + "img/logo_USGS.png") {
        if ( opts.imgAlt      === "USGS Logo"                                    ) { opts.imgAlt      = ""; }
        if ( opts.imgTitle    === "Go to U.S. Geological Survey (USGS) home page") { opts.imgTitle    = ""; }
        if ( opts.imgClickUrl === "http://www.usgs.gov/"                         ) { opts.imgClickUrl = ""; }
    }
    
    // helper function to create img html for options
    var imgHtml = function(opts) {
        var html;
        if (opts.imgClickUrl !== "") {
            // need link image
            html =
                "<div class='leaflet-control-logos-img-container'>" +
                    "<a href='" + opts.imgClickUrl + "' target='_blank'>" +
                        "<img src='" + opts.imgUrl + "' width='" + opts.imgWidthPx + "' alt='" + opts.imgAlt + "' title='" + opts.imgTitle + "' />" +
                    "</a>" +
                "</div>";
        } else {
            // do not link image
            html =
                "<div class='leaflet-control-logos-img-container'>" +
                    "<img src='" + opts.imgUrl + "' width='" + opts.imgWidthPx + "' alt='" + opts.imgAlt + "' title='" + opts.imgTitle + "' />" +
                "</div>";
        }
        return html;
    }
    
    // create extended leaflet control
    var control = L.Control.extend({
    
        // set default options
        "options": {
            "position"    : "topright",
            "imgUrl"      : U._private.rootPath + "img/logo_USGS.png",
            "imgWidthPx"  : 184,
            "imgAlt"      : "USGS Logo",
            "imgTitle"    : "Go to U.S. Geological Survey (USGS) home page",
            "imgClickUrl" : "http://www.usgs.gov/"
        },
        
        // on add function
        "onAdd": function (map) {
            // create container with class name
            var container = L.DomUtil.create("div", "leaflet-control-logos");
            var options   = this.options
            
            // reset some defaults if not USGS image and USGS defaults still set
            if (options.imgUrl !== U._private.rootPath + "img/logo_USGS.png") {
                if ( options.imgAlt      === "USGS Logo"                                    ) { options.imgAlt      = ""; }
                if ( options.imgTitle    === "Go to U.S. Geological Survey (USGS) home page") { options.imgTitle    = ""; }
                if ( options.imgClickUrl === "http://www.usgs.gov/"                         ) { options.imgClickUrl = ""; }
            }
            
            // add logo to container
            $(container).html( imgHtml(options) );
            return container;
        }
    });
    
    // create new logo or append to existing
    if (U.controls === undefined) { U.controls = {}; }
    if (U.controls.logos === undefined) {
        // create logos and add to map
        U.controls.logos = new control({
            "position"    : opts.position,
            "imgUrl"      : opts.imgUrl,
            "imgWidthPx"  : opts.imgWidthPx,
            "imgAlt"      : opts.imgAlt,
            "imgTitle"    : opts.imgTitle,
            "imgClickUrl" : opts.imgClickUrl
        });
        U.map.addControl( U.controls.logos );
        // fade in
        $( U.controls.logos.getContainer() )
            .css(    {"opacity":0}      )
            .stop()
            .animate({"opacity":1}, opts.fadeInMs);
    } else {
        // add to existing
        $( U.controls.logos.getContainer() ).prepend( imgHtml(opts) );
    }
}; // addLogos


//-----------------------------------------------------------
// addMapLayersPicker
//   add map layer picker to map
//
//   more than 1 mapLayersPicker can be added to the map
//   control object created is pushed to end of U.controls.mapLayersPicker array (0-based)
//   access the 1st added like U.controls.mapLayersPicker[0], the 2nd added like U.controls.mapLayersPicker[1], etc.
//
//   basemaps
//     array of layer objects, 1 object for each basemap layer to include in picker (see example)
//     basemap layers are at the top of the expanded widget and have radio buttons - only 1 can be selected and shown on the map at once
//     basemaps may be any combination of:
//       - "none" to show no basemap layer
//       - named tiled layer supported by getBaseUrls (openstreets used if not recognized)
//       - custom layer or layerGroup (thumb image required)
//     order in picker is order defined in array
//     set to [] to not include any basemap layers in the picker (1 or more overlays, below, must be defined)
//     example:
//         [
//             { "name":"none",          "label":"No basemap" }, // "none" to show no basemap layer when selected
//             { "name":"esri_imagery2", "label":"Imagery"    }, // named tiled layer supported by getBaseUrls
//             { // custom layer or layerGroup
//                 "layer"    : L.esri.dynamicMapLayer("http://raster.nationalmap.gov/arcgis/rest/services/LandCover/USGS_EROS_LandCover_NLCD/MapServer"),
//                 "label"    : "Land Cover",
//                 "thumbUrl" : "./img/thumb_coverage_landcover.png"
//             },
//             ...more...
//         ]
//     where:
//         ...named basemaps...
//         "name"  - (required) name of the layer ("none" or see available in U._private.getBaseUrls)
//         "label" - (optional) label to use to name the layer in the picker (set to "name" if omitted)
//         ...custom layer or layerGroups...
//         "layer"    - (required) leaflet layer of single layer or layerGroup of multiple layers
//         "label"    - (required) label to use to name the layer in the picker
//         "thumbUrl" - (required) url to thumbnail image to show in picker
//         "check"    - (optional) whether to check and show this overlay on creation (0 or 1, default=0)
//
//   overlays
//     array of layer objects, 1 for each overlay to include in picker
//     overlay layers are at the bottom of the expanded widget and have checkboxes - can be shown on the map independently
//     overlays may be any combination of:
//       - named tiled layer supported by getBaseUrls (openstreets used if not recognized)
//       - custom layer or layerGroup (thumb image required)
//     order in picker is order defined in array
//     set to [] to not include any overlays in the picker (1 or more basemaps, above, must be defined)
//     example:
//         [
//             { "name":"esri_transportation", "label":"Transportation", "check":0}, // named tiled layer supported by getBaseUrls
//             { // custom layer or layerGroup
//                 "layer"    : L.esri.dynamicMapLayer("http://XXX/arcgis/rest/services/XXX/XXX/MapServer"),
//                 "label"    : "My Cutsom Overlay",
//                 "thumbUrl" : "./img/thumb_coverage_landcover.png",
//                 "check"    : 1
//             },
//             ...more...
//         ]
//     where:
//         ...named overlays...
//         "name"  - (required) name of the layer (see available in U._private.getBaseUrls)
//         "label" - (optional) label to use to name the layer in the picker (set to "name" if omitted)
//         "check" - (optional) whether to check and show this overlay on creation (0 or 1, default=0)
//         ...custom layer or layerGroups...
//         "layer"    - (required) leaflet layer of single layer or layerGroup of multiple layers
//         "label"    - (required) label to use to name the layer in the picker
//         "thumbUrl" - (required) url to thumbnail image to show in picker
//         "check"    - (optional) whether to check and show this overlay on creation (0 or 1, default=0)
//
//   opts - (optional) options, see below for available
U.addMapLayersPicker = function (basemaps, overlays, opts) {
    var funcName = "U [addMapLayersPicker]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    // ...for L.control.layers...
    if (opts.position   === undefined) { opts.position   = "topright"; } // position on map: "topleft", "topright", "bottomleft", "bottomright"
    if (opts.collapsed  === undefined) { opts.collapsed  = true;       } // true = use icon that opens to menu, false = no icon and menu always open
    if (opts.autoZIndex === undefined) { opts.autoZIndex = true;       } // true = automatically assign z-indexes to preserve order
    // ...additional...
    if (opts.map                 === undefined) { opts.map                 = U.map;        } // leaflet map
    if (opts.buttonLabel         === undefined) { opts.buttonLabel         = "Map Layers"; } // label for collapsed widget button
    if (opts.basemapsLabel       === undefined) { opts.basemapsLabel       = "Basemaps";   } // label for expanded basemap section
    if (opts.overlaysLabel       === undefined) { opts.overlaysLabel       = "Overlays";   } // label for expanded overlay section
    if (opts.basemapsInitOpacity === undefined) { opts.basemapsInitOpacity = 1;            } // initial opacity for basemap layers (can change with slider)
    if (opts.overlaysInitOpacity === undefined) { opts.overlaysInitOpacity = 1;            } // initial opacity for overlay layers (can change with slider)
    if (opts.thumbOpacity        === undefined) { opts.thumbOpacity        = 0.6;          } // opacity for unselected thumb images
    if (opts.fadeInMs            === undefined) { opts.fadeInMs            = 2000;         } // fade in duration when adding contorl to map [milli-sec]
    U.map = opts.map;
    
    // need some basemaps and/or overlays defined
    if ( basemaps.length + overlays.length <= 0 ) {
        console.warn(funcName + "1 or more 'basemaps' and/or 'overlays' must be defined - not creating mapLayersPicker");
        return 1;
    }
    
    // create basemap layerConfig
    var basemapConfig = {};
    $.each( basemaps, function( idx, optsObj ){
        // different ways user can specify:
        //   { "name":"none",      "label":"Nothing"     }, // none
        //   { "name":"esri_topo", "label":"Topographic" }, // named tiled layer supported by getBaseUrls
        //   { "layer": L_LAYER_OR_LAYER_GROUP, "label":"LABEL", "thumbUrl":THUMB_IMG_URL } // custom layer or layerGroup with their own thumb
        // handle cases
        if ( optsObj.name !== undefined && optsObj.name.toLowerCase() === "none" ) {
            // "none" - set layer and thumb
            optsObj.name     = undefined; // clear so added as custom layer
            optsObj.thumbUrl = U._private.rootPath + "img/thumb_basemap_none.png";               // set thumb     (transparent)
            optsObj.layer    = L.tileLayer( U._private.rootPath + "img/thumb_basemap_none.png"); // set tileLayer (transparent)
            if ( optsObj.label === undefined ) { optsObj.label = "None"; } // set default label
        }
        if ( optsObj.name !== undefined ) {
            // named tiled layer supported by getBaseUrls
            
            // get URLs
            var urls = U._private.getBaseUrls(optsObj.name);
            
            // if unrecognised, openstreets used - need to set thumb
            if ( urls.length === 1 && urls[0] === U._private.baseUrls["openstreets"][0] ) { optsObj.name = "openstreets"; }
            
            // create layerGroup for this basemap
            var layerGroup =  L.layerGroup();
            $.each( urls, function( idx, url ) {
                layerGroup.addLayer(
                    L.tileLayer( url, {"opacity":opts.basemapsInitOpacity} )
                );
            });
            
            // add to basemapConfig with html - label defaults to name if not specified
            basemapConfig[ "<span class='basemap-span'><div class='picker-thumb "+optsObj.name+"'></div>"+( optsObj.label === undefined ? optsObj.name : optsObj.label )+"</span>" ] = layerGroup;
            
        } else {
            // custom layer or layerGroup with their own thumb
            
            // convert to layerGroup if input as layer
            if (typeof optsObj.layer.eachLayer !== "function") { // layer, not layer group
                optsObj.layer = L.layerGroup().addLayer( optsObj.layer );
            }
            
            // add to basemapConfig with html
            basemapConfig[ "<span class='basemap-span'><div class='picker-thumb'><img src='"+optsObj.thumbUrl+"'/></div>"+optsObj.label+"</span>" ] = optsObj.layer;
        }
    });
    
    // create overlay layerConfig
    var overlayConfig = {};
    $.each( overlays, function( idx, optsObj ){
        // different ways user can specify:
        //   { "name":"esri_transportation", "label":"Transportation" }, // named tiled layer supported by getBaseUrls
        //   { "layer": L_LAYER_OR_LAYER_GROUP, "label":"LABEL", "thumbUrl":THUMB_IMG_URL } // custom layer or layerGroup with their own thumb
        // handle cases
        if ( optsObj.name !== undefined ) {
            // named tiled layer supported by getBaseUrls
            
            // get URLs
            var urls = U._private.getBaseUrls(optsObj.name);
            
            // if unrecognised, openstreets used - need to set thumb
            if ( urls.length === 1 && urls[0] === U._private.baseUrls["openstreets"][0] ) { optsObj.name = "openstreets"; }
            
            // create layerGroup for this overlay
            var layerGroup =  L.layerGroup();
            $.each( urls, function( idx, url ) {
                layerGroup.addLayer(
                    L.tileLayer( url, {"opacity":opts.overlaysInitOpacity} )
                );
            });
            
            // add to overlayConfig with html
            // add check class if specified to check this (show layer) on creation
            // label defaults to name if not specified
            overlayConfig[ "<span class='overlay-span" + ( optsObj.check === 1 ? " check" : "" ) + "'><div class='picker-thumb "+optsObj.name+"'></div>"+( optsObj.label === undefined ? optsObj.name : optsObj.label )+"</span>" ] = layerGroup;
            
        } else {
            // custom layer or layerGroup with their own thumb
            
            // convert to layerGroup if input as layer
            if (typeof optsObj.layer.eachLayer !== "function") { // layer, not layer group
                optsObj.layer = L.layerGroup().addLayer( optsObj.layer );
            }
            
            // add to overlayConfig with html
            // add check class if specified to check this (show layer) on creation
            // label defaults to name if not specified
            overlayConfig[ "<span class='overlay-span" + ( optsObj.check === 1 ? " check" : "" ) + "'><div class='picker-thumb'><img src='"+optsObj.thumbUrl+"'/></div>"+optsObj.label+"</span>" ] = optsObj.layer;
        }
    });
    
    // create control and add to map
    // can have multiple mapLayersPicker's - push to array
    if (U.controls === undefined) { U.controls = {}; }
    if (U.controls.mapLayersPicker === undefined) { U.controls.mapLayersPicker = []; }
    U.controls.mapLayersPicker.push(
        L.control.layers(
            basemapConfig, // radio buttons - can only show 1 at a time
            overlayConfig, // checkboxes    - can show independently
            opts           // options
        )
    );
    U.map.addControl( U.controls.mapLayersPicker[ U.controls.mapLayersPicker.length-1 ] );
    
    // customize button
    var pickerContainer = $( U.controls.mapLayersPicker[ U.controls.mapLayersPicker.length-1 ].getContainer() );
    pickerContainer.find(".leaflet-control-layers-toggle")
        .prop("title","") // remove hover tip
        .addClass("picker-button")
        .append("<span class='picker-button-label'>" + opts.buttonLabel + "</span>");
    pickerContainer.css({"opacity":0}); // hide until ready
    
    // setup any basemaps
    if ( ! $.isEmptyObject(basemapConfig) ) {
        
        // need to set any other basemap added transparent
        if ( U.layers && U.layers.basemapLayerGroup ) {
            U.layers.basemapLayerGroup.eachLayer(function(layer) {
                layer.setOpacity(0);
            });
        }
        
        // set styling and behavior for menu items
        pickerContainer.find(".basemap-span").closest("label").addClass("picker-basemap-item"); // item wrapper including radio button, thumb, & label
        pickerContainer.find(".picker-basemap-item")
            .hover( // fade thumb in-out & set border when hover over any item element that is not selected
                function() { $(this).not(".selected").find(".picker-thumb").css({"border":"2px solid Gold"}).stop().animate({"opacity":"1.0"            }, 300); },
                function() { $(this).not(".selected").find(".picker-thumb").css({"border":"2px solid Gray"}).stop().animate({"opacity":opts.thumbOpacity}, 300); }
            )
            .click( function() {
                // do nothing if selected
                if ( $(this).hasClass("selected") ) { return 0; }
                
                // de-select all items
                pickerContainer.find(".picker-basemap-item")
                    .removeClass("selected")
                    .find(".picker-thumb").stop().css({"border":"2px solid Gray", "opacity":opts.thumbOpacity});
                // select the clicked item
                $(this)
                    .addClass("selected")
                    .find(".picker-thumb").stop().css({"border":"2px solid LimeGreen", "opacity":"1.0"});
                // update cursor
                pickerContainer.find(".picker-basemap-item.selected"        ).find("*").css({"cursor":"default"}); // selected item cursor
                pickerContainer.find(".picker-basemap-item").not(".selected").find("*").css({"cursor":"pointer"}); // non-selected item cursors
            });
        
        // click the 1st item to init menu and set basemap
        pickerContainer.find(".basemap-span").first().find(".picker-thumb").closest(".picker-basemap-item").click();
        
        // add section header and transparency slider
        pickerContainer.find(".leaflet-control-layers-base")
            .prepend("<span class='picker-header'>" + opts.basemapsLabel + "</span>")
            .append("<div class='basemap_slider' style='margin:5px 10px 10px 10px;'></div>");
        pickerContainer.find(".basemap_slider")
            .slider({
                "disabled"    : false,
                "orientation" : "horizontal",
                "range"       : false,
                "animate"     : "fast",
                "min"         : 0,
                "max"         : 1,
                "step"        : 0.05,
                "value"       : opts.basemapsInitOpacity,
                "change" : function (evt,ui) {
                    $.each( basemapConfig, function( key, layerGroup ) {
                        layerGroup.eachLayer(function(layer) {
                            try {
                                // some layer types might not be loaded yet
                                layer.setOpacity(ui.value);
                            } catch(err) {
                                // do nothing
                            }
                        });
                    });
                },
                "slide" : function (evt,ui) {
                    $.each( basemapConfig, function( key, layerGroup ) {
                        layerGroup.eachLayer(function(layer) {
                            try {
                                // some layer types might not be loaded yet
                                layer.setOpacity(ui.value);
                            } catch(err) {
                                // do nothing
                            }
                        });
                    });
                }
            });
            // do not add tooltip - hoving over closes picker
        pickerContainer.find(".basemap_slider").add( pickerContainer.find(".basemap_slider").find("*") ).css({"cursor":"pointer"});
    }
    
    // setup any overlays
    if ( ! $.isEmptyObject(overlayConfig) ) {
        
        // set styling and behavior for menu items
        pickerContainer.find(".overlay-span").closest("label").addClass("picker-overlay-item"); // item wrapper including radio button, thumb, & label
        pickerContainer.find(".picker-overlay-item")
            .mouseenter( function() {
                if ( $(this).hasClass("selected") ) {
                    $(this).find(".picker-thumb").css({"border":"2px solid LimeGreen"}).stop().animate({"opacity":"1.0"}, 300);
                } else {
                    $(this).find(".picker-thumb").css({"border":"2px solid Gold"     }).stop().animate({"opacity":"1.0"}, 300);
                }
            })
            .mouseleave( function() {
                if ( $(this).hasClass("selected") ) {
                    $(this).find(".picker-thumb").css({"border":"2px solid LimeGreen"}).stop().animate({"opacity":"1.0"            }, 300);
                } else {
                    $(this).find(".picker-thumb").css({"border":"2px solid Gray"     }).stop().animate({"opacity":opts.thumbOpacity}, 300);
                }
            })
            .mousedown( function() {
                if ( $(this).hasClass("selected") ) {
                     $(this)
                        .removeClass("selected")
                        .find(".picker-thumb").css({"border":"2px solid Gold"}).stop().animate({"opacity":opts.thumbOpacity}, 300);
                } else {
                    $(this)
                        .addClass("selected")
                        .find(".picker-thumb").css({"border":"2px solid LimeGreen"}).stop().animate({"opacity":"1.0"}, 300);
                }
            })
        
        // init: unselected and always pointer cursor
        pickerContainer.find(".picker-overlay-item").removeClass("selected");
        pickerContainer.find(".picker-overlay-item").find(".picker-thumb").css({"border":"2px solid Gray", "opacity":opts.thumbOpacity});
        pickerContainer.find(".picker-overlay-item").find("*").css({"cursor":"pointer"});
        
        // click to check if specified (has check class)
        pickerContainer.find(".overlay-span").each( function() {
            if ( $(this).hasClass("check") ) {
                $(this).find(".picker-thumb").closest(".picker-overlay-item")
                    .mousedown() // set active
                    .click();    // check checkbox
                $(this).removeClass("check");
            }
        });
        
        // add section header and transparency slider
        pickerContainer.find(".leaflet-control-layers-overlays")
            .prepend("<span class='picker-header'>" + opts.overlaysLabel + "</span>")
            .append("<div class='overlays_slider' style='margin:5px 10px 0px 10px;'></div>");
        pickerContainer.find(".overlays_slider")
            .slider({
                "disabled"    : false,
                "orientation" : "horizontal",
                "range"       : false,
                "animate"     : "fast",
                "min"         : 0,
                "max"         : 1,
                "step"        : 0.05,
                "value"       : opts.overlaysInitOpacity,
                "change" : function (evt,ui) {
                    $.each( overlayConfig, function( key, layerGroup ) {
                        layerGroup.eachLayer(function(layer) {
                            try {
                                // some layer types might not be loaded yet
                                layer.setOpacity(ui.value);
                            } catch(err) {
                                // do nothing
                            }
                        });
                    });
                },
                "slide" : function (evt,ui) {
                    $.each( overlayConfig, function( key, layerGroup ) {
                        layerGroup.eachLayer(function(layer) {
                            try {
                                // some layer types might not be loaded yet
                                layer.setOpacity(ui.value);
                            } catch(err) {
                                // do nothing
                            }
                        });
                    });
                }
            });
            // do not add tooltip - hoving over closes picker
        pickerContainer.find(".overlays_slider").add( pickerContainer.find(".overlays_slider").find("*") ).css({"cursor":"pointer"});
    }
    
    // remove horizontal separator line from default L.control
    pickerContainer.find(".leaflet-control-layers-separator").remove()
    
    // make contents non-mouse-drag-selectable
    U.noDragSelect( pickerContainer );
    
    // fade in
    pickerContainer.stop().animate({"opacity":1}, opts.fadeInMs);
    
}; // addMapLayersPicker


//-----------------------------------------------------------
// addZoomHome
//   add zoom control with home button to map
//   control object created as U.controls.zoomHome
//
//   opts - (optional) options, see below for available
U.addZoomHome = function ( opts ) {
    var funcName = "U [addZoomHome]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map           === undefined) { opts.map           = U.map;               } // leaflet map
    if (opts.position      === undefined) { opts.position      = "topright";          } // position on map: "topleft", "topright", "bottomleft", "bottomright"
    if (opts.zoomInText    === undefined) { opts.zoomInText    = "+";                 } // zoom in   button label
    if (opts.zoomInTitle   === undefined) { opts.zoomInTitle   = "Zoom in";           } // zoom in   tooltip
    if (opts.zoomOutText   === undefined) { opts.zoomOutText   = "-";                 } // zoom out  button label
    if (opts.zoomOutTitle  === undefined) { opts.zoomOutTitle  = "Zoom out";          } // zoom out  tooltip
    if (opts.zoomHomeText  === undefined) { opts.zoomHomeText  = "H";                 } // zoom home button label
    if (opts.zoomHomeTitle === undefined) { opts.zoomHomeTitle = "Zoom home";         } // zoom home tooltip
    if (opts.buttonOrder   === undefined) { opts.buttonOrder   = ["in","home","out"]; } // button order from top to bottom. 3-element array containing strings "in", "home", and "out". order in array sets order in widget
    if (opts.homeGeom      === undefined) { opts.homeGeom      = L.latLngBounds( L.latLng(24,-125), L.latLng(50,-66) ); } // bound to set when home button clicked
    if (opts.fadeInMs      === undefined) { opts.fadeInMs      = 2000;                } // fade in duration when adding to map [milli-sec]
    U.map = opts.map;
    
    // create zoom control with home button (L.Control.ZoomHome js plugin) and add to map
    if (U.controls === undefined) { U.controls = {}; }
    U.controls.zoomHome = new L.Control.ZoomHome({
        "position"      : opts.position,
        "zoomInText"    : opts.zoomInText,
        "zoomInTitle"   : opts.zoomInTitle,
        "zoomOutText"   : opts.zoomOutText,
        "zoomOutTitle"  : opts.zoomOutTitle,
        "zoomHomeText"  : opts.zoomHomeText,
        "zoomHomeTitle" : opts.zoomHomeTitle,
        "buttonOrder"   : opts.buttonOrder,
        "homeGeom"      : opts.homeGeom
    });
    U.map.addControl( U.controls.zoomHome );
    
    // fade in
    $( U.controls.zoomHome.getContainer() )
        .css(    {"opacity":0}      )
        .stop()
        .animate({"opacity":1}, opts.fadeInMs);
    
}; // addZoomHome


//-----------------------------------------------------------
// addMouseCoords
//   add control showing lat-lng of mouse position
//   control object created as U.controls.mouseCoords
//
//   opts - (optional) options, see below for available
U.addMouseCoords = function ( opts ) {
    var funcName = "U [addMouseCoords]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map                   === undefined) { opts.map                   = U.map;            } // leaflet map
    if (opts.position              === undefined) { opts.position              = "bottomleft";     } // position on map: "topleft", "topright", "bottomleft", "bottomright"
    if (opts.decimals              === undefined) { opts.decimals              = 3;                } // # decimals used if not using DMS or labelFormatter functions
    if (opts.decimalSeperator      === undefined) { opts.decimalSeperator      = ".";              } // decimal character (eg: "." US or "," EUR)
    if (opts.labelTemplateLat      === undefined) { opts.labelTemplateLat      = "Lat: {y}&nbsp;"; } // latitude  label template
    if (opts.labelTemplateLng      === undefined) { opts.labelTemplateLng      = "Lon: {x}";       } // longitude label template
    if (opts.useLatLngOrder        === undefined) { opts.useLatLngOrder        = true;             } // if true lat-lng instead of lng-lat label ordering is used
    if (opts.useDMS                === undefined) { opts.useDMS                = false;            } // use Degree-Minute-Second?
    if (opts.enableUserInput       === undefined) { opts.enableUserInput       = false;            } // switch on/off input fields on click - when user enters coord marker put on map
    if (opts.centerUserCoordinates === undefined) { opts.centerUserCoordinates = true;             } // if true user given coordinates are centered
    if (opts.fadeInMs              === undefined) { opts.fadeInMs              = 2000;             } // fade in duration when adding to map [milli-sec]
    U.map = opts.map;
    
    // create control (L.control.coordinates js plugin) and add to map
    if (U.controls === undefined) { U.controls = {}; }
    U.controls.mouseCoords = L.control.coordinates({
        "position"              : opts.position,
        "decimals"              : opts.decimals,
        "decimalSeperator"      : opts.decimalSeperator,
        "labelTemplateLat"      : opts.labelTemplateLat,
        "labelTemplateLng"      : opts.labelTemplateLng,
        "useLatLngOrder"        : opts.useLatLngOrder,
        "useDMS"                : opts.useDMS,
        "enableUserInput"       : opts.enableUserInput,
        "centerUserCoordinates" : opts.centerUserCoordinates
    });
    U.map.addControl( U.controls.mouseCoords );
    
    // fade in
    var controlContainer = $( U.controls.mouseCoords.getContainer() );
    controlContainer
        .css(    {"opacity":0.0}      )
        .stop()
        .animate({"opacity":0.6}, opts.fadeInMs);
    
    // zoom level to map scale lookup table
    // SOURCE: http://gis.stackexchange.com/questions/7430/what-ratio-scales-do-google-maps-zoom-levels-correspond-to
    var scaleZoomLookup = {
        19 :       "1,128",
        18 :       "2,257",
        17 :       "4,514",
        16 :       "9,028",
        15 :      "18,056",
        14 :      "36,112",
        13 :      "72,224",
        12 :     "144,448",
        11 :     "288,895",
        10 :     "577,791",
         9 :   "1,155,581",
         8 :   "2,311,162",
         7 :   "4,622,325",
         6 :   "9,244,649",
         5 :  "18,489,298",
         4 :  "36,978,597",
         3 :  "73,957,194",
         2 : "147,914,388",
         1 : "295,828,775",
         0 : "591,657,551"
    };
    
    // add map scale to reported lat-lng
    controlContainer.find(".uiElement.label").prepend("<span id='mouseCoordsScale'></span>"); // add span for inserting map scale
    U.map.on("zoomend", function () {
        // update scale when map zooms using fixed values based on zoom level
        var scale = scaleZoomLookup[ this.getZoom() ];
        if (scale !== undefined) { $("#mouseCoordsScale").html("Scale: 1:" + scale + "&nbsp;&nbsp;"); }
    });
    
    // show/hide lat-lng coords when mouse enters/leaves map
    U.map.on("mouseover", function () { controlContainer.find(".labelFirst").stop().fadeIn( 300); });
    U.map.on("mouseout",  function () { controlContainer.find(".labelFirst").stop().fadeOut(300); });
    
    // additional setup when user can click to enter coords
    if (opts.enableUserInput === true) {
        // highlight/un-highlight & increase/decrease opacity when mouse enters/exits control
        controlContainer.mouseenter( function() {
            // highlight & full opacity
            controlContainer.stop().addClass("highlight").stop().animate({"opacity":"1.0"}, 200);
        });
        controlContainer.mouseleave( function() {
            // un-highlight & reduce opacity
            controlContainer.stop().removeClass("highlight").stop().animate({"opacity":"0.6"}, 200);
            // collapse if editable when mouse leaves
            U.controls.mouseCoords.collapse();
        });
        // set tooltips
        controlContainer.prop("title","Click to enter a coordinate and a place marker on the map");
        controlContainer.find(".inputX").prop("title","Enter a longitude (decimal degrees) to place marker on the map");
        controlContainer.find(".inputY").prop("title","Enter a latitude (decimal degrees) to place marker on the map" );
    } else {
        // cannot click to enter coords
        controlContainer.css({"cursor":"default"});
    }
    
    // init on startup
    $("#mouseCoordsScale").html("Scale: 1:" + scaleZoomLookup[ U.map.getZoom() ] + "&nbsp;&nbsp;"); // init scale
    controlContainer.css({"opacity":"0.6"}); // init opacity
    
}; // addMouseCoords


//-----------------------------------------------------------
// addScale
//   add map scale to map
//   control object created as U.controls.scale
//
//   opts - (optional) options, see below for available
U.addScale = function ( opts ) {
    var funcName = "U [addScale]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map            === undefined) { opts.map            = U.map;        } // leaflet map
    if (opts.position       === undefined) { opts.position       = "bottomleft"; } // position on map: "topleft", "topright", "bottomleft", "bottomright"
    if (opts.maxWidth       === undefined) { opts.maxWidth       = 200;          } // max width [px]
    if (opts.metric         === undefined) { opts.metric         = true;         } // show metric? (km/m)
    if (opts.imperial       === undefined) { opts.imperial       = true;         } // show imperial? (mi/ft)
    if (opts.updateWhenIdle === undefined) { opts.updateWhenIdle = false;        } // true = wait for map to stop moving before updating, false = update as map is moved
    if (opts.fadeInMs       === undefined) { opts.fadeInMs       = 2000;         } // fade in duration when adding to map [milli-sec]
    U.map = opts.map;
    
    // create scale bar and add to map
    if (U.controls === undefined) { U.controls = {}; }
    U.controls.scale = L.control.scale({
        "position"       : opts.position,
        "maxWidth"       : opts.maxWidth,
        "metric"         : opts.metric,
        "imperial"       : opts.imperial,
        "updateWhenIdle" : opts.updateWhenIdle
    });
    U.map.addControl( U.controls.scale );
    
    // fade in
    $( U.controls.scale.getContainer() )
        .css(    {"opacity":0}      )
        .stop()
        .animate({"opacity":1}, opts.fadeInMs);
    
}; // addScale


//-----------------------------------------------------------
// addToggleFullScreen
//   add full screen toggle button to map (toggles map fullscreen)
//   control object created as U.controls.toggleFullScreen
//
//   opts - (optional) options, see below for available
U.addToggleFullScreen = function ( opts ) {
    var funcName = "U [addToggleFullScreen]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map       === undefined) { opts.map       = U.map;                    } // leaflet map
    if (opts.position  === undefined) { opts.position  = "topleft";                } // position on map: "topleft", "topright", "bottomleft", "bottomright"
    if (opts.titleFull === undefined) { opts.titleFull = "View map in fullscreen"; } // tooltip title to display to goto full screen
    if (opts.titleExit === undefined) { opts.titleExit = "Exit fullscreen mode";   } // tooltip title to display to exit full screen
    if (opts.fadeInMs  === undefined) { opts.fadeInMs  = 2000;                     } // fade in duration when adding to map [milli-sec]
    U.map = opts.map;
    
    // create control and add to map
    if (U.controls === undefined) { U.controls = {}; }
    U.controls.toggleFullScreen = new L.Control.Fullscreen({
        "position" : opts.position,
        "title"    : {
            "false" : opts.titleFull,
            "true"  : opts.titleExit
        }
    });
    U.map.addControl( U.controls.toggleFullScreen );
    U.map.on("fullscreenchange", function () {
        // ...can do something...
    });
    
    // fade in
    $( U.controls.toggleFullScreen.getContainer() )
        .css(    {"opacity":0}      )
        .stop()
        .animate({"opacity":1}, opts.fadeInMs);
    
}; // addToggleFullScreen


//-----------------------------------------------------------
// addInsetMap
//   add inset map to map
//   control object created as U.controls.insetMap
//
//   opts - (optional) options, see below for available
//
// EXAMPLE:
// U.map = map;
// U.addInsetMap({"name":"carto_base_light"});
U.addInsetMap = function ( opts ) {
    var funcName = "U [addInsetMap]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map               === undefined) { opts.map               = U.map;         } // leaflet map
    if (opts.name              === undefined) { opts.name              = "openstreets"  } // name of basemap to use for inset map
    if (opts.position          === undefined) { opts.position          = "bottomright"; } // position on map: "topleft", "topright", "bottomleft", "bottomright"
    if (opts.zoomLevelOffset   === undefined) { opts.zoomLevelOffset   = -7;            } // offset applied to the zoom in the minimap compared to the zoom of the main map, can be positive or negative
    if (opts.zoomLevelFixed    === undefined) { opts.zoomLevelFixed    = false;         } // overrides the offset to apply a fixed zoom level to the minimap regardless of the main map zoom
    if (opts.zoomAnimation     === undefined) { opts.zoomAnimation     = true;          } // whether the minimap should have an animated zoom (true causes lag)
    if (opts.toggleDisplay     === undefined) { opts.toggleDisplay     = true;          } // whether the minimap should have a button to minimise it
    if (opts.autoToggleDisplay === undefined) { opts.autoToggleDisplay = false;         } // whether the minimap should hide automatically if parent map bounds does not fit within the minimap bounds (esp. useful when 'zoomLevelFixed' set)
    if (opts.width             === undefined) { opts.width             = 200;           } // width  of the minimap in pixels
    if (opts.height            === undefined) { opts.height            = 150;           } // height of the minimap in pixels
    if (opts.collapsedWidth    === undefined) { opts.collapsedWidth    = 18;            } // width  of the toggle marker and the minimap when collapsed, in pixels
    if (opts.collapsedHeight   === undefined) { opts.collapsedHeight   = 18;            } // height of the toggle marker and the minimap when collapsed, in pixels
    if (opts.fadeInMs          === undefined) { opts.fadeInMs          = 2000;          } // fade in duration when adding to map [milli-sec]
    if (opts.aimingRectOptions === undefined) {
        // style of the "current extent" rectangle (Path.Options object)
        opts.aimingRectOptions = {
            "color"     : "#ff7800",
            "weight"    : 1,
            "clickable" : true
        };
    } 
    if (opts.shadowRectOptions === undefined) {
        // style of the "current extent" shadow rectangle when inset map clicked and dragged (Path.Options object)
        opts.shadowRectOptions = {
            "color"       : "#000000",
            "weight"      : 1,
            "clickable"   : true,
            "opacity"     : 0,
            "fillOpacity" : 0
        };
    }
    U.map = opts.map;
    
    // create basemap for inset map
    var baseUrl = U._private.getBaseUrls(opts.name);
    if (baseUrl.length > 1) { console.warn(funcName + "basemap '" + opts.name + "' has multiple layers - only using 1st layer for inset map"); }
    baseUrl = baseUrl[0];
    var baseTileLayer = new L.TileLayer(
        baseUrl,
        {
            "minZoom" : U.map.getMinZoom() + opts.zoomLevelOffset,
            "maxZoom" : U.map.getMaxZoom()
        }
    );
    
    // create inset map control (L.Control.MiniMap plugin) and add to map
    if (U.controls === undefined) { U.controls = {}; }
    U.controls.insetMap = new L.Control.MiniMap(
        baseTileLayer,
        {
            "position"          : opts.position,
            "toggleDisplay"     : opts.toggleDisplay,
            "zoomLevelOffset"   : opts.zoomLevelOffset,
            "zoomLevelFixed"    : opts.zoomLevelFixed,
            "zoomAnimation"     : opts.zoomAnimation,
            "autoToggleDisplay" : opts.autoToggleDisplay,
            "width"             : opts.width,
            "height"            : opts.height,
            "collapsedWidth"    : opts.collapsedWidth,
            "collapsedHeight"   : opts.collapsedHeight,
            "aimingRectOptions" : opts.aimingRectOptions,
            "shadowRectOptions" : opts.shadowRectOptions
        }
    );
    U.map.addControl( U.controls.insetMap );
    
    // fade in (note: complex - does not fade in well)
    $( U.controls.insetMap.getContainer() )
        .css({"opacity":0})
        .stop()
        .animate({"opacity":1}, opts.fadeInMs);
    
    // set map cursor
    $( U.controls.insetMap.getContainer() ).css({"cursor":"move"});
    
    // set button title
    $(".leaflet-control-minimap-toggle-display").prop("title","Show or hide inset map");
    
    // pan map slightly to make sure inset map is refreshed
    U.map.panBy([1,1]); // 1,1 pixels
    
}; // addInsetMap


//-----------------------------------------------------------
// MAP BASEMAP AND LAYERS
//-----------------------------------------------------------

//-----------------------------------------------------------
// changeBaseMap
//   add or update map basemap layer
//   layerGroup object created as U.layers.basemapLayerGroup
//   only 1 basemapLayerGroup can be on the map at once (adding new removes existing)
//   this should NOT be used if the basemap picker is added to manage basemaps (addBasemapPicker)
//
//   opts - see below
//
//   can also just input basemap "name" (opacity will be default)
//   if no input provided, lists available basemap names
//
// EXAMPLES:
// U.map = map; // specify map
// U.changeBaseMap();                                       // list available basemap names to console
// U.changeBaseMap("carto_base_light");                     // add this basemap with 100% opacity (previously added removed)
// U.changeBaseMap({ name:"carto_base_light", opacity:1 }); // same as above
// U.changeBaseMap({ name:"esri_natgeo", opacity:0.5 });    // add this basemap with 50% opacity (previously added removed)
// U.changeBaseMap("INVALID_NAME");                         // invalid name will default to "openstreets"
// U.changeBaseMap({ opacity:0.5 });                        // set last added basemap opacity 50%
// U.changeBaseMap("none");                                 // remove last added basemap
U.changeBaseMap = function ( opts ) {
    var funcName = "U [changeBaseMap]: ";
    if (opts === undefined) { // list available if no input
        U._private.getBaseUrls();
        return 0;
    }
    console.log(funcName + "");
    
    // if string input, set as basemap name with default opacity
    if (typeof opts === "string") {
        var name = opts;
        opts = {};
        opts.name = name;
    }
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map     === undefined) { opts.map     = U.map;  } // leaflet map
    if (opts.name    === undefined) { opts.name    = "same"; } // basemap name recognized by U._private.getBaseUrls() - omit or set "same" to use existing, set "none" to remove
    if (opts.opacity === undefined) { opts.opacity = 1;      } // opacity, 0 to 1
    U.map = opts.map;
    
    // create basemapLayerGroup if needed
    if (U.layers === undefined) { U.layers = {}; }
    if (U.layers.basemapLayerGroup === undefined) {
        U.layers.basemapLayerGroup = L.layerGroup();
        U.layers.basemapLayerGroup.addTo( U.map );
    }
    
    // handle "same" - apply opts to layerGroup
    if (opts.name.toLowerCase() === "same") { 
        U.layers.basemapLayerGroup.eachLayer( function (layer) {
            layer.setOpacity( opts.opacity );
            layer.bringToFront();
        });
        return 0; // done
    }
    
    // clear layerGroup
    U.layers.basemapLayerGroup.clearLayers();
    
    // if "none", we are done
    if (opts.name.toLowerCase() === "none") { return 0; }
    
    // add new
    $.each( U._private.getBaseUrls(opts.name), function( idx, url ) {
        U.layers.basemapLayerGroup.addLayer(
            L.tileLayer( url, {"opacity":opts.opacity} )
        );
    });
    
    // bring to top of map
    U.layers.basemapLayerGroup.eachLayer( function(layer) {
        layer.bringToFront();
    });
    
}; // changeBaseMap


//-----------------------------------------------------------
// addReferenceMap
//   add reference layer to map
//   layer object created as U.layers.referenceLayerGroup
//   new refence layers are appended to the referenceLayerGroup
//   see opts for clearing previously added reference layers
//   this should NOT be used if the basemap picker is added to manage reference layers (addBasemapPicker)
//
//   opts - see below
//
//   note: opts.name must be one of
//          "nationalmap_contours"     : elevation contours
//          "nationalmap_fills"        : green national forest areas, blue water areas, etc
//          "nationalmap_small"        : transportation. borders, cities, waterbodies
//          "esri_cites_borders_dark"  : cities and boundaries - dark  labels
//          "esri_cites_borders_light" : cities and boundaries - light labels
//          "esri_reference"           : lots of stuff
//          "esri_transportation"      : roads, etc.
//
//   can also just input reference map "name" (opacity will be default)
//   if no input provided, lists available reference map names
//
// EXAMPLES:
// U.map = map; // specify map
// U.addReferenceMap("nationalmap_contours");                                       // add this eference layer with 100% opacity
// U.addReferenceMap({ name:"nationalmap_contours", opacity:1 });                   // same as above
// U.addReferenceMap({ name:["nationalmap_fills","esri_reference"], opacity:0.5 }); // add these 2 reference layers with 50% opacity, keep any previously added
// U.addReferenceMap({ name:"nationalmap_small", clear:true });                     // add this eference layer with 100% opacity, clear any previously added
// U.addReferenceMap({ clear:true });                                               // add no eference layer but clear any previously added
U.addReferenceMap = function ( opts ) {
    var funcName = "U [addReferenceMap]: ";
    var validNames = [
        "nationalmap_small",
        "nationalmap_contours",
        "nationalmap_fills",
        "esri_cites_borders_light",
        "esri_cites_borders_dark",
        "esri_reference",
        "esri_transportation"
    ];
    if (opts === undefined) { // list available if no input
        console.log(funcName + "available reference maps:");
        $.each( validNames, function( idx, validName ){
            console.log(validName);
        });
        return 0;
    }
    console.log(funcName + "");
    
    // if string input, set as basemap name
    if (typeof opts === "string") {
        var name = opts;
        opts = {};
        opts.name = name;
    }
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map     === undefined) { opts.map     = U.map; } // leaflet map
    if (opts.name    === undefined) { opts.name    = "";    } // one of above validNames (string) or array of validNames - if omitted no reference layer added
    if (opts.opacity === undefined) { opts.opacity = 1;     } // opacity of added layer, 0 to 1
    if (opts.clear   === undefined) { opts.clear   = false; } // whether to clear all reference layers previously added with this function
    U.map = opts.map;
    
    // create referenceLayerGroup if needed
    if (U.layers === undefined) { U.layers = {}; }
    if (U.layers.referenceLayerGroup === undefined) {
        U.layers.referenceLayerGroup = L.layerGroup();
        U.layers.referenceLayerGroup.addTo( U.map );
    }
    
    // clear if specified
    if (opts.clear === true) {
        U.layers.referenceLayerGroup.clearLayers();
    }
    
    // if no "name", we are done
    if (opts.name === "") { return 0; }
    
    // convert name to array if needed
    if (typeof opts.name === "string") {
        opts.name = [ opts.name ];
    }
    
    // make sure name(s) are valid
    var badName = "";
    $.each( opts.name, function( idx, name ){
        if ( $.inArray(name,validNames) <= -1) {
            badName = name;
            return;
        }
    });
    if ( badName !== "") {
        console.warn(funcName + "invalid reference map name: '" + badName + "'");
        console.warn(funcName + "valid reference map names are:");
        $.each( validNames, function( idx, validName ){
            console.warn(validName);
        });
        return 1;
    }
    
    // add layer(s) to layerGroup
     $.each( opts.name, function( idx, name ) {
        U.layers.referenceLayerGroup.addLayer(
            L.tileLayer(
                U._private.getBaseUrls(name)[0], // all reference layers just have 1 url
                { "opacity" : opts.opacity }
            )
        );
    });
    
    // bring to top of map
    U.layers.referenceLayerGroup.eachLayer( function(layer) {
        layer.bringToFront();
    });
    
}; // addReferenceMap


//-----------------------------------------------------------
// addEsriTiledMapLayer
//   add ESRI tiled map layer(s) to the map as a layer group
//   returns the layerGroup
//
//   urls - array of 1 ['url1'] or more ['url1',url2',...] url(s) to the tiled map service(s)
//   opts - (optional) can contain the following (all optional):
//             opts.opacity - opacity to set for layers, 0.0 to 1.0
//
// EXAMPLES:
// U.map = map; // specify map
// var tiledMapLayer;
// tiledMapLayer = U.addEsriTiledMapLayer(["http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"]);               // add imagery tiled layer (100% opacity)
// tiledMapLayer = U.addEsriTiledMapLayer(["http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"],{opacity:0.5}); // add imagery tiled layer ( 50% opacity)
// tiledMapLayer = U.addEsriTiledMapLayer([ // add imagery and labels tiled layer (75% opacity)
//     "http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer",
//     "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer"
// ],{opacity:0.5});
// map.removeLayer(tiledMapLayer); // remove layer
U.addEsriTiledMapLayer = function (urls,opts) {
    var funcName = "U [addEsriTiledMapLayer]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map     === undefined) { opts.map     = U.map; } // leaflet map
    if (opts.opacity === undefined) { opts.opacity = 1;     } // opacity, 0 to 1
    U.map = opts.map;
    
    // create layer group and add to map
    var layerGroup = L.layerGroup();
    $.each( urls, function( idx, url ) {
        layerGroup.addLayer(
            L.esri.tiledMapLayer(
                url,
                {
                    "opacity" : opts.opacity
                }
            )
        );
    });
    layerGroup.addTo( U.map );
    return layerGroup;
    
}; // addEsriTiledMapLayer


//-----------------------------------------------------------
// addEsriDynamicMapLayer
//   add ESRI layer(s) from a dynamic map service to the map
//   returns the layer
//
//   url  - single url to the dynamic map service
//   idxs - array of 0-based indeces of the service layers to add
//   opts - (optional) can contain the following (all optional):
//             opts.opacity - opacity to set for layers, 0.0 to 1.0
//
// EXAMPLES:
// U.map = map; // specify map
// var tiledMapLayer;
// dynamicMapLayer = U.addEsriDynamicMapLayer("http://txpub.usgs.gov/arcgis/rest/services/GAT/GeologicDatabaseOfTexas250K/MapServer",[0]);                  // add layers [0]   layer   (100% opacity)
// dynamicMapLayer = U.addEsriDynamicMapLayer("http://txpub.usgs.gov/arcgis/rest/services/GAT/GeologicDatabaseOfTexas250K/MapServer",[0,10],{opacity:0.5}); // add layers [0,10] layers ( 50% opacity)
// map.removeLayer(dynamicMapLayer); // remove layer
U.addEsriDynamicMapLayer = function (url,idxs,opts) {
    var funcName = "U [addEsriDynamicMapLayer]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map     === undefined) { opts.map     = U.map; } // leaflet map
    if (opts.opacity === undefined) { opts.opacity = 1;     } // opacity, 0 to 1
    U.map = opts.map;
    
    // add to map
    var layer = L.esri.dynamicMapLayer(
        url,
        {
            "layers"  : [idxs],
            "opacity" : opts.opacity
        }
    );
    layer.addTo( U.map );
    return layer;
    
    // !!! WANT TO WAIT TO RETURN LAYER UNTIL LOADED
    
}; // addEsriDynamicMapLayer


//-----------------------------------------------------------
// MAP MARKERS
//-----------------------------------------------------------

//-----------------------------------------------------------
// addPntMarker
//   general function to add point marker to the map with optional popup
//
//   latLng - coordinate, eg: [lat, lng]
//   opts   - see below
//
// EXAMPLES:
// U.map = map; // specify map
// U.addPntMarker([30,-90],{"markerColor":"darkred", "icon":"home", "spin":true, "popupHtml":"A red, spinning home marker"});
U.addPntMarker = function (latLng,opts) {
    var funcName = "U [addPntMarker]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map          === undefined) { opts.map          = U.map;       } // leaflet map
    if (opts.markerColor  === undefined) { opts.markerColor  = "cadetblue"; } // marker color: 'red', 'darkred', 'orange', 'green', 'darkgreen', 'blue', 'purple', 'darkpuple', 'cadetblue'
    if (opts.icon         === undefined) { opts.icon         = "";          } // name of the icon, set blank for none (default) or see http://fortawesome.github.io/Font-Awesome/icons/ for available names
    if (opts.iconColor    === undefined) { opts.iconColor    = "white";     } // icon color, "white", "black" or css code (hex, rgba etc)
    if (opts.spin         === undefined) { opts.spin         = false;       } // whether to animate the icon with rotation
    if (opts.extraClasses === undefined) { opts.extraClasses = "";          } // additional css classes to apply, omit or set "" for none
    if (opts.popupHtml    === undefined) { opts.popupHtml    = "";          } // text or html for popup, omit or set "" for no popup
    U.map = opts.map;
    
    // create new marker layer group if needed
    if (U.layers === undefined) { U.layers = {}; };
    if (U.layers.markers === undefined) {
        U.layers.markers = new L.FeatureGroup();
        U.map.addLayer(U.layers.markers);
    }
    
    // create marker
    var marker = L.marker( latLng, {
        "clickable" : (opts.popupHtml !== ""), // clickable if have popupHtml
        "icon" : L.AwesomeMarkers.icon({
            "prefix"       : "fa", // fixed - using Font Awesome
            "markerColor"  : opts.markerColor,
            "icon"         : opts.icon,
            "iconColor"    : opts.iconColor,
            "spin"         : opts.spin,
            "extraClasses" : opts.extraClasses
        })
    });
    
    // add popup
    if (opts.popupHtml !== "") {
        opts.popupHtml =
            "<div class='popup-container'>" + opts.popupHtml + "</div>" +
            "<div class='popup-actions'>[<a href='#' onclick='javascript: U.map.setView( ["+latLng[0]+","+latLng[1]+"], U.map.getMaxZoom(), {animate:true} ); void(0);'>Zoom To</a>]</div>";
        marker.bindPopup( opts.popupHtml, U._private.popupOpts );
    }
    
    // add to map
    U.layers.markers.addLayer(marker);
    
}; // addPntMarker


//-----------------------------------------------------------
// addInfoMarker
//   shortcut to add point info marker to the map (blue with info icon)
//
//   latLng    - coordinate, eg: [lat, lng]
//   popupHtml - popup content
//
// EXAMPLES:
// U.map = map; // specify map
// U.addInfoMarker([31,-91],"An info marker");
U.addInfoMarker = function (latLng,popupHtml) {
    var funcName = "U [addInfoMarker]: ";
    console.log(funcName + "");
    
    // add info marker
    U.addPntMarker( latLng, {
        "markerColor"  : "blue",
        "icon"         : "info",
        "iconColor"    : "white",
        "spin"         : false,
        "extraClasses" : "",
        "popupHtml"    : popupHtml
    });
}; // addInfoMarker

// !!! REWORK addInfoMarker, addChartMarker, addImgMarker to use opts:
// * use input opts:
//    type   (optional - line)
//    latLng (required)
//    caption (optional)
//    thumbUrl
//    XXX
//  
// !!! ADD fullImgUrl OPTION LIKE IMAGE MARKER ???
//-----------------------------------------------------------
// addChartMarker
//   shortcut to add point chart marker to the map (red with chart icon)
//
//   latLng    - coordinate, eg: [lat, lng]
//   popupHtml - popup content
//   type      - chart icon type, one of:
//                 "line" [default]
//                 "area"
//                 "bar"
//                 "pie"
//
// EXAMPLES:
// U.map = map; // specify map
// U.addChartMarker([32,-92],"<img src='chart.png'/><br/>A pie chart marker","pie");
U.addChartMarker = function (latLng,popupHtml,type) {
    var funcName = "U [addChartMarker]: ";
    console.log(funcName + "");
    
    // add chart marker
    U.addPntMarker( latLng, {
        "markerColor"  : "red",
        "icon"         : (type === undefined ? "line" : type) + "-chart",
        "iconColor"    : "white",
        "spin"         : false,
        "extraClasses" : "",
        "popupHtml"    : popupHtml
    });
}; // addChartMarker


//-----------------------------------------------------------
// addImgMarker
//   add image marker to the map
//
//   latLng - coordinate, eg: [lat, lng]
//   opts   - see below
//
// EXAMPLES:
// XXX
U.addImgMarker = function (latLng,opts) {
    var funcName = "U [addImgMarker]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.popupHtml       === undefined) { opts.popupHtml      = "";    } // popup content, including <img> tag, caption text, etc.
    if (opts.fullImgUrl      === undefined) { opts.fullImgUrl     = "";    } // url to full-sized image, when input a "Full Size" link is added that shows the image as an overlay when clicked
    if (opts.fullImgCaption  === undefined) { opts.fullImgCaption = "";    } // caption for the full size overlay image
    
    // create new marker layer group if needed
    if (U.layers === undefined) { U.layers = {}; };
    if (U.layers.markers === undefined) {
        U.layers.markers = new L.FeatureGroup();
        U.map.addLayer(U.layers.markers);
    }
    
    // set zoomTo function string
    var zoomToFncStr = 'javascript: U.map.setView( ['+latLng[0]+','+latLng[1]+'], U.map.getMaxZoom(), {animate:true} ); void(0);';
    
    // markup popupHtml
    if ( opts.fullImgUrl === "" ) {
        // no [Full Size] link
        opts.popupHtml =
            "<div class='popup-container'>" + opts.popupHtml + "</div>" +
            "<div class='popup-actions'>[<a href='#' onclick='"+zoomToFncStr+"'>Zoom To</a>]</div>";
    } else {
        // with [Full Size] link
        
        // add to images list for slide show
        if (U.slideshow === undefined) { U.slideshow = {}; };
        var idx = Object.keys( U.slideshow ).length;
        U.slideshow[idx] = {
            "idx"     : idx,
            "latLng"  : latLng,
            "url"     : opts.fullImgUrl,
            "caption" : opts.fullImgCaption
        };
        
        // set full size link callback
        var fullSzFncStr =
            'javascript: ' +
            'U.map.closePopup(); ' +
            'U.disableUI({ ' +
                'imgUrl    : "' + opts.fullImgUrl + '", ' +
                'imgCss    : {"border":"10px solid white"}, ' +
                'caption   : "' + opts.fullImgCaption + '",' +
                'slideshow : true, ' +
                'close     : true ' +
            '}); ' +
            'void(0);';
        
        // set html
        opts.popupHtml =
            "<div class='popup-container'>" + opts.popupHtml + "</div>" +
            "<div class='popup-actions'>[<a href='#' onclick='"+fullSzFncStr+"'>Full Size</a>]&nbsp;&nbsp;&nbsp;[<a href='#' onclick='"+zoomToFncStr+"'>Zoom To</a>]</div>";
    }
    
    // add marker
    U.layers.markers.addLayer(
        L.marker(
            latLng,
            { "icon" : U._private.imgMarkerIcon }
        ).bindPopup(
            opts.popupHtml,
            U._private.popupOpts
        )
    );
    
}; // addImgMarker


//-----------------------------------------------------------
// clearMarkers
//   clear all markers (all types) from the map
//
// EXAMPLES:
// U.clearMarkers();
U.clearMarkers = function () {
    var funcName = "U [clearMarkers]: ";
    console.log(funcName + "");
    // clear layers
    if ((U.layers !== undefined) && (U.layers.markers !== undefined)) {
        U.layers.markers.clearLayers();
    }
    // clear slideshow images
    U.slideshow = {};
}; // clearMarkers


//-----------------------------------------------------------
// MAP EXTENT
//-----------------------------------------------------------

//-----------------------------------------------------------
// zoomMarkers
//   zoom map to contain all markers (all types) currently on the map
//
//   opts   - see below
//
// EXAMPLES:
// U.zoomMarkers(map);
U.zoomMarkers = function (opts) {
    var funcName = "U [zoomMarkers]: ";
    console.log(funcName + "");
    
    // set opts defaults
    if (opts === undefined) { opts = {}; }
    if (opts.map      === undefined) { opts.map      = U.map;   } // leaflet map
    if (opts.reset    === undefined) { opts.reset    = false;   } // true: the map view will be completely reset (without any animations)
    if (opts.animate  === undefined) { opts.animate  = true;    } // animate pan/zoom if possible
    if (opts.duration === undefined) { opts.duration = 0.25;    } // duration of animated panning [seconds]
    if (opts.padding  === undefined) { opts.padding  = [10,10]; } // top left and bottom right padding [px]
    if (opts.maxZoom  === undefined) { opts.maxZoom  = 999;     } // maximum possible zoom to use
    U.map = opts.map;
    
    // zoom to markers
    if ((U.layers !== undefined) && (U.layers.markers !== undefined)) {
        U.map.fitBounds( U.layers.markers.getBounds(), opts );
    }
}; // zoomMarkers


//-----------------------------------------------------------
// resetZoomHomeExtent
//   reset the zoom home button extent
//
//   bounds - (optional) new extent bounds, set to current map extent if omitted
//
// EXAMPLES:
// U.resetZoomHomeExtent(); // reset to current map extent
// U.resetZoomHomeExtent( [[40.712,-74.227],[40.774, -74.125]] ); // reset to this southWest - northEast extent
U.resetZoomHomeExtent = function ( bounds ) {
    var funcName = "U [resetZoomHomeExtent]: ";
    console.log(funcName + "");
    
    if ( !U.controls || !U.controls.zoomHome) {
        console.warn(funcName + "zoomHome control does not exist - cannot reset");
        return 0;
    }
    setTimeout( function() {
        if (bounds === undefined) {
            U.controls.zoomHome.options.homeGeom = U.map.getBounds(); // current map extent
        } else {
            U.controls.zoomHome.options.homeGeom = L.latLngBounds(bounds[0],bounds[1]); // input
        }
    }, 1000);
    
}; // resetZoomHomeExtent


//-----------------------------------------------------------
// INTERFACE UTILS
//-----------------------------------------------------------

//-----------------------------------------------------------
// popupWindow
//   launch 'url' in browser popup window with width 'w' and height 'h'
//   returns window opened
U.popupWindow = function( url, w, h ) {
    
    // // add time-stamp parm to force load from server (not browser cache)
    // if (url.match(/\?/)) {
        // // has a '?' parm - add at end with '&'
        // url = url + "&_t=" + (+new Date);
    // } else {
        // // no '?' parm - add at end with '?'
        // url = url + "?_t=" + (+new Date);
    // }
    
    // get the left-right window positions based on the window dimensions
    var wLeft = window.screenLeft ? window.screenLeft : window.screenX;
    var wTop  = window.screenTop  ? window.screenTop  : window.screenY;
    var left  = wLeft + (window.innerWidth  / 2) - (w / 2);
    var top   = wTop  + (window.innerHeight / 2) - (h / 2);
    
    // set the top-left position string to use
    var top_left = ""; // default: don't include and let browser decide
    if ( Number(left) && Number(top) ) {
        // browser recognizes the window properties use to compute
        top_left = ",top=" + Math.floor(top) + "," + "left=" + Math.floor(left);
    }
    
    // popup the window
    var myWindow = window.open(
        url,
        "_blank",
        // ...options...
        "toolbar=no,"       + // whether or not to display the browser toolbar (default=yes)
        "location=no,"      + // whether or not to display the address field (default=yes)
        "directories=no,"   + // whether or not to add directory buttons (default=yes, IE ONLY)
        "status=no,"        + // whether or not to add a status bar (default=yes)
        "menubar=no,"       + // whether or not to display the menu bar (default=yes)
        "scrollbars=yes,"   + // whether or not to display scroll bars (default=yes)
        "resizable=yes,"    + // whether or not the window is resizable (default=yes)
        "copyhistory=no,"   + // ???
        "width="  + w + "," + // width  of window in pixels (min values are 100)
        "height=" + h       + // height of window in pixels (min values are 100)
        top_left              // top and left position of the window in pixels
    );
    myWindow.focus();
    
    // return the window
    return myWindow;
    
}; // popupWindow

//-----------------------------------------------------------
// userAlert
//   display a jQuery dialog containing a "msg", "title", and "OK" button.
//   optionally has a "Do not show again" checkbox.
//
// INPUT:
//   "noShowDlgFlagName"
//      set undefined to NOT include the "Do not show again" checkbox option.
//      the dialog will always appear when called.
//
//      set to one of the "U._private.noShowDlgFlags" (name of field, string) to include the "Do not show again" option.
//      if the user checks the box, the dialog will not be shown again.
//      (no cookies are used - visiting the site again resets the flags)
//
//   "msg"
//      dialog content, can be:
//      * string
//      * array of strings (each element will be a paragraph in the dialog)
//      use <a href="XXX"> tags in "msg" to hyperlink.
//
//   "title"
//     dialog title (string)
//     set "Walker Basin Hydro Mapper" if not input
U.userAlert = function (noShowDlgFlagName,msg,title) {
    var funcName = "main [userAlert]: ";
    
    // do nothing if the noShowDlgFlagName is true (or undefined)
    if (U._private.noShowDlgFlags[noShowDlgFlagName] === true) { return 0; }
    
    // set title blank if not input
    if (title === undefined)  { title = "Story Map" }; // can't be "", need string to size titlebar
    
    // convert to array of strings if only a string was input
    if (typeof msg === "string") { msg = [msg]; }
    
    // create dialog div if doesn't exist
    if ( $("#jquery-dialog-content").length <= 0 ) { $("body").append("<div id='jquery-dialog-content'></div>"); }
    
    // add message and setup dialog
    $("#jquery-dialog-content")
        .html(
            "<p class='ui-dialog-text'>" + msg.join("</p><p class='ui-dialog-text'>") + "</p>" // break string array into content paragraphs
        )
        .dialog({
            "title"         : title,
            "minHeight"     : 0,       // px if number [default: 78px]
            "closeOnEscape" : true,    // allow ESC keypress to close [default: true]
            "closeText"     : "Close", // hover title of [X] close button [default: "close"]
            //"dialogClass" : "alert", // name of class to add for additional styling (eg: "query-dialog-alert")
            "draggable"     : true,    // default: true
            "resizable"     : true,    // default: true
            "show"          : { "effect":"fade", "duration":U._private.animateMs }, // show animation mode
            "hide"          : { "effect":"fade", "duration":U._private.animateMs }, // hide animation mode
            
            "modal"     : true,  // grey out browser screen and do not allow other page interaction
            "autoOpen"  : false, // don't open yet
            
            // buttons and callbacks
            "buttons" : {
                "OK": function() { $(this).dialog("close"); }
            },
            
            // dialog open event callback
            "open" : function(){
                // fade in modal overlay when opened
                $(".ui-widget-overlay").hide().fadeIn(U._private.animateMs);
            },
            
            // dialog before-close event callback
            "beforeClose" : function(){
                $(".ui-widget-overlay:first")
                    // fade out modal overlay before closing
                    // can't do this in the "close" event because ".ui-widget-overlay" is removed
                    // cloning it before it is removed and fade the clone out
                    .clone()
                    .appendTo("body")
                    .show()
                    .fadeOut(U._private.animateMs, function(){ 
                        $(this).remove(); 
                    });
            }
        });
        
    // see if we need to add "Do not show again" checkbox
    $("#ui_dialog_myCheckbox").remove(); // need to remove always in case it was added previously
    if ( noShowDlgFlagName !== undefined )  {
        // make sure the flag is defined (bug check)
        if (U._private.noShowDlgFlags[noShowDlgFlagName] === undefined) {
            console.error(funcName + "input 'noShowDlgFlagName' is not defined in 'U._private.noShowDlgFlags' - you need to define it");
            return 1;
        }
        
        // add div at bottom with checkbox if specified
        // checking checkbox sets the "noShowDlgFlagName" flag to the checked state
        $(".ui-dialog").append(
            '<div id="ui_dialog_myCheckbox" class="ui-dialog-myCheckbox">' +
                '<input type="checkbox" onclick="javascript: U._private.noShowDlgFlags[\''+noShowDlgFlagName+'\']=this.checked;"/>' +
                '&nbsp;Do not show this again' +
            '</div>'
        );
    }
    
    // open dialog
    $("#jquery-dialog-content").dialog("open");
    
}; // userAlert


//-----------------------------------------------------------
// disableUI
//   main funciton to enable/disable interface with options
//
//   opts - see below
U.disableUI = function ( opts ) {
    var funcName = "U [disableUI]: ";
    var isDisabled = ($("#disableOverlay").length > 0);    // overlay already shown?
    
    // set opts
    if (opts === undefined) { opts = {}; }
    if (opts.disable   === undefined) { opts.disable   = !isDisabled;          } // show or hide image overlay, toggled if omitted
    if (opts.imgUrl    === undefined) { opts.imgUrl    = "";                   } // url to image to show centered in screen (none shown if omitted)
    if (opts.imgCss    === undefined) { opts.imgCss    = {"border":"none"};    } // css object to apply to image
    if (opts.caption   === undefined) { opts.caption   = "";                   } // optional caption text to add under optional image
    if (opts.slideshow === undefined) { opts.slideshow = false;                } // whether to ad slideshow controls (using U.slideshow) when showing an image
    if (opts.close     === undefined) { opts.close     = true;                 } // whether to add a close button under image to close image and enable 
    if (opts.animateMs === undefined) { opts.animateMs = U._private.animateMs; } // fade in-out animation time [ms]
    if (opts.addClass  === undefined) { opts.addClass  = ""                    } // class to add to the overlay
    
    // enable or disable
    if (opts.disable === true) {
        // disable:
        
        // do nothing if already disabled
        if (isDisabled === true) { return 0; }
        
        // remove any previous overlays
        if ($("#disableOverlay"   ).length > 0)  { $("#disableOverlay" ).remove(); }
        if ($("#imgOverlay"       ).length > 0)  { $("#imgOverlay"     ).remove(); }
        
        // fade in disable overlay
        $( '<div id="disableOverlay" class="ui-widget-overlay"></div>' )
            .hide()
            .appendTo(
                $("body")
            )
            .addClass( opts.addClass )
            .stop()
            .fadeIn( opts.animateMs );
        
        // add centered image if needed
        if ( opts.imgUrl !== "" ) {
            // add image div
            $(
                '<div id="imgOverlay">' +
                    '<img src="'+opts.imgUrl+'"/>' +
                    '<div class="imgOverlay-caption">' + opts.caption +'</div>' +
                '</div>'
            )
                .css({
                    "visibility" : "hidden",
                    "position"   : "absolute",
                    "top"        : 0,
                    "left"       : 0,
                    "height"     : "100%",
                    "width"      : "100%",
                    "z-index"    : 1000
                })
                .appendTo(
                    $("body")
                );
            
            // add controls
            if ((U.slideshow === undefined) || (Object.keys( U.slideshow ).length < 1)) { opts.slideshow = false; } // can't do slideshow
            var controls = $('<div id="disableUIcontrols"></div>');
            if ( opts.slideshow ) {
                controls.append(
                    '<div id="disableUIprev" class="disableUI-button">Previous Image</div>' +
                    '<div id="disableUInext" class="disableUI-button">Next Image</div>' +
                    '<div id="disableUImap"  class="disableUI-button">Go to Map Point</div>'
                );
            }
            if (opts.close) {
                controls.append(
                    '<div id="disableUIclose" class="disableUI-button">Close</div>'
                );
            }
            if (opts.slideshow || opts.close) {
                // function to find currently display image record in fullImgs
                var findImgIdx = function() {
                    var imgIdx     = undefined;
                    var currImgUrl = $("#imgOverlay img").attr("src");
                    $.each( Object.keys( U.slideshow ).sort(), function( idx, val ){
                        if ( U.slideshow[val].url === currImgUrl ) {
                            imgIdx = val;
                            return;
                        }
                    });
                    return parseFloat(imgIdx);
                };
                // add controls to overlay
                controls.appendTo( $("#imgOverlay") );
                // set callbacks
                $("#disableUIprev").click( function() {
                    var newIdx = findImgIdx() - 1; // current index - 1
                    if ( newIdx < 0 ) { newIdx = 0; } // wrap back to last
                    $("#imgOverlay img").stop().fadeOut(500, function() {
                        $("#imgOverlay .imgOverlay-caption").html( U.slideshow[newIdx].caption );
                        $(this)
                            .attr("src",U.slideshow[newIdx].url)
                            .stop().fadeIn(500);
                    });
                });
                $("#disableUInext").click( function() {
                    var newIdx = findImgIdx() + 1; // current index + 1
                    if ( newIdx > Object.keys( U.slideshow ).length-1 ) { newIdx = 0; } // wrap back to 1st
                    $("#imgOverlay img").stop().fadeOut(500, function() {
                        $("#imgOverlay .imgOverlay-caption").html( U.slideshow[newIdx].caption );
                        $(this)
                            .attr("src",U.slideshow[newIdx].url)
                            .stop().fadeIn(500);
                    });
                });
                $("#disableUImap").click( function() {
                    U.disableUI({disable:false}); // close disable
                    U.map.setView( U.slideshow[findImgIdx()].latLng, U.map.getMaxZoom(), {"animate":true} ); // zoom map to current img latLng
                });
                $("#disableUIclose").click( function() {
                    U.disableUI({disable:false}); // close disable
                });
            }
            
            // setup then fade in all
            $("#imgOverlay img")
                .css( opts.imgCss )
                .load( function () {
                    // center image when loaded then fade in
                    var H = $("#imgOverlay img").height();
                    var W = $("#imgOverlay img").width();
                    var Hmax = 0.85*$(window).innerHeight() - 80;
                    var Wmax = 0.85*$(window).innerWidth();
                    if (H > Hmax) { // height too big for screen
                        var scale = Hmax/H;
                        H = scale * H;
                        W = scale * W;
                    }
                    if (W > Wmax) { // width too big for screen
                        var scale = Wmax/W;
                        W = scale * W;
                        H = scale * H;
                    }
                    $("#imgOverlay").css({
                        "position"    : "absolute",
                        "height"      : Math.round(H),
                        "width"       : Math.round(W),
                        "top"         : "45%",
                        "left"        : "50%",
                        "margin-top"  : "-"+Math.round(H/2)+"px",
                        "margin-left" : "-"+Math.round(W/2)+"px"
                    });
                    $("#imgOverlay img").css({
                        "height"      : Math.round(H),
                        "width"       : Math.round(W),
                        "margin"      : "0px",
                        "padding"     : "0px"
                    });
                    $("#imgOverlay .imgOverlay-caption").css({
                        "background"    : "rgba(255,255,255,0.5)",
                        "font-family"   : "Arial, Helvetica, sans-serif",
                        "font-size"     : "15px",
                        "padding"       : "5px",
                        "margin"        : "0 0 5px 0",
                        "width"         : Math.round(W) + 10,
                        "min-height"    : "0px",
                        "max-height"    : "80px",
                        "overflow"      : "auto",
                    })
                    $("#disableUIcontrols").css({
                        "width":Math.round(W) + 20
                    });
                    if ( $("#imgOverlay").css("visibility") === "hidden" ) {
                        $("#imgOverlay").hide().css({"visibility":"visible"}).stop().fadeIn( opts.animateMs );
                    }
            });
        }
        
    } else {
        // enable:
        
        // do nothing if already enabled
        if (isDisabled === false) { return 0; }
        
        // fade out overlay(s) then remove
        if ($("#disableOverlay").length > 0) {
            $("#disableOverlay")
                .stop()
                .fadeOut( opts.animateMs, function(){ 
                    $(this).remove(); 
                });
        }
        if ($("#imgOverlay").length > 0) {
            $("#imgOverlay")
                .stop()
                .fadeOut( opts.animateMs, function(){ 
                    $(this).remove(); 
                });
        }
    }
    
}; // disableUI


//-----------------------------------------------------------
// disableLoading
//   convienience function to disable/enable interface with animated loading image
//   "disable" = true    : disable
//   "disable" = false   : enable
//   "disable" not input : toggle (disable if enabled and vice-versa)
U.disableLoading = function ( disable ) {
    var isDisabled = ( $("#disableOverlay.disableLoading").length > 0 ); // already disabled with loading image?
    if (disable === undefined) { disable = !isDisabled; }  // toggle if not input
    U.disableUI({
        "disable"  : disable,
        "imgUrl"   : U._private.rootPath + "img/loading.gif",
        "close"    : false,
        "addClass" : "disableLoading"
    });
}; // disableLoading


//-----------------------------------------------------------
// startSlideShow
//   convienience function to start slide show of currently set slide images (U.slideshow)
//   "idx" is starting index (set to 0 if none)
U.startSlideShow = function ( idx ) {
    if (idx === undefined) { idx = 0; }
    if (U.slideshow === undefined) {
        console.warn("there is no U.slideshow object of slide images - doing nothing");
        return 0;
    }
    if (idx > Object.keys(U.slideshow).length-1) { idx = Object.keys(U.slideshow).length-1; } // reset to last
    U.map.closePopup();
    U.disableUI({
        "imgUrl"    : U.slideshow[idx].url,
        "imgCss"    : {"border":"10px solid white"},
        "caption"   : U.slideshow[idx].caption,
        "slideshow" : true,
        "close"     : true
    });
}; // startSlideShow


//-----------------------------------------------------------
// MISC
//-----------------------------------------------------------

//-----------------------------------------------------------
// addUsgsFavicon
//   add USGS favicon to document
U.addUsgsFavicon = function () {
    var funcName = "U [addUsgsFavicon]: ";
    console.log(funcName + "");
    $("head").append("<link rel='icon' type='image/x-icon' href='" + U._private.rootPath + "img/favicon.png' />");
    $("head").append("<link rel='icon' type='image/png'    href='" + U._private.rootPath + "img/favicon.png' />");
}; // addUsgsFavicon


//-----------------------------------------------------------
// addTooltips
//   create jQuery tooltips
//
//   parentElem - (optional) jQuery selector or id (string) of parent element to add tooltips to (tooltips added to entire document if omitted)
U.addTooltips = function ( parentElem ) {
    var funcName = "U [addTooltips]: ";
    console.log(funcName + "");
    var selector = $(document);
    // if (parentElem !== undefined) { selector = $("#"+parentElem); }
    if (parentElem !== undefined) {
        if (typeof parentElem === "string") {
            selector = $("#"+parentElem);
        } else {
            selector = parentElem;
        }
    }
    selector.tooltip({
        "content" : function(callback) {
            // enable html markup
            callback( $(this).prop("title") );
        },
        "show": {
            // fade in after mouse hovers for a delay
            "effect" : "fadeIn",
            "delay"  : 400
        },
        "hide": {
            // fade out immediately when mouse leaves
            "effect" : "fadeOut",
            "delay"  : 0
        },
        "open" : function(evt,ui) {
            $(".ui-tooltip").not(ui.tooltip).stop().hide(); // close all others in case previous ones are stuck
            setTimeout( function() { ui.tooltip.stop().fadeOut(400); }, 5000); // set timeout so this one doesn't get stuck
            ui.tooltip.click( function() { $(this).stop().fadeOut(200); } );   // close this tooltip when clicked
        }
    });
    
}; // addTooltips


//-----------------------------------------------------------
// noDragSelect
//   make elements non-mouse-drag-select (eg: click-drag on text does not hightlight)
//
//   parentElem - (optional) jQuery selector or id (string) of parent element (entire document used if omitted)
U.noDragSelect = function ( parentElem ) {
    var funcName = "U [noDragSelect]: ";
    console.log(funcName + "");
    var selector = $(document);
    if (parentElem !== undefined) {
        if (typeof parentElem === "string") {
            selector = $("#"+parentElem);
        } else {
            selector = parentElem;
        }
    }
    selector.add(selector.find("*")).addClass("click-drag-unselectable");
}; // noDragSelect


//-----------------------------------------------------------
// okDragSelect
//   make elements mouse-drag-selectable (eg: click-drag on text hightlights)
//
//   parentElem - (optional) jQuery selector or id (string) of parent element (entire document used if omitted)
U.okDragSelect = function ( parentElem ) {
    var funcName = "U [okDragSelect]: ";
    console.log(funcName + "");
    var selector = $(document);
    if (parentElem !== undefined) {
        if (typeof parentElem === "string") {
            selector = $("#"+parentElem);
        } else {
            selector = parentElem;
        }
    }
    selector.add(selector.find("*")).removeClass("click-drag-unselectable");
}; // okDragSelect


//-----------------------------------------------------------
// loadJsCss
//   load external script(s) and/or style sheet(s) into the document
//   input "urls" is string array of urls: [ 'url1.css', 'url2.js', ... ]
//   .js extension will load as script, .css extension will load as css
//   loads in order given
//   does not load next until 1st is loaded so scripts/css that depend on other scripts/css being loaded 1st (eg: jQuery & jQuery UI) can be handled
//   optional 2nd arg "doneFunc" is function to execute when all are loaded (does nothing if not input)
//
//   urls     - array of .js and/or .cc url(s)
//   doneFunc - (optional) function to execute after all urls are loaded
U.loadJsCss = function ( urls, doneFunc ) {
    var funcName = "U [loadJsCss]: ";
    if (urls.length <= 0) {
        // done with all - execute function if given
        if (typeof doneFunc === "function") {
            console.log(funcName + "done loading - executing doneFunc");
            $( document ).ready(function() {
                doneFunc();
            });
        } else {
            console.log(funcName + "done loading - no doneFunc to execute");
        }
        return 0;
    };
    var url = urls.shift(); // get the 1st and remove from list
    
    // load current js or css
    if ( url.toLowerCase().indexOf(".css", url.length - ".css".length) !== -1 ) {
        // ends with .css
        console.log(funcName + "loading css: " + url);
        var ref = document.createElement("link");
        ref.setAttribute("rel","stylesheet");
        ref.setAttribute("type","text/css");
        ref.setAttribute("href",url);
        if (typeof ref !== "undefined" ) {document.getElementsByTagName("head")[0].appendChild(ref); }
        U.loadJsCss(urls,doneFunc); // call again with remaining
        
    } else if ( url.toLowerCase().indexOf(".js", url.length - ".js".length) !== -1 ) {
        // ends with .js
        // url += '?_=' + Date.now(); // add timestamp to ensure download and no cache
        console.log(funcName + "loading js: " + url);
        var script  = document.createElement("script");
        script.type = "text/javascript";
        script.src  = url;
        var head = document.getElementsByTagName("head")[0];
        var completed = false;
        script.onload = script.onreadystatechange = function () {
            if (!completed && (!this.readyState || this.readyState == "loaded" || this.readyState == "complete")) {
                completed = true;
                U.loadJsCss(urls,doneFunc); // call again with remaining
                script.onload = script.onreadystatechange = null;
                head.removeChild(script);
            }
        };
        head.appendChild(script);
    } else {
        // neither
        console.warn(funcName + "url is not .css or .js (" + url + ") - doing nothing");
        U.loadJsCss(urls,doneFunc); // call again with remaining
    }
}; // loadJsCss


//-----------------------------------------------------------
// STARTUP
//-----------------------------------------------------------

// load dependancies in order given then execute init()
U.loadJsCss(U._private.dependancyUrls, function() {
    U._private.init();
});


//===========================================================
// END
//===========================================================
