ecmascript_mead_map <- function(){
  
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
  'svgDocument = evt.target.ownerDocument;',
               'svgDocument.incrementScene = this.incrementScene;',
               'svgDocument.decrementScene = this.decrementScene;}',
               '}',
               
               'var sceneNum = 0;',
               
               'function incrementScene(){',
               'if (sceneNum < scenes.length-1){',
               'scenes[++sceneNum]();',
               '}',
               '}',
               
               'function decrementScene(){',
               'if (sceneNum > 0){',
               'scenes[--sceneNum]();',
               '}',
               '}',
               
               'function scene1(){',
               'show("co-river-polyline");',
                'draw("colorado-river");',
              'show("co-basin-polygon");',
              'hide("pictogram-topfive");',
               '}',
               
               'function scene2(){',
'show("pictogram-topfive");',
'show("non-lo-co-states");',
'show("co-river-polyline");',
'show("co-basin-polygon");',
'resetStates();',
'hide("Nevada-pictos");',
'hide("California-pictos");',
'hide("Arizona-pictos");',
'hide("Mexico-pictos");',
'hide("Mead-2D");',
               '}',
               
               'function scene3(){',
'show("Nevada-pictos");',
'show("California-pictos");',
'show("Arizona-pictos");',
'show("Mexico-pictos");',
'hide("pictogram-topfive");',
'hide("co-river-polyline");',
'hide("co-basin-polygon");',
'moveStates();',
'hide("non-lo-co-states");',
'show("Mead-2D");',
               '}',
               
               'function scene4(){',
              '\tmove("Mead-normal");',
               '\tsetAllocationsNormal();',
               '}',
               'function scene5(){',
              '\tmove("Mead-shortage-1");',
               '\tsetAllocationsShortage1();',
               '}',

'function scene6(){',
'\tmove("Mead-shortage-2");',
'\tsetAllocationsShortage2();',
'}',
'function scene7(){',
'\tmove("Mead-shortage-3");',
'\tsetAllocationsShortage3();',
'}',
               
               
               'var scenes = [scene1, scene2, scene3, scene4, scene5, scene6, scene7];',

'function move(name){',
  '\tvar ani = document.getElementById(name);',
  '\tvar fromValue = ani.getAttribute("attributeName");',
  '\tani.setAttribute("from",ani.parentNode[fromValue].animVal.valueAsString);',
  '\tani.beginElement();',
'}',
'function show(name){',
'var ele = document.getElementById(name);',
'ele.setAttribute("class","shown");',
'}',

'function hide(name){',
'var ele = document.getElementById(name);',
'ele.setAttribute("class","hidden");',
'}',
'function resetStates(){ ',
'resetTransform("California", "translate(0 0)", "reset");',
'resetTransform("Nevada", "translate(0 0)", "reset");',
'resetTransform("Arizona", "translate(0 0)", "reset");',
'resetTransform("mexico", "translate(0 0)", "reset");',
'resetTransform("Mexico", "scale(1 1)", "scale-reset");',
'document.getElementById("Mexico-stroke-reset").beginElement();',
'}',
'function moveStates(){',
'transform("California","translate(0 0)","move");',
'transform("Nevada","translate(0 0)","move");',
'transform("Arizona","translate(0 0)","move")',
'transform("mexico","translate(0 0)","move")',
'transform("Mexico","scale(1 1)","scale")',
'document.getElementById("Mexico-stroke").beginElement();',
'}',

'function resetTransform(name, match, resetFun){',
'var ele = document.getElementById(name);',
'if (ele.getAttribute("transform") != null & ele.getAttribute("transform") != match){',
'document.getElementById(name+"-"+resetFun).beginElement();',
'}',
'}',

'function transform(name, match, transformFun){',
'var ele = document.getElementById(name);',
'if (ele.getAttribute("transform") === null | ele.getAttribute("transform") === match){',
'document.getElementById(name+"-"+transformFun).beginElement();',
'}',
'}',

'function draw(name){',
'document.getElementById("draw-"+name).beginElement();}',
               
               
               'function drawUserPicto(user_id){',
               '\tdocument.getElementById("usage-"+user_id).setAttribute("opacity","0.8");',
               '\tdocument.getElementById("picto-highlight-"+user_id).setAttribute("opacity","0.8");',
               '\teval(document.getElementById("picto-"+user_id).getAttribute("onmouseover").replace("evt","null").replace("evt","null"));',
               '}',
               
               'function displayPictoName(evt, name) {',
               '\tdocument.getElementById("picto-info").firstChild.data = name;',
               '}',
               
               'function displayPictoValue(evt, name) {',
               '\tdocument.getElementById("picto-value").firstChild.data = name;',
               '}',
               
               'function hidePictoName(evt) {',
               '\tdocument.getElementById("picto-info").firstChild.data = " ";',
               '}',
               
               'function hidePictoValue(evt) {',
               '\tdocument.getElementById("picto-value").firstChild.data = " ";',
               '}',
               
               'function removeUserPicto(user_id){',
               '\tdocument.getElementById("usage-"+user_id).setAttribute("opacity","0.0");',
               '\tdocument.getElementById("picto-highlight-"+user_id).setAttribute("opacity","0.0");',
               '\teval(document.getElementById("picto-"+user_id).getAttribute("onmouseout").replace("evt","null").replace("evt","null"));',
               '}',
               
               'function drawStatePicto(user_id){',
               '\tdocument.getElementById("draw-"+user_id+"-pictogram").beginElement();',
               '}',
               'function removeStatePicto(user_id){',
               '\tdocument.getElementById("remove-"+user_id+"-pictogram").beginElement();',
               '}',
               
               'function setAllocationsNormal(){',
               '\tdocument.getElementById("Nevada-pictos-normal").setAttribute("visibility","visible");',
               '\tdocument.getElementById("Arizona-pictos-normal").setAttribute("visibility","visible");',
               '\tdocument.getElementById("Mexico-pictos-normal").setAttribute("visibility","visible");',
               '\tdocument.getElementById("allocation-picto-highlight-1").setAttribute("opacity","0");',
               '\tdocument.getElementById("allocation-picto-highlight-2").setAttribute("opacity","0");',
               '\tdocument.getElementById("allocation-picto-highlight-3").setAttribute("opacity","0");',
               '}',
               
               'function setAllocationsShortage1(){',
               '\tdocument.getElementById("Nevada-pictos-normal").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage1").setAttribute("visibility","visible");',
               '\tdocument.getElementById("Arizona-pictos-normal").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage1").setAttribute("visibility","visible");',
               '\tdocument.getElementById("Mexico-pictos-normal").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage1").setAttribute("visibility","visible");',
               '\tdocument.getElementById("allocation-picto-highlight-1").setAttribute("opacity","0.8");',
               '\tdocument.getElementById("allocation-picto-highlight-2").setAttribute("opacity","0");',
               '\tdocument.getElementById("allocation-picto-highlight-3").setAttribute("opacity","0");',
               '}',
               
               'function setAllocationsShortage2(){',
               '\tdocument.getElementById("Nevada-pictos-normal").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage1").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage2").setAttribute("visibility","visible");',
               '\tdocument.getElementById("Arizona-pictos-normal").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage1").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage2").setAttribute("visibility","visible");',
               '\tdocument.getElementById("Mexico-pictos-normal").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage1").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage2").setAttribute("visibility","visible");',
               '\tdocument.getElementById("allocation-picto-highlight-1").setAttribute("opacity","0");',
               '\tdocument.getElementById("allocation-picto-highlight-2").setAttribute("opacity","0.8");',
               '\tdocument.getElementById("allocation-picto-highlight-3").setAttribute("opacity","0");',
               '}',
               
               'function setAllocationsShortage3(){',
               '\tdocument.getElementById("Nevada-pictos-normal").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage1").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage2").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Arizona-pictos-normal").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage1").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage2").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Mexico-pictos-normal").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage1").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage2").setAttribute("visibility","hidden");',
               '\tdocument.getElementById("allocation-picto-highlight-1").setAttribute("opacity","0");',
               '\tdocument.getElementById("allocation-picto-highlight-2").setAttribute("opacity","0");',
               '\tdocument.getElementById("allocation-picto-highlight-3").setAttribute("opacity","0.8");',
               '}',
               
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