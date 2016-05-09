ecmascript_mead_map <- function(language='en'){
  
  ltl <- function(x) lt(x, lang=language)
  flux.units <- ifelse(language=='en',ltl('mead-scene-units-imperial'),ltl('mead-scene-units-metric'))
  scripts <- c('function init(evt){',
               'if ( window.svgDocument == null ) {',
  'svgDocument = evt.target.ownerDocument;',
               'svgDocument.incrementScene = this.incrementScene;',
               'svgDocument.decrementScene = this.decrementScene;',
               'svgDocument.sceneNum = 0;',
               'svgDocument.drawRiver = this.scene1;}',
               '}',
  sprintf('var elevations = {"flood":"> %s",',ifelse(language=='en','1,200','365.8')),
  sprintf('"surplus":"%s",',ifelse(language=='en','1,145-1,200','349-365.8')),
  sprintf('"normal":"%s",',ifelse(language=='en',"1,075-1,145",'327.7-349')),
  sprintf('"shortage-1":"%s",',ifelse(language=='en',"1,050-1,075",'320-327.7')),
  sprintf('"shortage-2":"%s",',ifelse(language=='en',"1,025-1,050",'312.4-320')),
  sprintf('"shortage-3":"< %s"}',ifelse(language=='en',"1,025",'312.4')),
  sprintf('var storages = {"flood":"> %s",', ifelse(language=='en','23.1', '28,493')),
  sprintf('"surplus":"%s",', ifelse(language=='en',"16.2 to 23.1", "19,982 to 28,493")),
  sprintf('"normal":"%s",', ifelse(language=='en',"9.6 to 16.2", "11,841 to 19,982")),
  sprintf('"shortage-1":"%s",', ifelse(language=='en',"7.7 to 9.6", "9,498 to 11,841")),
  sprintf('"shortage-2":"%s",', ifelse(language=='en',"6.0 to 7.7", "7,401 to 9,498")),
  sprintf('"shortage-3":"< %s"}', ifelse(language=='en',"6.0", "7,401")),
  'var conditions = ',
  sprintf('{"flood":"%s",',ltl('var-condition-flood')), 
  sprintf('"surplus":"%s",',ltl('var-condition-surplus')),
  sprintf('"normal":"%s",',ltl('var-condition-normal')),
  sprintf('"shortage-1":"%s",',ltl('var-condition-shortage-1')),
  sprintf('"shortage-2":"%s",',ltl('var-condition-shortage-2')),
  sprintf('"shortage-3":"%s"}',ltl('var-condition-shortage-3')),
  'function displayAllocationName(evt, name) {
  var data = {"California":{',
  sprintf('"flood":["%s %s,","%s"],',ifelse(language=='en', '4,400,000', '5,427.3'),flux.units, ltl('var-data-text-Californnia-flood')),
  sprintf('"surplus":["%s %s,","%s"],',ifelse(language=='en', '4,400,000', '5,427.3'),flux.units, ltl('var-data-text-Californnia-surplus')),
  sprintf('"normal":["%s %s,","%s"],',ifelse(language=='en', '4,400,000', '5,427.3'),flux.units, ltl('var-data-text-Californnia-normal')),
  sprintf('"shortage-1":["","%s %s"],',ifelse(language=='en', '4,400,000', '5,427.3'),flux.units),
  sprintf('"shortage-2":["","%s %s"],',ifelse(language=='en', '4,400,000', '5,427.3'),flux.units),
  sprintf('"shortage-3":["","%s %s"]},',ifelse(language=='en', '4,400,000', '5,427.3'),flux.units),
  '"Arizona":{',
  sprintf('"flood":["%s %s,","%s"],',ifelse(language=='en', '2,800,000', '3,453.7'),flux.units, ltl('var-data-text-Arizona-flood')),
  sprintf('"surplus":["%s %s,","%s"],',ifelse(language=='en', '2,800,000', '3,453.7'),flux.units, ltl('var-data-text-Arizona-surplus')),
  sprintf('"normal":["%s %s,","%s"],',ifelse(language=='en', '2,800,000', '3,453.7'),flux.units, ltl('var-data-text-Arizona-normal')),
  sprintf('"shortage-1":["%s %s,","%s"],',ifelse(language=='en', '2,480,000', '3,059.0'),flux.units, ltl('var-data-text-Arizona-shortage-1')),#3059.0
  sprintf('"shortage-2":["%s %s,","%s"],',ifelse(language=='en', '2,400,000', '2,960.0'),flux.units, ltl('var-data-text-Arizona-shortage-2')),#2960
  sprintf('"shortage-3":["%s %s,","%s"]},',ifelse(language=='en', '2,320,000', '2,861.7'),flux.units, ltl('var-data-text-Arizona-shortage-3')), #2861.7 #2,320,000
  '"Nevada":{',
  sprintf('"flood":["%s %s,","%s"],', ifelse(language=='en', '300,000', '370.0'), flux.units, ltl('var-data-text-Nevada-flood')),
  sprintf('"surplus":["%s %s,","%s"],',ifelse(language=='en', '300,000', '370.0'), flux.units, ltl('var-data-text-Nevada-surplus')),
  sprintf('"normal":["%s %s,","%s"],',ifelse(language=='en', '300,000', '370.0'), flux.units, ltl('var-data-text-Nevada-normal')),
  sprintf('"shortage-1":["%s %s,","%s"],',ifelse(language=='en', '287,000', '354.0'), flux.units, ltl('var-data-text-Nevada-shortage-1')), #287,000 354
  sprintf('"shortage-2":["%s %s,","%s"],',ifelse(language=='en', '283,000', '349.1'), flux.units, ltl('var-data-text-Nevada-shortage-2')), #283,000
  sprintf('"shortage-3":["%s %s,","%s"]},',ifelse(language=='en', '280,000', '345.4'), flux.units, ltl('var-data-text-Nevada-shortage-3')), #280,000
  '"Mexico":{',
  sprintf('"flood":["","%s %s."],',ifelse(language=='en', '1,700,000', '2,096.9'), flux.units), #2096.9
  sprintf('"surplus":["%s %s,","%s"],',ifelse(language=='en', '1,500,000', '1,850.2'), flux.units, ltl('var-data-text-Mexico-surplus')), #1850.2
  sprintf('"normal":["%s %s,","%s"],',ifelse(language=='en', '1,500,000', '1,850.2'), flux.units, ltl('var-data-text-Mexico-normala'),ltl('var-data-text-Mexico-normalb')),
  sprintf('"shortage-1":["%s %s,","%s"],',ifelse(language=='en', '1,500,000', '1,850.2'), flux.units, ltl('var-data-text-Mexico-shortage-1a'),ltl('var-data-text-Mexico-shortage-1b')),
  sprintf('"shortage-2":["%s %s,","%s"],',ifelse(language=='en', '1,500,000', '1,850.2'), flux.units, ltl('var-data-text-Mexico-shortage-2a'),ltl('var-data-text-Mexico-shortage-2b')),
  sprintf('"shortage-3":["%s %s, %s","%s"]}};',ifelse(language=='en', '1,500,000', '1,850.2'), flux.units, ltl('var-data-text-Mexico-shortage-3a'),ltl('var-data-text-Mexico-shortage-3b')),
  'var state = document.getElementById("allocation-state").firstChild.data
  document.getElementById("allocation-value-1").firstChild.data = name + ": " + data[name][state][0];
  document.getElementById("allocation-value-2").firstChild.data = data[name][state][1];
  document.getElementById("allocation-context").firstChild.data = " ";
  }
  function setMeadCondition(storage_id){
  document.getElementById("allocation-state").firstChild.data = storage_id',
  sprintf('document.getElementById("mead-storage-text").firstChild.data = storages[storage_id] + " %s"', ifelse(language=='en','maf','mcm')),
  sprintf('document.getElementById("mead-elevation-text").firstChild.data = "%s: " + elevations[storage_id] + " %s"',
          ltl('elevation'),
          ifelse(language=='en',ltl('unitsImperialElevation'),ltl('unitsMetricElevation'))),
  'document.getElementById("mead-condition-text").firstChild.data = conditions[storage_id]
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