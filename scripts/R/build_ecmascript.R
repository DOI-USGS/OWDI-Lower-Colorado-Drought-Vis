build_ecmascript <- function(){
  
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
               'svgDocument = evt.target.ownerDocument;',
               'svgDocument.drawRiver = this.drawRiver;}',
               '}',
               'function drawRiver(){',
               'document.getElementById("colorado-river-draw").beginElement();}',
               'function drawBasin(){',
               'document.getElementById("colorado-basin-draw").beginElement();}',
               'function drawPictogram(){',
               'document.getElementById("pictogram-topfive-draw").beginElement();}',
               
               'function removeGreyStates(){',
               'document.getElementById("remove-grey-states").beginElement();}',
               'function removeRiver(){',
               'document.getElementById("remove-river").beginElement();',
               'document.getElementById("remove-basin").beginElement();}',
               'function removePictogram(){',
               'document.getElementById("remove-pictogram").beginElement();}',
               'function moveStates(){',
               'document.getElementById("California-move").beginElement();',
               'document.getElementById("Nevada-move").beginElement();',
               'document.getElementById("Arizona-move").beginElement();',
               'document.getElementById("Nevada-move").beginElement();',
               'document.getElementById("mexico-move").beginElement();',
               'document.getElementById("Mexico-stroke").beginElement();',
               'document.getElementById("Mexico-scale").beginElement();}'
               )
  
  
}