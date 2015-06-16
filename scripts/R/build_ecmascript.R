build_ecmascript <- function(){
  
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
               'svgDocument = evt.target.ownerDocument;',
               'svgDocument.drawRiver = this.drawRiver;}',
               '}',
               'function drawRiver(){',
               'document.getElementById("colorado-river-draw").beginElement();}')
  
  
}