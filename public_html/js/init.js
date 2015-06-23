/* jshint strict: true */
/* global $ */
/* global ScrollMagic */
/* global owdiDrought */
/* global Handlebars */
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
            loadTemplate = function(containerId, sectionId) {
                return $.ajax({
                    url: "sections/" + sectionId + "/" + sectionId + ".html",
                    context: {
                        containerId: containerId,
                        sectionId: sectionId
                    }
                });
            },
            applyTemplate = function(data) {
                var template = Handlebars.compile(data);
                $("#" + this.containerId + " > #" + this.sectionId).html(template());
            },
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

        for (var cIdx = 0; cIdx < containers.length; cIdx++) {
            var $container = $(containers[cIdx]),
                sections = $container.find(".section");
            for (var sIdx = 0; sIdx < sections.length; sIdx++) {
                var $section = $(sections[sIdx]),
                    containerId = $container.attr("id"),
                    sectionId = $section.attr("id");
                var loadTemplateDeferred = loadTemplate(containerId, sectionId);

                loadTemplateDeferred.done(applyTemplate, initializeSections);
            }
        }
    })();
});
