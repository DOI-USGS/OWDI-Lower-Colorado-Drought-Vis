//===========================================================
// story_slides.js - create "slides"-type story map
//
//-----------------------------------------------------------
// REFERENCING THIS API:
//
// <!-- txwsc-leaflet-utils & story_api -->
// <script type="text/javascript" src="../../txwsc-leaflet-utils/utils/txwsc-leaflet-utils.min.js"></script>
// <script type="text/javascript" src="../story_api/api/js/story_slides.js"></script>
//
//-----------------------------------------------------------
// USING THIS API:
//
// see /sample_slides/index.html for example slides story map using this api
//
//-----------------------------------------------------------
// DEPENDANCIES:
//
// txwsc-leaflet-utils.js (loads various dependencies it requires)
// all other required dependencies are dynamically loaded by the module
//
//-----------------------------------------------------------
// BUGS / TO DO:
//
// !!!
// "data" and "legend"
// have func to add toggle button bottom left of slides panel (do in story_slides.js).
// clicking button shows a div, clicking again hides.
// make generic so have options:
// - button label
// - div id
// - div id can change for each slide
// eg: "data"
// clicking shows data XXX
//
//===========================================================
// "use strict"; // !!! DO NOT USE FOR PROD

// create module object
window.story_api = {};
story_api._private = {};

// init function
story_api._private.init = function() {
    // add required HTML elements that do not exist
    //
    // user only needs to define this:
    //    <body>
    //        <div id="storymap_container">
    //            <div id="slides_container">
    //                <div id="slides">
    //                    <div class="slide">USER MUST DEFINE THIS AND CONTENT</div>
    //                    <div class="slide"> ...MORE USER-DEFINED SLIDES...  </div>
    //                </div>
    //            </div>
    //        </div>
    //    </body>
    //
    // we need this:
    //    <body>
    //        <div id="storymap"></div>
    //        <div id="slides_container">
    //            <div id="toggleSlides"></div>
    //            <div id="progress"></div>
    //            <div id="slides">
    //                <div class="slide">USER MUST DEFINE THIS AND CONTENT</div>
    //                <div class="slide"> ...MORE USER-DEFINED SLIDES...  </div>
    //            </div>
    //            <ul id="navigation">
    //                <li><a class="prev"></a></li>
    //                <li><a class="next"></a></li>
    //            </ul>
    //        </div>
    //    </body>
    if ( $("#storymap"     ).length <= 0 ) { $( "#storymap_container" ).prepend( '<div id="storymap"></div>'     ); }
    if ( $("#toggleSlides" ).length <= 0 ) { $( "#slides_container"   ).prepend( '<div id="toggleSlides"></div>' ); }
    if ( $("#progress"     ).length <= 0 ) { $( "#slides_container"   ).prepend( '<div id="progress"></div>'     ); }
    if ( $("#navigation"   ).length <= 0 ) { $( "#slides_container"   ).append(  '<ul id="navigation"><li><a class="prev"></a></li><li><a class="next"></a></li></ul>' ); }
    $("#storymap").css({
        "position"        : "absolute",
        "top"             : "0px",
        "left"            : "0px",
        "width"           : "100%",
        "height"          : "100%",
        "overflow"        : "hidden",
        "background-color": "#fff"
    });
    
    // NOTE: "U" is txwsc-leaflet-utils object
    
    // make all elements in storymap_container non-mouse-drag selectable (no highlight when drag mouse to select)
    U.noDragSelect( $("#storymap_container") );
    
    // add all txwsc-leaflet-utils function to story_api so can access through story_api (eg: story_api.addLogos, etc)
    $.each( U, function(key,val) {
        if (typeof val === "function") { story_api[key] = val; }
    });
    
    // make story map
    story_api._private.makeStoryMap();
    
    // set jQuery tooltips
    U.addTooltips( $("#storymap_container") );
};

// when txwsc-leaflet-utils.js (U) is ready load additional dependencies then make story map
story_api._private.rootPath = U.getScriptPath();
story_api._private.dependancyUrls = [
    // ...odyssey.js - must be loaded after leaflet (extends)...
    story_api._private.rootPath + "../../odyssey/odyssey.min.js", // minified
    // ...this module...
    story_api._private.rootPath + "../css/story_slides.css"
];
U.ready = function() {
    U.loadJsCss( story_api._private.dependancyUrls, story_api._private.init );
};


//===========================================================
// PUBLIC FUNCTIONS
//===========================================================

//-----------------------------------------------------------
// resizeSlides
//   resize slides_container to best fit #storymap_container based on slide content
story_api.resizeSlides = function () {
    var funcName = "story_api [resizeSlides]: ";
    console.log(funcName + "resizing slides container");
    
    // do nothing if hidden
    if ( $("#toggleSlides").hasClass("minimized") ) { return 0; }
    
    // wait for all images in slides_container to load then resize slides_container
    function imageLoaded() {
        counter--;
        if (counter === 0) {
            // images loaded - resize
            var container = $("#slides_container");           // slide panel
            var content   = $("#slides_container .selected"); // slide content
            container.height("auto"); // set natural full height
            content.height(  "auto"); // set natural full height
            var Hmax = $("#storymap_container").height() - container.position().top - 100; // available space (with buffer) for container (max allowed)
            var Hreq = content.height()        + container.position().top + 100; // required space for container with content
            var Hmin = 150;  // minimum allowed
            var Huse = Hreq; // init to required
            if (Huse > Hmax) { Huse = Hmax; } // too big   - reset to max allowed
            if (Huse < Hmin) { Huse = Hmin; } // too small - reset to min allowed
            container.height(Huse); // set container height
            content // set conent height and scroll to top
                .height( $("#slides_container").height()-80 )
                .scrollTop(0);
        }
    }
    var images = $("#slides_container img");
    var counter = images.length;
    images.each( function() {
        if (this.complete) {
            imageLoaded.call(this);
        } else {
            $(this).one("load", imageLoaded);
        }
    });
} // resizeSlides


//-----------------------------------------------------------
// toggleSlides
//   show (show=true) or hide (show=false) the slides container
//   visibility toggled if show not input
story_api.toggleSlides = function ( show ) {
    var funcName = "story_api [toggleSlides]: ";
    var isShown  = ! $("#toggleSlides").hasClass("minimized");
    if (show === undefined) { show = ! isShown; } // toggle
    console.log(funcName + "toggling slides container: " + show);
    if ( show ) {
        // show
        if (isShown) { return 0; } // already shown
        $("#toggleSlides").removeClass("minimized");
        $("#slides_container")
            .css({"box-shadow":"10px 10px 5px rgba(0,0,0,0.2)"})
            .stop().animate({
                "background-color" : "rgba(255,255,255,0.7)",
                "width"            : "500px",
                "height"           : ( $("#toggleSlides").prop("data-show-height") ? $("#toggleSlides").prop("data-show-height") : "auto" ) // saved height
            }, 200, function() {
                $("#progress, #slides, #navigation").stop().fadeIn(200, function() {
                    $("#slides_container").css({
                        "height" : "auto",
                    });
                    story_api.resizeSlides();
                });
            });
    } else {
        // hide
        if (! isShown) { return 0; } // already hidden
        $("#toggleSlides")
            .addClass("minimized")
            .prop("data-show-height", $("#slides_container").height() ); // save height
        $("#progress, #slides, #navigation").stop().fadeOut(200, function() {
            $("#slides_container").stop().animate({
                "background-color" : "rgba(255,255,255,0)",
                "width"            : "30px",
                "height"           : "30px"
            }, 200, function() { $("#slides_container").css({"box-shadow":"none"}); } );
        });
    }
} // toggleSlides


//===========================================================
// PRIVATE FUNCTIONS
//===========================================================

//-----------------------------------------------------------
// make slides story map
story_api._private.makeStoryMap = function() {
    var funcName = "story_api [makeStoryMap]: ";
    console.log(funcName + "");
    
    // make map
    story_api.map = new L.Map( "storymap", U.mapOpts);
    U.map = story_api.map; // set map for utils funcs
    story_api.map.refresh = function() {
        L.Util.requestAnimFrame( story_api.map.invalidateSize, story_api.map, false, story_api.map.getContainer() );
    };
    story_api.map.keyboard.disable(); // need turn off map keyboard nav so keys advance slides
    
    // add startup basemap
    story_api.changeBaseMap("openstreets");
    
    // execute user-defined map setup function
    if ( typeof story_api.actionMapSetup === "function" ) { story_api.actionMapSetup(); }
    
    // advance slides when < and > navigation icons clicked
    var seq = O.Sequential();
    var click = function(el) {
        var e = O.Core.getElement(el);
        var t = O.Trigger();
        e.onclick = function () {
            t.trigger();
        }
        return t;
    }
    click( $("#navigation").find(".prev") ).then( seq.prev, seq );  $("#navigation").find(".prev").attr("title","Go to previous slide");
    click( $("#navigation").find(".next") ).then( seq.next, seq );  $("#navigation").find(".next").attr("title","Go to next slide"    );
    
    // advance slides when <= and => keys pressed
    O.Keys().left( ).then(seq.prev, seq);
    O.Keys().right().then(seq.next, seq);
    
    // // advance slides when progress dots clicked
    var progress = O.UI.DotProgress($("#progress")).count( $(".slide").length );
    $("#progress").find("a")
        .attr("title","Jump to slide")
        .click( function() {
            seq.current( $(this).attr("slide-index") );
        });
    
    // make slides
    var slides = O.Slides($("#slides"));
    
    // convert user-defined actions into odyssey Actions
    // ...actionBeforeSlide - executed before individual slide actions for all slides
    var beforeSlideAction;
    if (typeof story_api.actionBeforeSlide === "function") {
        // defined
        beforeSlideAction = O.Action(function() {
            story_api.actionBeforeSlide(); // user action
            story_api.clearMarkers();      // also clear any markers
        });
    } else {
        // not defined
        beforeSlideAction = O.Action(function() {
            story_api.clearMarkers(); // clear any markers
        });
    }
    // ...actionEachSlide - array of individual slide actions to execute for each slide
    var eachSlideAction;
    if ((story_api.actionEachSlide !== undefined) && (story_api.actionEachSlide.length > 0)) {
        // defined
        eachSlideAction = [];
        $.each( story_api.actionEachSlide, function( idx, slideActionFcn ){
            eachSlideAction.push(
                O.Action(function() {
                    slideActionFcn();
                })
            );
        });
    } else {
        // not defined
        eachSlideAction = O.Action(function() {
            // do nothing
        });
    }
    // ...slideAfterAction - executed after individual slide actions for all slides
    var afterSlideAction;
    if (typeof story_api.actionAfterSlide === "function") {
        // defined
        afterSlideAction = O.Action(function() {
            story_api.actionAfterSlide(); // user action
            if (U.controls && U.controls.zoomHome) { story_api.resetZoomHomeExtent(); } // also reset zoom home extent if defined
        });
    } else {
        // not defined
        afterSlideAction = O.Action(function() {
            if (U.controls && U.controls.zoomHome) { story_api.resetZoomHomeExtent(); } // reset zoom home extent if defined
        });
    }
    
    // make story
    story_api.story = new O.Story();
    for (var i = 0; i < $(".slide").length; ++i) {
        
        // set actions for this slide - do sequentially and in order
        var actions = O.Step(
            slides.activate(i),   // make this slide active
            progress.activate(i), // make this dot active
            beforeSlideAction,    // user-defined: before all slides
            eachSlideAction[i],   // user-defined: for this slide
            afterSlideAction      // user-defined: after all slides
        );
        actions.on("finish.app", function() {
            setTimeout( function() { story_api.resizeSlides(); }, 10 );
        });
        
        // add slide state to story
        story_api.story.addState(
            seq.step(i), // trigger: ith slide active
            actions      // execute actions
        )
    }
    
    // resize content when browser resizes
    $(window).resize( function() {
        story_api.resizeSlides();
    });
    
    // setup slides toggle arrow
    $("#toggleSlides")
        .prop("title","Show or hide slides panel")
        .click( function() { story_api.toggleSlides(); });
    
    // start story
    setTimeout( function() {
        story_api.story.go( 0 );  // goto 1st slide
        $("#storymap_container").hide().css({"visibility":"visible"}).fadeIn(2000); // fade in
    }, 1000);
    
} // makeStoryMap


//===========================================================
// END
//===========================================================
