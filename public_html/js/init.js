$(document).ready(function() {
    window.owdiDrought = window.owdiDrought || {};
    window.owdiDrought.SMController = new ScrollMagic.Controller();

    (function() {
        var mkTemplate = function(section) {
            return $.ajax({
                url: "sections/" + section + "/" + section + ".html",
                success: function(data) {
                    var template = Handlebars.compile(data);
                    $("#" + section).html(template());
                }
            });
        }

        for (var sIdx = 1; sIdx < 17; sIdx++) {
            var ajax = mkTemplate("section" + sIdx);

            if (sIdx === 5) {
                ajax.done(function(data) {
                    owdiDrought.createDygraph("natural-flow-graph");
                })
            }

            if (sIdx === 13) {
                ajax.done(function(data) {
                    owdiDrought.slider.sliderInit();
                })
            }
        }
    })();
});
