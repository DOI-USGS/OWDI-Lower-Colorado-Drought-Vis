ecmascript_mead_map <- function(){
  
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
               'svgDocument = evt.target.ownerDocument;',
               'svgDocument.drawRiver = this.drawRiver;',
               'svgDocument.showRiver = this.showRiver;',
               'svgDocument.drawBasin = this.drawBasin;',
               'svgDocument.drawPictogram = this.drawPictogram;',
               'svgDocument.removeGreyStates = this.removeGreyStates;',
               'svgDocument.resetGreyStates = this.resetGreyStates;',
               'svgDocument.removeRiver = this.removeRiver;',
               'svgDocument.resetRiver = this.resetRiver;',
               'svgDocument.resetBasin = this.resetBasin;',
               'svgDocument.removePictogram = this.removePictogram;',
               'svgDocument.moveStates = this.moveStates;',
               'svgDocument.resetStates = this.resetStates;}',
               
               '}',
               'function showRiver(){',
               'document.getElementById("show-river").beginElement();}',
               
               'function drawRiver(){',
               'document.getElementById("colorado-river-draw").beginElement();}',
               'function resetRiver(){',
               'document.getElementById("colorado-river-reset").beginElement();',
               'document.getElementById("reset-river").beginElement();}',
               
               'function drawBasin(){',
               'document.getElementById("colorado-basin-draw").beginElement();}',
               'function resetBasin(){',
               'document.getElementById("remove-basin").beginElement();}',
               
               'function drawPictogram(){',
               'document.getElementById("pictogram-topfive-draw").beginElement();}',
               'function resetPictogram(){',
               'document.getElementById("pictogram-topfive-reset").beginElement();}',
               
               'function removeGreyStates(){',
               'document.getElementById("remove-grey-states").beginElement();}',
               'function resetGreyStates(){',
               'document.getElementById("reset-grey-states").beginElement();}',
               
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
               'document.getElementById("Mexico-scale").beginElement();}',
               'function resetStates(){',
               'document.getElementById("California-reset").beginElement();',
               'document.getElementById("Nevada-reset").beginElement();',
               'document.getElementById("Arizona-reset").beginElement();',
               'document.getElementById("Nevada-reset").beginElement();',
               'document.getElementById("mexico-reset").beginElement();',
               'document.getElementById("Mexico-stroke-reset").beginElement();',
               'document.getElementById("Mexico-scale-reset").beginElement();}',
               
               'function highlightUser(user_id){',
               'document.getElementById("pictogram-"+user_id+"-draw").beginElement();}'
               )
  
  
}

ecmascript_supply_usage <- function(){
  
  scripts <- 'function init(evt)
  {
  if ( window.svgDocument == null )
  {
    svgDocument = evt.target.ownerDocument;
    svgDocument.timeAdvance = this.timeAdvance;
    svgDocument.visibleAxes = this.visibleAxes;
  }
  
  legend = svgDocument.getElementById("legend");
  }
  function legendViz(evt,elementname)
  {
  var r = document.getElementById(elementname).r.animVal.value
  
  if (r === 0){
    legend.setAttributeNS(null,"visibility","hidden");
  } else {
    legend.setAttributeNS(null,"visibility","visible");
  }
  
  }
  function highlightViz(evt,elementname,opacity)
  {
  var r = document.getElementById(elementname).r.animVal.value
  
  if (r === 0){
    evt.target.setAttribute("fill-opacity", "0.0");
  } else {
    evt.target.setAttribute("fill-opacity", opacity);
  }
  
  }
  
  function ChangeText(evt, elementname, legendtext)
  {
  textelement = svgDocument.getElementById(elementname);                      
  textelement.firstChild.data = legendtext;
  } 
  function timeAdvance(){
    var ele = document.getElementById("timeAdvance");
    ele.beginElement();
  }
  function visibleAxes(){
    var ele = document.getElementById("visibleAxes");
    ele.beginElement();
  }'
  
}