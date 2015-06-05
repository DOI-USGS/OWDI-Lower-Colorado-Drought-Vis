-------------------------------------------------------
STANDALONE BLUE DRAGON "STORY MAP" FOR INCLUSION INTO MAIN WEBPAGE
-------------------------------------------------------

CONTACT:
  Joe Vrabel, USGS TX-WSC Austin
  jvrabel@usgs.gov
  512-927-3563

Directory structure made as I understand the main app will be:

    ./ ................... (root dir) corresponds to the "public_html" directory the app is served from
    ./storymap.html ...... stand-alone demo, see notes in file
    
    ./css/ ............... main css dir used by all
    ./css/storymap.css ... css file for storymap
    
    ./data/ .............. main data dir used by all
    ./data/storymap/ ..... subdir used by storymap
    
    ./img/ ............... main img dir used by all
    /img/storymap/   ..... subdir used by storymap
    
    ./js/ ................ main js dir used by all
    ./js/storymap/ ....... subdir used by storymap

I made the storymap be independent in its own div (see storymap.htm).
It can be sized and placed as needed, but it needs to be fairly large so the map and accompanying slide text panel at left are not too cramped and are still usable.

I assumed things like:
    * jQuery
    * jQuery-UI
    * Leaflet
Will be required by others parts of the main app, so I broke those out in the html head.
The story map requires a lot of resources (besides what are in the html head) that get dynamically loaded
(including jQuery, jQuery-UI, and Leaflet if they aren't already loaded when the storymap js gets loaded).
All these resources are bundled with this stand-alone package.

I tried to adjust things to anticipate and minimize clashes with the rest of the app,
but some tweaking may be required as things get "stitched" together.

In the past, I've had jQuery-UI clashing problems when incorporating a stand-alone feature into a larger app.
If jQuery-UI is not used by anything else, the storymap will load it as it is needed and all should be OK.
If jQuery-UI is used by other parts, it should be loaded as needed (features and styling) before any of the other parts are loaded,
and it will be accessible to all parts as-is and hopefully be OK.
Just a heads up.

I'm assuming URL hash tags will probably be used by the main app for site navigation.
The storymap alters hash tags as it changes slides.
I've written most of this behavior out, but not entirely yet.

GLOBAL OBJECTS Story Map CREATES / USES:
When Story Map loaded, these global objects are create (E.G.: window.U, etc.)
    * $ - jQuery  (will be loaded if does not already exist)
    * L - leaflet (will be loaded if does not already exist)
    * O - Odyssey story map
    * U - TXWSC leaflet utility library
    * story_map - story map utility wrapper
If other things are creating and using O, U, and story_map, there will be serious problems.
Note: TXWSC leaflet utilities may extend some Leaflet widgets - hopefully not a problem.
    
CONSOLE LOGGING:
I tend to use console logging a lot when writing dev code - this code will spit a ton of stuff to console.
I kept that in for now as it can be useful if problems crop up when integrating into main app and stuff stops working.
I'll write out console logging for prod.

MOBILE:
I recall hearing in 6/3/2015 conf.call that a simplified mobile version of the main page is under consideration.
The storymap requires a good amount of space to be usable and I am not sure it would work well on a small screen.
Probably not include this in mobile version.
Or maybe create new greatly simplified version that is just static slide images & text (no leaflet map) that you can change by swiping left-right.

-------------------------------------------------------

