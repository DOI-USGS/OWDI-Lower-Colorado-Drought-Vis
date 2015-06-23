/* jshint strict: true */
/* global $ */
/* global ScrollMagic */
/* global owdiDrought */
/* global Handlebars */
/* global console */
$(document).ready(function() {
    "use strict";
    window.owdiDrought = window.owdiDrought || {};
    window.owdiDrought.SMController = new ScrollMagic.Controller();


    (function() {

        // For every container, find the sections it holds. Then for each section,
        // use the section's HTML id attribtue to load the template. Once the template
        // is loaded, apply it to the specific container->section. This can be further
        // refactored to include subsections within each section. Some sections have a
        // function that should be triggered after loading it. 
        var containers = $(".container"),
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
            templateLoadError = function () {
                console.warn("Could not load the template for container " + this.containerId + ", section " + this.sectionId);
            },
            // Applies the Handlebars template to the designated container -> section
            applyTemplate = function(data) {
                var template = Handlebars.compile(data);

                $("#" + this.containerId + " > #" + this.sectionId).html(template());
            },
            // In case anything needs to be initialized in a section, do that here using
            // the section's HTML id attribute
            initializeSections = function () {
                switch (this.sectionId) {
                    case "section5":
                        owdiDrought.createDygraph("natural-flow-graph");
                        break;
                    case "section13":
                        owdiDrought.slider.sliderInit();
                        break;
                }
            };

        // Run through each container and section to load the Handlebars templates and apply them
        for (var cIdx = 0; cIdx < containers.length; cIdx++) {
            var $container = $(containers[cIdx]),
                sections = $container.find(".section");
            for (var sIdx = 0; sIdx < sections.length; sIdx++) {
                var $section = $(sections[sIdx]),
                    containerId = $container.attr("id"),
                    sectionId = $section.attr("id"),
                    loadTemplateDeferred = loadTemplate(containerId, sectionId);

                loadTemplateDeferred
                    .done(applyTemplate, initializeSections)
                    .fail(templateLoadError);
            }
        }
    })();
});
