/* jshint strict: true */
/* global $ */
/* global ScrollMagic */
/* global owdiDrought */
/* global Handlebars */
/* global console */
$( document ).ready( function () {
    "use strict";
    // First order of business is to remove the very rude HTML DOM that JQuery Mobile forces on us
    // JQuery Mobile wraps the entire application in a div with its own classes. There's no way to
    // tell it not to do this, so I remove the wrapper div here
    $( "#application" ).unwrap();
    // JQuery Mobile also shoves its own loading indicator into the page. We don"t want this.
    $( ".ui-loader" ).remove();
    // JQuery Mobile also adds questionable CSS to the html and body node
    $( "html" ).removeAttr( "class" );
    $( "body" ).removeAttr( "class" );

    var scrollMagicOptions = {
        loglevel: 3 // http://janpaepke.github.io/ScrollMagic/docs/ScrollMagic.Controller.html#loglevel
    };
    window.owdiDrought = window.owdiDrought || {};
    window.owdiDrought.SMController = new ScrollMagic.Controller( scrollMagicOptions );
    window.owdiDrought.formFactor = "";
    window.owdiDrought.slider.sliderInit();
	window.isIE = navigator.userAgent.indexOf("MSIE ") > -1;

    window.owdiDrought.addScene = function ( sceneItem ) {
        var scene = new ScrollMagic.Scene( {
                triggerElement: sceneItem.parentContainer,
                duration: sceneItem.duration
            } );

        if ( sceneItem.pin ) {
            scene.setPin( sceneItem.pin );
        }

        if ( sceneItem.triggerHook ) {
            scene.triggerHook(sceneItem.triggerHook);
        }

        if ( sceneItem.offset ) {
            scene.offset( sceneItem.offset );
        }

        if ( sceneItem.hasOwnProperty( "start" ) ) {
            scene.on( "start", sceneItem.start );
        }

        if ( sceneItem.hasOwnProperty( "end" ) ) {
            scene.on( "end", sceneItem.end );
        }

        if ( sceneItem.hasOwnProperty( "enter" ) ) {
            scene.on( "enter", sceneItem.enter );
        }

        scene.name = sceneItem.name;

        scene.addTo( window.owdiDrought.SMController );
    };

    //Allows the nav to find the containers based on its ID's
    window.owdiDrought.nav = function(fragment){
        window.location.href = fragment;
    };


    // Track window size and emit events when we pass through width thresholds
    var magicWidth = 686; // Pixel width to use to base mobile/desktop on
    $( window ).on( "resize", function ( e ) {
        var formFactor = "desktop",
            eventName = "",
            evt;

        // Check that we may have moved on to a mobile form factor
        if ( $( e.currentTarget ).width() <= magicWidth ) {
            formFactor = "mobile";
        }

        if ( window.owdiDrought.formFactor !== formFactor ) {
            window.owdiDrought.formFactor = formFactor;
            eventName = "form-factor-" + window.owdiDrought.formFactor;

            if (document.createEvent) {
              evt = document.createEvent("Event");
              evt.initEvent(eventName, true, true);
            } else {
              evt = new Event(eventName);
            }
            window.dispatchEvent(evt);
        }

    } );

    // Before/After section
    (function() {
      "use strict";
      // Bind the before/after spans
      $('figure.cd-image-container .button-before').on('click', owdiDrought.slider.beforeButtonClicked);
      $('figure.cd-image-container .button-after').on('click', owdiDrought.slider.afterButtonClicked);
    })();
	 
	 // Lake Mead animated
	 (function() {
		"use strict";
		var triggered = false,
			parentContainer = "#meadSVGContainer",
			animation = function() {
				var animationSVG = document.getElementById("mead-object").getSVGDocument();
				var animationMobileSVG = document.getElementById("mead-object-mobile").getSVGDocument();
				$(animationSVG).find("#decrement-scene, #increment-scene").on("click", function() {
						var stepNumber = animationSVG.sceneNum;
						$(".SVGInfo:visible").fadeOut({
							complete: function() {
								switch (stepNumber) {
								case 0:
									$("#draw-river").fadeIn();
									break;
								case 1:
									$("#draw-basin").fadeIn();
									break;
								case 2:
									$("#highlight-user-2").fadeIn();
									break;
								case 3:
									$("#mead-info-1").fadeIn();
									break;
								case 4:
									$("#mead-info-2").fadeIn();
									break;
								case 5:
									$("#mead-info-3").fadeIn();
									break;
								case 6:
									$("#mead-info-4").fadeIn();
									break;
								case 7:
									$("#mead-info-5").fadeIn();
									break;
								}
							}
						});
					});
					$(animationMobileSVG).find("#decrement-scene, #increment-scene").on("click", function() {
						var stepNumber = animationMobileSVG.sceneNum;
						$(".SVGInfo:visible").fadeOut({
							complete: function() {
								switch (stepNumber) {
								case 0:
									$("#draw-river").fadeIn();
									break;
								case 1:
									$("#draw-basin").fadeIn();
									break;
								case 2:
									$("#highlight-user-2").fadeIn();
									break;
								case 3:
									$("#mead-info-1").fadeIn();
									break;
								case 4:
									$("#mead-info-2").fadeIn();
									break;
								case 5:
									$("#mead-info-3").fadeIn();
									break;
								case 6:
									$("#mead-info-4").fadeIn();
									break;
								case 7:
									$("#mead-info-5").fadeIn();
									break;
								}
							}
						});
					});
					// Only call if SVG is loaded and has this function
				if (animationSVG && animationSVG.drawRiver && !triggered) {
					animationSVG.drawRiver();
					triggered = true;
				}
				if (animationMobileSVG && animationMobileSVG.drawRiver && !triggered) {
					animationMobileSVG.drawRiver();
					triggered = true;
				}
			};

		window.owdiDrought.addScene({
			parentContainer: parentContainer,
			duration: 100,
			enter: animation
		});
	})();
	
	// Lake Mead static
	(function () {
		var triggered = false,
		parentContainer = "#meadElevationContainer",
		animation = function () {
			var animationSVG = document.getElementById('mead-elev-object').getSVGDocument();

			// Only call if SVG is loaded and has this function
			if (animationSVG && animationSVG.drawTiers && !triggered) {
				animationSVG.drawTiers();
				triggered = true;
			}
		};
		
		$(window).resize(function(){
				 triggered = false;
				 });

		window.owdiDrought.addScene({
			parentContainer: parentContainer,
			duration: 100,
			enter: animation
		});
	})();
	
	(function () {
		var triggered = false,
		parentContainer = "#meadElevationContainer",
		animation = function () {
			var animationMobileSVG = document.getElementById('mead-elev-object-mobile').getSVGDocument();

			// Only call if SVG is loaded and has this function
			if (animationMobileSVG && animationMobileSVG.drawTiers && !triggered) {
				animationMobileSVG.drawTiers();
				triggered = true;
			}
			
		};
		
		$(window).resize(function(){
				 triggered = false;
				 });

		window.owdiDrought.addScene({
			parentContainer: parentContainer,
			duration: 100,
			enter: animation
		});
	})();
	
	// Water Usage
	(function() {
		var triggered = [false, false],
			parentContainer = "#waterUsageContainer",
			animation = function() {
				var animationSVG = document.getElementsByClassName('triggerMe');
				for(var i = 0; i < animationSVG.length; i++){
					var svgElement = animationSVG[i].getSVGDocument();
					if (svgElement && svgElement.visibleAxes && !triggered[i]) {
						svgElement.visibleAxes();
						triggered[i] = true;
					}
				}
			};

		$('#section10Button').click(function() {
		  $('#section10Info').toggle();
		});

		window.owdiDrought.addScene({
		  parentContainer: parentContainer,
		  duration: 100,
		  enter: animation
		});
	 })();
	 
	Handlebars.registerHelper('isEn',function(opts){
		return opts.fn(this);
	});
	
	Handlebars.registerHelper('isEs',function(opts){
		return opts.fn(this);
	});
	
	
    // Update the last modified timestamp in the footer
    $( "#last-mod-timestamp" ).html( document.lastModified );
	
} );


