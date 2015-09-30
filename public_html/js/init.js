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
	
	//Marty Function here...
	
	window.owdiDrought.nav = function(fragment){
		window.location.hash = fragment;
	};

    var fillDom = ( function () {
        // For every container, find the sections it holds. Then for each section,
        // use the section's HTML id attribtue to load the template. Once the template
        // is loaded, apply it to the specific container->section. This can be further
        // refactored to include subsections within each section. Some sections have a
        // function that should be triggered after loading it.
        var containers = $( ".container" ),
            // A deferred that is passed back to the caller and resolved when I've loaded all
            // of the templates and applied them to the dom
            deferred = $.Deferred(),
            // Loads the Handlebars template and returns a deferred object to the caller.
            // The context is the passed-in container and section ids
            loadTemplate = function ( containerId, sectionId ) {
                return $.ajax( {
                    url: "sections/" + sectionId + "/" + sectionId + ".html",
                    context: {
                        containerId: containerId,
                        sectionId: sectionId
                    }
                } );
            },
            templateLoadError = function () {
                console.warn( "Could not load the template for container " + this.containerId + ", section " + this.sectionId );
            },
            // Applies the Handlebars template to the designated container -> section
            applyTemplate = function ( templateHTML, status, jqXHR, templateData ) {
                var host = window.location.origin;
                if ( !host ) {
                    host = "//" + window.location.host;
                }
                var template = Handlebars.compile( templateHTML ),
                    extendedTemplateData = $.extend( {}, templateData, {
                        baseUrl: host + window.location.pathname
                    } ),
                    html = template( extendedTemplateData );

                $( "#" + this.containerId + " > #" + this.sectionId ).html( html );
            },
            // In case anything needs to be initialized in a section, do that here using
            // the section's HTML id attribute
            initializeSections = function () {
                switch ( this.sectionId ) {
                case "before-after":
                    owdiDrought.slider.sliderInit();
                    break;
                }
            },
            // This variable is set at this level of the scope because I need to attach a
            // resolution for a deferred after it comes out of the loop below. This allows me
            // to resolve the deferred after the last container's DOM is populated which
            // allows us to do things like remove an overlay when the app has finished loading
            loadTemplateDeferred;

        // Run through each container and section to load the Handlebars templates and apply them
        for ( var cIdx = 0; cIdx < containers.length; cIdx++ ) {
            var $container = $( containers[ cIdx ] ),
                sections = $container.find( ".section" );

            for ( var sIdx = 0; sIdx < sections.length; sIdx++ ) {
                var $section = $( sections[ sIdx ] ),
                    containerId = $container.attr( "id" ),
                    sectionId = $section.attr( "id" );

                loadTemplateDeferred = loadTemplate( containerId, sectionId );

                loadTemplateDeferred
                    .done( applyTemplate, initializeSections )
                    .fail( templateLoadError );

            }
        }

        // At this point, the loadTemplateDeferred object is the last container/section combo
        // so when it's populated, resolve the deferred object being returned to the caller so it
        // can act
        loadTemplateDeferred.always( deferred.resolve );

        return deferred;
    } )();

    // The fillDom deferred object will be resolved when the DOM for the application has been loaded
    fillDom.done( function () {
        // At this point, the DOM will have been built

        window.console.trace( "Application loaded" );
        window.owdiDrought.SMController.scrollTo( 0 );
        var fadeTimeInMs = 1500;

        $( "#overlay" ).fadeOut( fadeTimeInMs, "swing", function () {
            $( this ).remove();
            $( window ).resize();
        } );
    } );

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


    // Update the last modified timestamp in the footer
    $( "#last-mod-timestamp" ).html( document.lastModified );
} );
