/* jshint strict: true */
/* global $ */
/* global ScrollMagic */
/* global owdiDrought */
/* global Handlebars */
/* global console */
$(document).ready(function() {
    "use strict";
    // First order of business is to remove the very rude HTML DOM that JQuery Mobile forces on us
    // JQuery Mobile wraps the entire application in a div with its own classes. There's no way to
    // tell it not to do this, so I remove the wrapper div here
    $('#application').unwrap();
    // JQuery Mobile also shoves its own loading indicator into the page. We don't want this. 
    $('.ui-loader').remove();
    // JQuery Mobile also adds questionable CSS to the html and body node
    $('html').removeAttr('class');
    $('body').removeAttr('class');
    
    var scrollMagicOptions = {
          loglevel : 3 // http://janpaepke.github.io/ScrollMagic/docs/ScrollMagic.Controller.html#loglevel
    };
    window.owdiDrought = window.owdiDrought || {};
    window.owdiDrought.SMController = new ScrollMagic.Controller(scrollMagicOptions);
    window.owdiDrought.formFactor = '';
    
    var fillDom = (function() {
        // For every container, find the sections it holds. Then for each section,
        // use the section's HTML id attribtue to load the template. Once the template
        // is loaded, apply it to the specific container->section. This can be further
        // refactored to include subsections within each section. Some sections have a
        // function that should be triggered after loading it. 
        var containers = $(".container"),
            // A deferred that is passed back to the caller and resolved when I've loaded all 
            // of the templates and applied them to the dom
            deferred = $.Deferred(),
            // Loads the Handlebars template and returns a deferred object to the caller.
            // The context is the passed-in container and section ids
            loadTemplate = function(containerId, sectionId) {
                return $.ajax({
                    url: "sections/" + sectionId + "/" + sectionId + ".html",
                    context: {
                        containerId: containerId,
                        sectionId: sectionId
                    }
                });
            },
            templateLoadError = function() {
                console.warn("Could not load the template for container " + this.containerId + ", section " + this.sectionId);
            },
            // Applies the Handlebars template to the designated container -> section
            applyTemplate = function(templateHTML, status, jqXHR, templateData) {
                var template = Handlebars.compile(templateHTML),
                    extendedTemplateData = $.extend({}, templateData, {
                        baseUrl: window.location.origin + window.location.pathname
                    });

                $("#" + this.containerId + " > #" + this.sectionId).html(template(extendedTemplateData));
            },
            // In case anything needs to be initialized in a section, do that here using
            // the section's HTML id attribute
            initializeSections = function() {
                switch (this.sectionId) {
                    case "blue-dragon":
                        owdiDrought.createDygraph("natural-flow-graph");
                        break;
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
        for (var cIdx = 0; cIdx < containers.length; cIdx++) {
            var $container = $(containers[cIdx]),
                sections = $container.find(".section");

            for (var sIdx = 0; sIdx < sections.length; sIdx++) {
                var $section = $(sections[sIdx]),
                    containerId = $container.attr("id"),
                    sectionId = $section.attr("id");

                loadTemplateDeferred = loadTemplate(containerId, sectionId);

                loadTemplateDeferred
                    .done(applyTemplate, initializeSections)
                    .fail(templateLoadError);

            }
        }

        // At this point, the loadTemplateDeferred object is the last container/section combo
        // so when it's populated, resolve the deferred object being returned to the caller so it 
        // can act
        loadTemplateDeferred.always(deferred.resolve);

        return deferred;
    })();

    // The fillDom deferred object will be resolved when the DOM for the application has been loaded
    fillDom.done(function() {
        // At this point, the DOM will have been built 

        window.console.trace("Application loaded");
        window.owdiDrought.SMController.scrollTo(0);
        var fadeTimeInMs = 1500;

        $("#overlay").fadeOut(fadeTimeInMs, "swing", function() {
            $(this).remove();
            $(window).resize();
        });
    });

    // Track window size and emit events when we pass through width thresholds
    var magicWidth = 686; // Pixel width to use to base mobile/desktop on
    $(window).on('resize', function (e) {
        var formFactor = 'desktop',
            resizeEvent,
            eventName = '';
        
        // Check that we may have moved on to a mobile form factor    
        if ($(e.currentTarget).width() <= magicWidth) {
            formFactor = 'mobile';
        }

        // Create and dispatch event. A bit complicated due to dealing with
        // IE and non-IE browsers and the way they dispatch events
        if (window.owdiDrought.formFactor !== formFactor) {
            window.owdiDrought.formFactor = formFactor;
            eventName = "form-factor-" + window.owdiDrought.formFactor;

            window.dispatchEvent(new Event(eventName));
        }

    });


    // Update the last modified timestamp in the footer
    $('#last-mod-timestamp').html(document.lastModified);
});
