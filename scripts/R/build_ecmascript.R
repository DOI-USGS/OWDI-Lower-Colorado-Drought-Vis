ecmascript_mead_map <- function(){
  
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
               'svgDocument = evt.target.ownerDocument;',
               'svgDocument.drawRiver = this.drawRiver;',
               'svgDocument.showRiver = this.showRiver;',
               'svgDocument.drawBasin = this.drawBasin;',
               'svgDocument.drawMead = this.drawMead;',
               'svgDocument.drawPictogram = this.drawPictogram;',
               'svgDocument.removeGreyStates = this.removeGreyStates;',
               'svgDocument.resetGreyStates = this.resetGreyStates;',
               'svgDocument.removeRiver = this.removeRiver;',
               'svgDocument.removeMead = this.removeMead;',
               'svgDocument.resetRiver = this.resetRiver;',
               'svgDocument.resetBasin = this.resetBasin;',
               'svgDocument.removePictogram = this.removePictogram;',
               'svgDocument.moveStates = this.moveStates;',
               'svgDocument.highlightUser = this.highlightUser;',
               'svgDocument.setMeadCondition = this.setMeadCondition;',
               'svgDocument.drawStatePicto = this.drawStatePicto;',
               'svgDocument.removeStatePicto = this.drawStatePicto;',
               'svgDocument.resetStates = this.resetStates;}',
               
               '}',
               'function showRiver(){',
               'document.getElementById("show-river").beginElement();}',
               
               'function drawMead(){',
               'document.getElementById("mead-draw").beginElement();}',
               'function removeMead(){',
               'document.getElementById("mead-remove").beginElement();}',
               
               'function drawRiver(){',
               'document.getElementById("colorado-river-draw").beginElement();}',
               'function resetRiver(){',
               'document.getElementById("colorado-river-reset").beginElement();}',
               
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
               'document.getElementById("pictogram-"+user_id+"-draw").beginElement();',
               'document.getElementById("user-"+user_id+"-draw").beginElement();}',
               
               'function drawStatePicto(user_id){',
               'document.getElementById("draw-"+user_id+"-pictogram").beginElement();}',
               'function removeStatePicto(user_id){',
               'document.getElementById("remove-"+user_id+"-pictogram").beginElement();}',
               
               'function setMeadCondition(storage_id){',
               'document.getElementById("Mead-"+storage_id).beginElement();}',
               'function showRiverDOM(){
	animateIE(document.getElementById("show-river"));
}
function drawRiverDOM(){
animateIE(document.getElementById("colorado-river-draw"));
}
function resetRiverDOM(){
animateIE(document.getElementById("colorado-river-reset"));
animateIE(document.getElementById("reset-river"));
}
function drawBasinDOM(){
animateIE(document.getElementById("colorado-basin-draw"));
}
function resetBasinDOM(){
animateIE(document.getElementById("remove-basin"));
}
function drawPictogramDOM(){
animateIE(document.getElementById("pictogram-topfive-draw"));
}
function resetPictogramDOM(){
animateIE(document.getElementById("pictogram-topfive-reset"));
}
function removeGreyStatesDOM(){
animateIE(document.getElementById("remove-grey-states"));
}
function resetGreyStatesDOM(){
animateIE(document.getElementById("reset-grey-states"));
}
function removeRiverDOM(){
animateIE(document.getElementById("remove-river"));
animateIE(document.getElementById("remove-basin"));
}
function removePictogramDOM(){
animateIE(document.getElementById("remove-pictogram"));
}
function highlightUserDOM(user_id){
animateIE(document.getElementById("pictogram-"+user_id+"-draw"));
animateIE(document.getElementById("user-"+user_id+"-draw"));
}
function moveStatesDOM(){
animateIE(document.getElementById("California-move"));
animateIE(document.getElementById("Nevada-move"));
animateIE(document.getElementById("Arizona-move"));
animateIE(document.getElementById("Nevada-move"));
animateIE(document.getElementById("mexico-move"));
animateIE(document.getElementById("Mexico-stroke"));
animateIE(document.getElementById("Mexico-scale"));
}
function resetStatesDOM(){
animateIE(document.getElementById("California-reset"));
animateIE(document.getElementById("Nevada-reset"));
animateIE(document.getElementById("Arizona-reset"));
animateIE(document.getElementById("Nevada-reset"));
animateIE(document.getElementById("mexico-reset"));
animateIE(document.getElementById("Mexico-stroke-reset"));
animateIE(document.getElementById("Mexico-scale-reset"));
}
function setMeadConditionDOM(storage_id){
animateIE(document.getElementById("Mead-"+storage_id));
}

function animateIE(element) {
if(element instanceof Element) {
if(element.nodeName === "animate" || element.nodeName === "animateTransform") {
var parent = element.parentNode;
if(element.getAttribute("attributeName") === "transform") {
var type = element.getAttribute("type");
parent.setAttribute("transform", type.concat("(", element.getAttribute("to"), ")"));
} else if(element.hasAttribute("to")) {
parent.setAttribute(element.getAttribute("attributeName"), element.getAttribute("to"));
} else if(element.hasAttribute("values")){
parent.setAttribute(element.getAttribute("attributeName"), element.getAttribute("values").split(";")[1]);
}
}
}
}'
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
    svgDocument.setMobile = this.setMobile;
    svgDocument.setDesktop = this.setDesktop;
  }
  
  legend = svgDocument.getElementById("legend");
  window.parent.addEventListener("form-factor-desktop", setDesktop, false);
  window.parent.addEventListener("form-factor-mobile", setMobile, false);  
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
  function setMobile(){
  	svgDocument.getElementById("legend").setAttribute("transform","scale(1.5)translate(-40,-8)");
    svgDocument.getElementById("y-label").setAttribute("y","-10");       
  }
  function setDesktop(){
    svgDocument.getElementById("legend").setAttribute("transform","scale(1.0)translate(0,0)");     
    svgDocument.getElementById("y-label").setAttribute("y","0");                          
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

ecmascript_mead_proj <- function(){
  
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
               'svgDocument = evt.target.ownerDocument;',
               'svgDocument.setMobile = this.setMobile;',
               'svgDocument.setDesktop = this.setDesktop;}',
               '}',
               'window.parent.addEventListener("form-factor-desktop", setDesktop, false);',
               'window.parent.addEventListener("form-factor-mobile", setMobile, false);',
               "function ChangeText(evt, elementname, legendtext)
               {
               textelement = svgDocument.getElementById(elementname);                      
               textelement.firstChild.data = legendtext;
               }",
               'function highlightEle(evt,opacity)
               {
                 evt.target.setAttribute("fill-opacity", opacity);
               }',
               'function setMobile(){
                 svgDocument.getElementById("legend").setAttribute("transform","scale(1.5)translate(-40,-8)");
                 svgDocument.getElementById("y-label").setAttribute("y","-12");       
               }
               function setDesktop(){
                 svgDocument.getElementById("legend").setAttribute("transform","scale(1.0)translate(0,0)");     
                 svgDocument.getElementById("y-label").setAttribute("y","0");                          
               }')
  
  
}