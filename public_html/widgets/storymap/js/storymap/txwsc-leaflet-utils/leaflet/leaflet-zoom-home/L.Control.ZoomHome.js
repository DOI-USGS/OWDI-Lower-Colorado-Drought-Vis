//------------------------------------------------------
// L.Control.ZoomHome:
//   A Leaflet control that extends L.Control.Zoom.
//   It adds a button to the zoom control that allows you to zoom to the map minimum zoom level in a single click.
//
// to load script:
//   <link rel="stylesheet" href="L.Control.ZoomHome.css" media="screen">
//   <script src="L.Control.ZoomHome.js"></script>
//
// example usage:
// map.addControl(new L.Control.ZoomHome( /* options */ ))
//
// map should have "zoomControl":false to NOT create default zoom buttons when using this.
//
//------------------------------------------------------
// original code: https://github.com/alanshaw/leaflet-zoom-min
// modified by jvrabel@usgs.gov
//------------------------------------------------------
L.Control.ZoomHome = L.Control.Zoom.extend({
    // input option defaults:
    options : {
        "position"      : "topleft",   // position on map, "topleft", "topright", "bottomleft", "bottomright"
        
        "zoomInText"    : "+",         // zoom in   button label
        "zoomInTitle"   : "Zoom in",   // zoom in   tooltip
        
        "zoomOutText"   : "-",         // zoom out  button label
        "zoomOutTitle"  : "Zoom out",  // zoom out  tooltip
        
        "zoomHomeText"  : "H",         // zoom home button label (image used, should have no effect)
        "zoomHomeTitle" : "Zoom home", // zoom home tooltip
        
        // ...added options (jvrabel@usgs.gov)...
        
        // buttonOrder
        //   button order from top to bottom.
        //   3-element array containing strings "in", "home", and "out".
        //   order in array sets order in widget.
        "buttonOrder" : ["in","home","out"], // default
        
        // homeGeom
        //   leaflet geometry object that determines where to zoom to when home button clicked
        //   can be:
        //     L.LatLng object       - center map to this point and zoom out to the map's 'minZoom' level (farthest out)
        //     L.latLngBounds object - set the map extent to this lat-long bounds
        //   if none of above or this option is not defined, map zooms to 'minZoom' level (farthest out) with no panning
        "homeGeom" : undefined
    },
    
    // on add:
    onAdd : function (map) {
        var zoomName  = "leaflet-control-zoom";
        var container = L.DomUtil.create("div", zoomName+" leaflet-bar");
        var options   = this.options;
        this._map = map;
        var that = this;
        
        // function to create zoom in button
        var createIn = function(that) {
            that._zoomInButton = that._createButton(
                options.zoomInText,
                options.zoomInTitle,
                zoomName + '-in',
                container,
                that._zoomIn,
                that
            );
        };
        
        // function to create zoom home button
        var createHome = function(that) {
            that._zoomHomeButton = that._createButton(
                options.zoomHomeText,
                options.zoomHomeTitle,
                zoomName + '-min',
                container,
                that._zoomHome,
                that
            );
        };
        
        // function to create zoom out button
        var createOut = function(that) {
            that._zoomOutButton = that._createButton(
                options.zoomOutText,
                options.zoomOutTitle,
                zoomName + '-out',
                container,
                that._zoomOut,
                that
            );
        };
        
        // function to create any of above by name: "in", "home", or "out"
        var createButton = function(name) {
            switch(name) {
                case "in":
                    createIn(that);
                    break;
                case "home":
                    createHome(that);
                    break;
                case "out":
                    createOut(that);
                    break;
                default:
                    // do nothing
                    break;
            } 
        };
        
        // create button in specified buttonOrder
        createButton( options.buttonOrder.shift() );
        createButton( options.buttonOrder.shift() );
        createButton( options.buttonOrder.shift() );
        
        // set update function to disable buttons
        this._updateDisabled();
        map.on("zoomend zoomlevelschange", this._updateDisabled, this);
        
        return container;
    },
    
    // zoom home button callback
    _zoomHome: function () {
        if ((typeof this.options.homeGeom === "object") && (this.options.homeGeom.lat !== undefined)) {
            // L.LatLng point - center and zoom
            this._map.setView( this.options.homeGeom, this._map.getMinZoom() );
            
        } else if ((typeof this.options.homeGeom === "object") && (this.options.homeGeom.getNorthEast !== undefined)) {
            // L.latLngBounds extent - fit bounds
            this._map.fitBounds( this.options.homeGeom );
            
        } else {
            // none of above - zoom to min level without pan
            this._map.setZoom(this._map.getMinZoom());
        }
    },
    
    // update function to disable buttons
    _updateDisabled: function () {
        // remove disable class from buttons
        var className = "leaflet-disabled"
        L.DomUtil.removeClass(this._zoomInButton,   className);
        L.DomUtil.removeClass(this._zoomOutButton,  className);
        L.DomUtil.removeClass(this._zoomHomeButton, className);
        
        // disable zoom out if already zoomed out
        if (this._map._zoom === this._map.getMinZoom()) {
            L.DomUtil.addClass(this._zoomOutButton, className);
        }
        
        // disable zoom home if already zoomed out homeGeom option not specified
        if ( (this._map._zoom === this._map.getMinZoom() ) && (typeof this.options.homeGeom !== "object") ) {
            L.DomUtil.addClass(this._zoomHomeButton, className);
        }
        
        // disable zoom in if already zoomed in
        if (this._map._zoom === this._map.getMaxZoom()) {
            L.DomUtil.addClass(this._zoomInButton, className);
        }
    }
});