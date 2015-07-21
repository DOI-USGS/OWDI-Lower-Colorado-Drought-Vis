ecmascript_mead_map <- function(){
  
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
  'svgDocument = evt.target.ownerDocument;',
               'svgDocument.incrementScene = this.incrementScene;',
               'svgDocument.decrementScene = this.decrementScene;}',
               '}',
  'function displayAllocationName(evt, name) {',
    'var data = {"California":{',
      '"flood":"4,400,000",',
      '"surplus":"4,400,000",',
      '"normal":"4,400,000",',
      '"shortage-1":"4,400,000",',
      '"shortage-2":"4,400,000",',
      '"shortage-3":"4,400,000"},',
      '"Arizona":{',
        '"flood":"2,800,000",',
        '"surplus":"2,800,000",',
        '"normal":"2,800,000",',
        '"shortage-1":"2,480,000",',
        '"shortage-2":"2,400,000",',
        '"shortage-3":"2,320,000"},',
      '"Nevada":{',
        '"flood":"300,000",',
        '"surplus":"300,000",',
        '"normal":"300,000",',
        '"shortage-1":"287,000",',
        '"shortage-2":"283,000",',
        '"shortage-3":"280,000"},',
      '"Mexico":{',
        '"flood":"1,500,000",',
        '"surplus":"1,500,000",',
        '"normal":"1,500,000",',
        '"shortage-1":"1,450,000",',
        '"shortage-2":"1,430,000",',
        '"shortage-3":"1,375,000"}};',
    'var state = document.getElementById("allocation-state").firstChild.data',
    'document.getElementById("allocation-value").firstChild.data = name + ": " + data[name][state] +" acre-feet/year";',
'}',
  'function setMeadCondition(storage_id){',
    
    'document.getElementById("allocation-state").firstChild.data = storage_id',
    'var elevations = {"flood":"1,219.6",',
      '"surplus":"1,200",',
      '"normal":"1,145",',
      '"shortage-1":"1,075",',
      '"shortage-2":"1,050",',
      '"shortage-3":"1,025"}',
    'var storages = {"flood":"26.1",',
      '"surplus":"23.1",',
      '"normal":"16.2",',
      '"shortage-1":"9.6",',
      '"shortage-2":"7.7",',
      '"shortage-3":"6.0"}',
    'document.getElementById("mead-storage-text").firstChild.data = "Storage: " + storages[storage_id] + " maf"',
    'document.getElementById("mead-elevation-text").firstChild.data = "Elevation: " + elevations[storage_id] + " feet"',
  '}',
'function showStateMouseovers(){',
  'document.getElementById("california-mouseovers").setAttribute("visibility","visbile");',
  'document.getElementById("nevada-mouseovers").setAttribute("visibility","visbile");',
  'document.getElementById("arizona-mouseovers").setAttribute("visibility","visbile");',
  'document.getElementById("mexico-mouseovers").setAttribute("visibility","visbile");',
'}',
'function hideStateMouseovers(){',
  'document.getElementById("california-mouseovers").setAttribute("visibility","hidden");',
  'document.getElementById("nevada-mouseovers").setAttribute("visibility","hidden");',
  'document.getElementById("arizona-mouseovers").setAttribute("visibility","hidden");',
  'document.getElementById("mexico-mouseovers").setAttribute("visibility","hidden");',
'}',
'function highlightState(evt, name) {',
  'document.getElementById(name).setAttribute("stroke","#808080");',
'}',

'function lowlightState(evt, name) {',
  'document.getElementById(name).setAttribute("stroke","#FFFFFF");',
'}',

'function hideAllocationName(evt) {',
  'document.getElementById("allocation-value").firstChild.data = " ";',
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
'hideStateMouseovers();',
               '}',
               
               'function scene3(){',
'showStateMouseovers();',
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
'\tdocument.getElementById("Mead-water-level").setAttribute("class","mead-flood");',
'\tdocument.getElementById("mead-elevation-text-position").setAttribute("class","mead-flood");',
'\tsetMeadCondition("flood");',
'\tsetAllocationsNormal();',
               '}',
'function scene4(){',
'\tdocument.getElementById("Mead-water-level").setAttribute("class","mead-surplus");',
'\tdocument.getElementById("mead-elevation-text-position").setAttribute("class","mead-surplus");',
'\tsetMeadCondition("surplus");',
'\tsetAllocationsNormal();',
'}',
'function scene5(){',
'\tdocument.getElementById("Mead-water-level").setAttribute("class","mead-normal");',
'\tdocument.getElementById("mead-elevation-text-position").setAttribute("class","mead-normal");',
'\tsetMeadCondition("normal");',
'\tsetAllocationsNormal();',
'}',
               'function scene6(){',
'\tdocument.getElementById("Mead-water-level").setAttribute("class","mead-shortage-1");',
'\tdocument.getElementById("mead-elevation-text-position").setAttribute("class","mead-shortage-1");',
'\tsetMeadCondition("shortage-1");',
               '\tsetAllocationsShortage1();',
               '}',

'function scene7(){',
'\tdocument.getElementById("Mead-water-level").setAttribute("class","mead-shortage-2");',
'\tdocument.getElementById("mead-elevation-text-position").setAttribute("class","mead-shortage-2");',
'\tsetMeadCondition("shortage-2");',
'\tsetAllocationsShortage2();',
'}',
'function scene8(){',
'\tdocument.getElementById("Mead-water-level").setAttribute("class","mead-shortage-3");',
'\tdocument.getElementById("mead-elevation-text-position").setAttribute("class","mead-shortage-3");',
'\tsetMeadCondition("shortage-3");',
'\tsetAllocationsShortage3();',
'}',
               
               
               'var scenes = [scene1, scene2, scene3, scene4, scene5, scene6, scene7,scene8];',

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
'document.getElementById("California").setAttribute("class","california");',
'document.getElementById("Nevada").setAttribute("class","nevada");',
'document.getElementById("Arizona").setAttribute("class","arizona");',
'document.getElementById("Mexico").setAttribute("class","mexico");',
'}',
'function moveStates(){',
'document.getElementById("California").setAttribute("class","california-moved");',
'document.getElementById("Nevada").setAttribute("class","nevada-moved");',
'document.getElementById("Arizona").setAttribute("class","arizona-moved");',
'document.getElementById("Mexico").setAttribute("class","mexico-moved");',
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
               
               'function setAllocationsNormal(){',
               '\tdocument.getElementById("Nevada-pictos-normal").setAttribute("class","shown");',
               '\tdocument.getElementById("Arizona-pictos-normal").setAttribute("class","shown");',
               '\tdocument.getElementById("Mexico-pictos-normal").setAttribute("class","shown");',
               '\tdocument.getElementById("allocation-picto-highlight-1").setAttribute("class","hidden");',
               '\tdocument.getElementById("allocation-picto-highlight-2").setAttribute("class","hidden");',
               '\tdocument.getElementById("allocation-picto-highlight-3").setAttribute("class","hidden");',
               '}',
               
               'function setAllocationsShortage1(){',
               '\tdocument.getElementById("Nevada-pictos-normal").setAttribute("class","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage1").setAttribute("class","shown");',
               '\tdocument.getElementById("Arizona-pictos-normal").setAttribute("class","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage1").setAttribute("class","shown");',
               '\tdocument.getElementById("Mexico-pictos-normal").setAttribute("class","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage1").setAttribute("class","shown");',
               '\tdocument.getElementById("allocation-picto-highlight-1").setAttribute("class","shown");',
               '\tdocument.getElementById("allocation-picto-highlight-2").setAttribute("class","hidden");',
               '\tdocument.getElementById("allocation-picto-highlight-3").setAttribute("class","hidden");',
               '}',
               
               'function setAllocationsShortage2(){',
               '\tdocument.getElementById("Nevada-pictos-normal").setAttribute("class","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage1").setAttribute("class","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage2").setAttribute("class","shown");',
               '\tdocument.getElementById("Arizona-pictos-normal").setAttribute("class","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage1").setAttribute("class","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage2").setAttribute("class","shown");',
               '\tdocument.getElementById("Mexico-pictos-normal").setAttribute("class","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage1").setAttribute("class","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage2").setAttribute("class","shown");',
               '\tdocument.getElementById("allocation-picto-highlight-1").setAttribute("class","hidden");',
               '\tdocument.getElementById("allocation-picto-highlight-2").setAttribute("class","shown");',
               '\tdocument.getElementById("allocation-picto-highlight-3").setAttribute("class","hidden");',
               '}',
               
               'function setAllocationsShortage3(){',
               '\tdocument.getElementById("Nevada-pictos-normal").setAttribute("class","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage1").setAttribute("class","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage2").setAttribute("class","hidden");',
               '\tdocument.getElementById("Nevada-pictos-shortage3").setAttribute("class","shown");',
               '\tdocument.getElementById("Arizona-pictos-normal").setAttribute("class","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage1").setAttribute("class","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage2").setAttribute("class","hidden");',
               '\tdocument.getElementById("Arizona-pictos-shortage3").setAttribute("class","shown");',
               '\tdocument.getElementById("Mexico-pictos-normal").setAttribute("class","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage1").setAttribute("class","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage2").setAttribute("class","hidden");',
               '\tdocument.getElementById("Mexico-pictos-shortage3").setAttribute("class","shown");',
               '\tdocument.getElementById("allocation-picto-highlight-1").setAttribute("class","hidden");',
               '\tdocument.getElementById("allocation-picto-highlight-2").setAttribute("class","hidden");',
               '\tdocument.getElementById("allocation-picto-highlight-3").setAttribute("class","shown");',
               '}',
'function animateIE(element) {
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