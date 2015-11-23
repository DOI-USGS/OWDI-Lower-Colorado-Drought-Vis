ecmascript_mead_map <- function(){
  
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
  'svgDocument = evt.target.ownerDocument;',
               'svgDocument.incrementScene = this.incrementScene;',
               'svgDocument.decrementScene = this.decrementScene;',
               'svgDocument.sceneNum = 0;',
               'svgDocument.drawRiver = this.scene1;}',
               '}',
  'var elevations = {"flood":"> 1,200",
"surplus":"1,145-1,200",
  "normal":"1,075-1,145",
  "shortage-1":"1,050-1,075",
  "shortage-2":"1,025-1,050",
  "shortage-3":"< 1,025"}
  var storages = {"flood":"> 23.1",
  "surplus":"16.2 to 23.1",
  "normal":"9.6 to 16.2",
  "shortage-1":"7.7 to 9.6",
  "shortage-2":"6.0 to 7.7",
  "shortage-3":"< 6.0"}
  var conditions = 
  {"flood":"Flood Control Surplus",
  "surplus":"Quantified & Domestic Surplus",
  "normal":"Normal Condition",
  "shortage-1":"Shortage Condition Level 1",
  "shortage-2":"Shortage Condition Level 2",
  "shortage-3":"Shortage Condition Level 3"}
  function displayAllocationName(evt, name) {
  var data = {"California":{
  "flood":["4,400,000 acre-feet/year,","plus additional deliveries as requested."],
  "surplus":["4,400,000 acre-feet/year,","plus surplus water."],
  "normal":["4,400,000 acre-feet/year,","plus or minus any ICS created or delivered."],
  "shortage-1":["","4,400,000 acre-feet/year"],
  "shortage-2":["","4,400,000 acre-feet/year"],
  "shortage-3":["","4,400,000 acre-feet/year"]},
  "Arizona":{
  "flood":["2,800,000 acre-feet/year,","plus additional deliveries as requested."],
  "surplus":["2,800,000 acre-feet/year,","plus surplus water."],
  "normal":["2,800,000 acre-feet/year,","plus or minus any ICS created or delivered."],
  "shortage-1":["2,480,000 acre-feet/year,","(deliveries reduced by 320,000 acre-feet)."],
  "shortage-2":["2,400,000 acre-feet/year,","(deliveries reduced by 400,000 acre-feet)."],
  "shortage-3":["2,320,000 acre-feet/year,","(deliveries reduced by 480,000 acre-feet)."]},
  "Nevada":{
  "flood":["300,000 acre-feet/year,","plus additional deliveries as requested."],
  "surplus":["300,000 acre-feet/year,","plus surplus water."],
  "normal":["300,000 acre-feet/year,","plus or minus any ICS created or delivered."],
  "shortage-1":["287,000 acre-feet/year,","(deliveries reduced by 13,000 acre-feet)."],
  "shortage-2":["283,000 acre-feet/year,","(deliveries reduced by 17,000 acre-feet)."],
  "shortage-3":["280,000 acre-feet/year,","(deliveries reduced by 20,000 acre-feet)."]},
  "Mexico":{
  "flood":["","1,700,000 acre-feet/year."],
  "surplus":["1,500,000 acre-feet/year,","plus surplus water."],
  "normal":["1,500,000 acre-feet/year, plus or minus","any water deferred or delivered under Minute 319."],
  "shortage-1":["1,500,000 acre-feet/year, (deliveries reduced by","50,000 acre-feet; reductions may be offset under Minute 319)."],
  "shortage-2":["1,500,000 acre-feet/year, (deliveries reduced by","70,000 acre-feet; reductions may be offset under Minute 319)."],
  "shortage-3":["1,500,000 acre-feet/year, (deliveries reduced by","125,000 acre-feet; reductions may be offset under Minute 319)."]}};
  var state = document.getElementById("allocation-state").firstChild.data
  document.getElementById("allocation-value-1").firstChild.data = name + ": " + data[name][state][0];
  document.getElementById("allocation-value-2").firstChild.data = data[name][state][1];
  document.getElementById("allocation-context").firstChild.data = " ";
  }
  function setMeadCondition(storage_id){
  document.getElementById("allocation-state").firstChild.data = storage_id
  document.getElementById("mead-storage-text").firstChild.data = storages[storage_id] + " maf"
  document.getElementById("mead-elevation-text").firstChild.data = "Elevation: " + elevations[storage_id] + " feet"
  document.getElementById("mead-condition-text").firstChild.data = conditions[storage_id]
  }
  function showStateMouseovers(){
  document.getElementById("california-mouseovers").setAttribute("visibility","visbile");
  document.getElementById("nevada-mouseovers").setAttribute("visibility","visbile");
  document.getElementById("arizona-mouseovers").setAttribute("visibility","visbile");
  document.getElementById("mexico-mouseovers").setAttribute("visibility","visbile");
  }
  function hideStateMouseovers(){
  document.getElementById("california-mouseovers").setAttribute("visibility","hidden");
  document.getElementById("nevada-mouseovers").setAttribute("visibility","hidden");
  document.getElementById("arizona-mouseovers").setAttribute("visibility","hidden");
  document.getElementById("mexico-mouseovers").setAttribute("visibility","hidden");
  }
  function highlightState(evt, name) {
  document.getElementById(name).setAttribute("stroke","#808080");
  }
  function lowlightState(evt, name) {
  document.getElementById(name).setAttribute("stroke","#FFFFFF");
  }
  function hideAllocationName(evt) {
  document.getElementById("allocation-value-1").firstChild.data = " ";
  document.getElementById("allocation-value-2").firstChild.data = " ";
  document.getElementById("allocation-context").firstChild.data = " ";
  }
  function incrementScene(){
  if (svgDocument.sceneNum < scenes.length-1){
  svgDocument.sceneNum++;
  scenes[svgDocument.sceneNum]();
  }
  }
  function decrementScene(){
  if (svgDocument.sceneNum > 0){
  svgDocument.sceneNum--;
  scenes[svgDocument.sceneNum]();
  }
  }
  function scene1(){
  show("co-river-polyline");
  drawCoRiver();
  show("co-basin-polygon");
  hide("top-users");
  hide("pictogram-topfive");
  hide("mead-pictogram-legend");
  setTimeout(function(){
  {show("mouser-helper");}},5000)
  setTimeout(function(){
  {hide("mouser-helper");}},6000)
  setTimeout(function(){
  {show("mouser-helper");}},6800)
  setTimeout(function(){
  {hide("mouser-helper");}},8000)
  }
  function scene2(){
  show("Mexico-border");
  hide("mouser-helper");
  show("pictogram-topfive");
  show("top-users");
  show("non-lo-co-states");
  show("co-river-polyline");
  show("co-basin-polygon");
  resetStates();
  hide("Nevada-pictos");
  hide("California-pictos");
  hide("Arizona-pictos");
  hide("Mexico-pictos");
  hide("Mead-2D");
  hideStateMouseovers();
  
  hide("sankey-lines");
  if ("beginElement" in document.getElementById("draw-colorado-river")) {
  show("mead-pictogram-legend");
  document.getElementById("mead-pictogram-legend").setAttribute("class","legend-box");
  } else {
  show("mead-pictogram-legend");
  document.getElementById("mead-pictogram-legend").setAttribute("transform","translate(200, 135)");
  }
  }
  function scene3(){
  hide("mouser-helper");
  hide("Mexico-border");
  showStateMouseovers();
  show("Nevada-pictos");
  show("California-pictos");
  show("Arizona-pictos");
  show("Mexico-pictos");
  hide("pictogram-topfive");
  show("sankey-lines");
  hide("top-users");
  hide("co-river-polyline");
  hide("co-basin-polygon");
  moveStates();
  hide("non-lo-co-states");
  if ("beginElement" in document.getElementById("draw-colorado-river")) {
  document.getElementById("mead-pictogram-legend").setAttribute("class","legend-moved");
  } else {
  document.getElementById("mead-pictogram-legend").setAttribute("transform","translate(-135, 190)");
  }
  show("Mead-2D");
  if ("beginElement" in document.getElementById("draw-colorado-river")) {
  document.getElementById("Mead-water-level").setAttribute("class","mead-flood");
  document.getElementById("mead-elevation-text-position").setAttribute("class","mead-flood");
  } else {
  document.getElementById("Mead-water-level").setAttribute("transform","translate(0,41.81159)");
  document.getElementById("mead-elevation-text-position").setAttribute("transform","translate(0,41.81159)");
  }
  setMeadCondition("flood");
  setAllocationsNormal();
  }
  function scene4(){
  hide("mouser-helper");
  if ("beginElement" in document.getElementById("draw-colorado-river")) {
  document.getElementById("Mead-water-level").setAttribute("class","mead-surplus");
  document.getElementById("mead-elevation-text-position").setAttribute("class","mead-surplus");
  } else {
  document.getElementById("Mead-water-level").setAttribute("transform","translate(0,90.109)");
  document.getElementById("mead-elevation-text-position").setAttribute("transform","translate(0,90.109)");
  }
  setMeadCondition("surplus");
  setAllocationsNormal();
  }
  function scene5(){
  if ("beginElement" in document.getElementById("draw-colorado-river")) {
  document.getElementById("Mead-water-level").setAttribute("class","mead-normal");
  document.getElementById("mead-elevation-text-position").setAttribute("class","mead-normal");
  } else {
  document.getElementById("Mead-water-level").setAttribute("transform","translate(0,197.61)");
  document.getElementById("mead-elevation-text-position").setAttribute("transform","translate(0,197.61)");
  }
  setMeadCondition("normal");
  setAllocationsNormal();
  }
  function scene6(){
  if ("beginElement" in document.getElementById("draw-colorado-river")) {
  document.getElementById("Mead-water-level").setAttribute("class","mead-shortage-1");
  document.getElementById("mead-elevation-text-position").setAttribute("class","mead-shortage-1");
  } else {
  document.getElementById("Mead-water-level").setAttribute("transform","translate(0,300.4)");
  document.getElementById("mead-elevation-text-position").setAttribute("transform","translate(0,300.4)");
  }
  setMeadCondition("shortage-1");
  setAllocationsShortage1();
  }
  function scene7(){
  if ("beginElement" in document.getElementById("draw-colorado-river")) {
  document.getElementById("Mead-water-level").setAttribute("class","mead-shortage-2");
  document.getElementById("mead-elevation-text-position").setAttribute("class","mead-shortage-2");
  } else {
  document.getElementById("Mead-water-level").setAttribute("transform","translate(0,330.04)");
  document.getElementById("mead-elevation-text-position").setAttribute("transform","translate(0,330.04)");
  }
  setMeadCondition("shortage-2");
  setAllocationsShortage2();
  }
  function scene8(){
  if ("beginElement" in document.getElementById("draw-colorado-river")) {
  document.getElementById("Mead-water-level").setAttribute("class","mead-shortage-3");
  document.getElementById("mead-elevation-text-position").setAttribute("class","mead-shortage-3");
  } else {
  document.getElementById("Mead-water-level").setAttribute("transform","translate(0,356.52)");
  document.getElementById("mead-elevation-text-position").setAttribute("transform","translate(0,356.52)");
  }
  setMeadCondition("shortage-3");
  setAllocationsShortage3();
  }
  var scenes = [scene1, scene2, scene3, scene4, scene5, scene6, scene7,scene8];
  function move(name){
  var ani = document.getElementById(name);
  var fromValue = ani.getAttribute("attributeName");
  ani.setAttribute("from",ani.parentNode[fromValue].animVal.valueAsString);
  ani.beginElement();
  }
  function show(name){
  var ele = document.getElementById(name);
  ele.setAttribute("class","shown");
  }
  function hide(name){
  var ele = document.getElementById(name);
  ele.setAttribute("class","hidden");
  }
  function resetStates(){ 
  
  var riverDraw = document.getElementById("draw-colorado-river");
  if (!("beginElement" in riverDraw)) {
  document.getElementById("California").setAttribute("transform","translate(0,0)");
  document.getElementById("Nevada").setAttribute("transform","translate(0,0)");
  document.getElementById("Arizona").setAttribute("transform","translate(0,0)");
  document.getElementById("Mexico").setAttribute("transform","translate(0,0),scale(1.0)");
  document.getElementById("Mexico").setAttribute("stroke-width","1");
  } else {
  document.getElementById("California").setAttribute("class","california");
  document.getElementById("Nevada").setAttribute("class","nevada");
  document.getElementById("Arizona").setAttribute("class","arizona");
  document.getElementById("Mexico").setAttribute("class","mexico");
  }
  }
  function moveStates(){
  
  var riverDraw = document.getElementById("draw-colorado-river");
  if (!("beginElement" in riverDraw)) {
  document.getElementById("California").setAttribute("transform","translate(-40,-20)");
  document.getElementById("Nevada").setAttribute("transform","translate(-23,-27)");
  document.getElementById("Arizona").setAttribute("transform","translate(-8,-12)");
  document.getElementById("Mexico").setAttribute("transform","translate(-78,105),scale(0.55)");
  document.getElementById("Mexico").setAttribute("stroke-width","2.73");
  } else {
  document.getElementById("California").setAttribute("class","california-moved");
  document.getElementById("Nevada").setAttribute("class","nevada-moved");
  document.getElementById("Arizona").setAttribute("class","arizona-moved");
  document.getElementById("Mexico").setAttribute("class","mexico-moved");
  }
  }
  function drawCoRiver(name){
  var riverDraw = document.getElementById("draw-colorado-river")
  if ("beginElement" in riverDraw) {
  riverDraw.beginElement();
  } else {
  document.getElementById("co-river-polyline").setAttribute("style","stroke-linejoin:round;stroke-linecap:round;");
  }}
  function drawUserPicto(user_id){
  document.getElementById("usage-"+user_id).setAttribute("opacity","0.8");
  document.getElementById("picto-highlight-"+user_id).setAttribute("opacity","0.8");
  eval(document.getElementById("picto-"+user_id).getAttribute("onmouseover").replace("evt","null").replace("evt","null"));
  }
  function displayPictoName(evt, name) {
  document.getElementById("picto-info").firstChild.data = name;
  }
  function displayPictoValue(evt, name) {
  document.getElementById("picto-value").firstChild.data = name;
  }
  function hidePictoName(evt) {
  document.getElementById("picto-info").firstChild.data = " ";
  }
  function hidePictoValue(evt) {
  document.getElementById("picto-value").firstChild.data = " ";
  }
  function removeUserPicto(user_id){
  document.getElementById("usage-"+user_id).setAttribute("opacity","0.0");
  document.getElementById("picto-highlight-"+user_id).setAttribute("opacity","0.0");
  eval(document.getElementById("picto-"+user_id).getAttribute("onmouseout").replace("evt","null").replace("evt","null"));
  }
  function setAllocationsNormal(){
  document.getElementById("Nevada-pictos-normal").setAttribute("class","shown");
  document.getElementById("Arizona-pictos-normal").setAttribute("class","shown");
  document.getElementById("allocation-picto-highlight-1").setAttribute("class","hidden");
  document.getElementById("allocation-picto-highlight-2").setAttribute("class","hidden");
  document.getElementById("allocation-picto-highlight-3").setAttribute("class","hidden");
  document.getElementById("arizona-sankey").setAttribute("stroke-width","14");
  document.getElementById("mexico-sankey").setAttribute("stroke-width","7.5");
  }
  function setAllocationsShortage1(){
  document.getElementById("Nevada-pictos-normal").setAttribute("class","hidden");
  document.getElementById("Nevada-pictos-shortage1").setAttribute("class","shown");
  document.getElementById("Arizona-pictos-normal").setAttribute("class","hidden");
  document.getElementById("Arizona-pictos-shortage1").setAttribute("class","shown");
  document.getElementById("allocation-picto-highlight-1").setAttribute("class","shown");
  document.getElementById("allocation-picto-highlight-2").setAttribute("class","hidden");
  document.getElementById("allocation-picto-highlight-3").setAttribute("class","hidden");
  document.getElementById("arizona-sankey").setAttribute("stroke-width","12.4");
  document.getElementById("mexico-sankey").setAttribute("stroke-width","7.25");
  }
  function setAllocationsShortage2(){
  document.getElementById("Nevada-pictos-normal").setAttribute("class","hidden");
  document.getElementById("Nevada-pictos-shortage1").setAttribute("class","hidden");
  document.getElementById("Nevada-pictos-shortage2").setAttribute("class","shown");
  document.getElementById("Arizona-pictos-normal").setAttribute("class","hidden");
  document.getElementById("Arizona-pictos-shortage1").setAttribute("class","hidden");
  document.getElementById("Arizona-pictos-shortage2").setAttribute("class","shown");
  document.getElementById("allocation-picto-highlight-1").setAttribute("class","hidden");
  document.getElementById("allocation-picto-highlight-2").setAttribute("class","shown");
  document.getElementById("allocation-picto-highlight-3").setAttribute("class","hidden");
  document.getElementById("arizona-sankey").setAttribute("stroke-width","12");
  document.getElementById("mexico-sankey").setAttribute("stroke-width","7.15");
  }
  function setAllocationsShortage3(){
  document.getElementById("Nevada-pictos-normal").setAttribute("class","hidden");
  document.getElementById("Nevada-pictos-shortage1").setAttribute("class","hidden");
  document.getElementById("Nevada-pictos-shortage2").setAttribute("class","hidden");
  document.getElementById("Nevada-pictos-shortage3").setAttribute("class","shown");
  document.getElementById("Arizona-pictos-normal").setAttribute("class","hidden");
  document.getElementById("Arizona-pictos-shortage1").setAttribute("class","hidden");
  document.getElementById("Arizona-pictos-shortage2").setAttribute("class","hidden");
  document.getElementById("Arizona-pictos-shortage3").setAttribute("class","shown");
  document.getElementById("Mexico-pictos-normal").setAttribute("class","hidden");
  document.getElementById("allocation-picto-highlight-1").setAttribute("class","hidden");
  document.getElementById("allocation-picto-highlight-2").setAttribute("class","hidden");
  document.getElementById("allocation-picto-highlight-3").setAttribute("class","shown");
  document.getElementById("arizona-sankey").setAttribute("stroke-width","11.6");
  document.getElementById("mexico-sankey").setAttribute("stroke-width","6.875");
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
  }
    legend = svgDocument.getElementById("legend");
  }
  function legendViz(evt,elementname)
   {
  var r = document.getElementById(elementname).r
  if ("beginElement" in document.getElementById("timeAdvance")) {
  	if (r.animVal.value === 0){
    	legend.setAttributeNS(null,"visibility","hidden");
  	  } else {
    	legend.setAttributeNS(null,"visibility","visible");
  	  }

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
  if ("beginElement" in ele) {
    ele.beginElement();
  } else {
    document.getElementById("usage-liner").setAttribute("style","stroke:#B22C2C;stroke-width:3");
		document.getElementById("supply-liner").setAttribute("style","stroke:#0066CC;stroke-width:3");
  }
    
  }
  function visibleAxes(){
  document.getElementById("plot-contents").setAttribute("class","shown");
  setTimeout(function(){
  {timeAdvance();}},1000)
  }'
}

ecmascript_mead_proj <- function(){
  
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
               'svgDocument = evt.target.ownerDocument;',
               'svgDocument.drawTiers = this.moveInToMomsHouse;}',
               '}',

               "function ChangeText(evt, elementname, legendtext)
               {
               textelement = svgDocument.getElementById(elementname);                      
               textelement.firstChild.data = legendtext;
               }",
               'function highlightEle(evt,opacity)
               {
                 evt.target.setAttribute("fill-opacity", opacity);
               }',

               "function moveInToMomsHouse(){
                 
                 document.getElementById('flood').setAttribute('class','level-move');
                 document.getElementById('surplus').setAttribute('class','level-move');
                 document.getElementById('normal').setAttribute('class','level-move');
                 document.getElementById('shortage').setAttribute('class','level-move');
				 setTimeout(function(){
				         {
                  document.getElementById('Projected-marker').setAttribute('class','shown');
                 document.getElementById('Historical-marker').setAttribute('class','shown');
                 document.getElementById('dashed-projection').setAttribute('class','shown');
document.getElementById('condition-markers').setAttribute('class','shown');}
				     }, 1500);
                 }")
  
  
}