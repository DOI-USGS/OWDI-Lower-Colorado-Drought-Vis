#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param ele_names a character vector equal in length to the number of path elements to name
#' @param keep.attrs a character vector of attributes to keep in original paths
#' @import XML
name_svg_elements <- function(svg, ele_names, keep.attrs = c('d')){
  require(XML)

  path_nodes <- xpathApply(svg, "//*[local-name()='path']")
  for (i in 1:length(path_nodes)){
    attrs <- xmlAttrs(path_nodes[[i]])
    
    removeAttributes(path_nodes[[i]])
    addAttributes(path_nodes[[i]], .attrs = c(id=ele_names[i], attrs['d'])) # drop style and others
  }
  
  invisible(svg)
}

remove_svg_elements <- function(svg, elements){
  root_nd <- xmlRoot(svg)
  
  for (i in 1:length(elements)){
    xpath = sprintf("//*[local-name()='%s']", elements[i])
    if (names(elements)[i] != ""){
      xpath <- sprintf("%s[@id='%s']",xpath,names(elements)[i])
    }
    kids <- xpathApply(svg, xpath)
    parent_id <- xpathApply(svg, paste0(xpath,"/parent::node()"))[[1]]
    removeChildren(parent_id, kids = kids)
    
  }
  invisible(svg)
}

clean_svg_doc <- function(svg, keep.attrs = c('viewBox','version')){
  svg_nd <- xpathApply(svg, "//*[local-name()='svg']")
  attrs <- xmlAttrs(svg_nd[[1]])
  removeAttributes(svg_nd[[1]])
  addAttributes(svg_nd[[1]], .attrs = c(preserveAspectRatio= "xMinYMin meet", attrs[keep.attrs]))
  
  junk_nd <- xpathApply(svg, "//*[local-name()='rect']")
  g_nd <- xpathApply(svg, "//*[local-name()='g']")[[1]]
  removeChildren(g_nd, kids = c(junk_nd, xpathApply(svg, "//*[local-name()='path']")[[1]]))
  removeAttributes(g_nd)
  addAttributes(g_nd, .attrs = c('id'='delete_group'))
  invisible(svg)
}

#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param groups a list of groupings that match element IDs
#' @import XML
group_svg_elements <- function(svg, groups){
  
  # create groups
  root_nd <- xmlRoot(svg)
  for (i in 1:length(groups)){
    if (is.list(groups)){
      g_id <- newXMLNode('g', parent = root_nd, attrs = c('id' = names(groups)[i]))
      for (j in 1:length(groups[[i]])){
        path_nodes <- xpathApply(svg, sprintf("//*[local-name()='path'][@id='%s']",groups[[i]][j]))
        addChildren(g_id, kids = list(path_nodes))
      }
    } else {
      
      path_nodes <- xpathApply(svg, sprintf("//*[local-name()='path'][@id='%s']",groups[i]))
      parent_nd <- xpathApply(svg, sprintf("//*[local-name()='path'][@id='%s']/parent::node()",groups[i]))
      g_id <- newXMLNode('g', parent = parent_nd)
      addChildren(g_id, kids = list(path_nodes))
    }
  }
  invisible(svg)
}

group_svg_group <- function(svg, groups){
  
  # create groups
  root_nd <- xmlRoot(svg)
  for (i in 1:length(groups)){
    if (is.list(groups)){
      g_id <- newXMLNode('g', parent = root_nd, attrs = c('id' = names(groups)[i]))
      for (j in 1:length(groups[[i]])){
        path_nodes <- xpathApply(svg, sprintf("//*[local-name()='g'][@id='%s']",groups[[i]][j]))
        addChildren(g_id, kids = list(path_nodes))
      }
    } else {
      
      path_nodes <- xpathApply(svg, sprintf("//*[local-name()='g'][@id='%s']",groups[i]))
      parent_nd <- xpathApply(svg, sprintf("//*[local-name()='g'][@id='%s']/parent::node()",groups[i]))
      g_id <- newXMLNode('g', parent = parent_nd)
      addChildren(g_id, kids = list(path_nodes))
    }
  }
  invisible(svg)
}

#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param attrs a list of styles that match group or element IDs
#' @import XML
attr_svg_groups <- function(svg, attrs){

  for (i in 1:length(attrs)){
    g_id <- xpathApply(svg, sprintf("//*[local-name()='g'][@id='%s']",names(attrs)[i]))[[1]]
    addAttributes(g_id, .attrs = attrs[[i]])
  }
  invisible(svg)
}

attr_svg_paths <- function(svg, attrs){
  
  for (i in 1:length(attrs)){
    g_id <- xpathApply(svg, sprintf("//*[local-name()='path'][@id='%s']",names(attrs)[i]))[[1]]
    addAttributes(g_id, .attrs = attrs[[i]])
  }
  invisible(svg)
}

edit_attr_svg <- function(svg, attrs){
  svg_nd <- xpathApply(svg, "//*[local-name()='svg']")
  svg_attrs <- xmlAttrs(svg_nd[[1]])
  keep.attrs <- !names(svg_attrs) %in% names(attrs)
  removeAttributes(svg_nd[[1]])
  addAttributes(svg_nd[[1]], .attrs = c(attrs, svg_attrs[keep.attrs]))

  invisible(svg)
}

attr_svg <- function(svg, attrs, type){
  for (i in 1:length(attrs)){
    g_id <- xpathApply(svg, sprintf("//*[local-name()='%s'][@id='%s']",type, names(attrs)[i]))[[1]]
    addAttributes(g_id, .attrs = attrs[[i]])
  }
  invisible(svg)
}

add_background_defs <- function(svg, id, image_url){
  root_nd <- xmlRoot(svg)
  def_nd <- newXMLNode("defs",parent = root_nd, at = 0)
  pt_nd <- newXMLNode('pattern',parent=def_nd, attrs = c(id=id, patternUnits='userSpaceOnUse',x=-50,width=640, height=547))
  #newXMLNode('image', parent=pt_nd, attrs = c('xlink:href'=image_url, width=610, height=547))
  newXMLNode('rect', parent=pt_nd, attrs = c('fill'="black",opacity='0.9', width=640, height=547))
  invisible(svg)
  
}

add_flag_defs <- function(svg, id,x,y, width,height, image_url){
  root_nd <- xmlRoot(svg)
  def_nd <- newXMLNode("defs",parent = root_nd, at = 0)
  pt_nd <- newXMLNode('pattern',parent=def_nd, attrs = c(id=id, patternUnits='userSpaceOnUse',x=x,y=y,width=width, height=height))
  #newXMLNode('rect', parent=pt_nd, attrs = c(fill='white', width=width, height=height))
  newXMLNode('image', parent=pt_nd, attrs = c('xlink:href'=image_url, width=width, height=height, opacity=1))
  invisible(svg)
  
}


#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param r character vector radius of circle
#' @param id character vector mask id
#' @param ... additional attributes of circle mask (e.g., cx, cy)
#' @import XML
add_radial_mask <- function(svg, r, id, ...){
  root_nd <- xmlRoot(svg)
  def_nd <- newXMLNode('defs', parent = root_nd) 
  grad_nd <- newXMLNode('radialGradient', parent = def_nd,
                        attrs=c(id="Gradient"))
  newXMLNode("stop",parent = grad_nd, 
             attrs=c(offset="0",'stop-color'="white",'stop-opacity'="1"))
  newXMLNode("stop",parent = grad_nd, 
             attrs=c(offset="0.35",'stop-color'="white",'stop-opacity'="1"))
  newXMLNode("stop",parent = grad_nd, 
             attrs=c(offset="1",'stop-color'="white",'stop-opacity'="0"))
  for (i in 1:length(r)){
    mask_nd <- newXMLNode('mask', parent = def_nd,
                          attrs=c(id=id[i]))
    attrs <- expand.grid(..., stringsAsFactors = FALSE)
    newXMLNode('circle', parent = mask_nd,
               attrs = c('r'=r[i], stroke="none", fill="url(#Gradient)", attrs[i,]))
  }
  invisible(svg)
  
}
#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param attr a character vector of length 1 for an animation attribute name (e.g., 'stroke-dashoffset')
#' @param parent_id the id of the parent node for the animation
#' @param ... additional attributes for the animation
add_animation <- function(svg, attr, parent_id, element = 'path', ...){
  attrs <- expand.grid(..., stringsAsFactors = FALSE)
  parent_nd <- xpathApply(svg, sprintf("//*[local-name()='%s'][@id='%s']",element, parent_id))
  newXMLNode('animate', parent = parent_nd, 
             attrs = c('attributeName'=attr, attrs))
  invisible(svg)
  
}

add_animateTransform <- function(svg, attr = "transform", parent_id, element = 'path', ...){
  attrs <- expand.grid(..., stringsAsFactors = FALSE)
  parent_nd <- xpathApply(svg, sprintf("//*[local-name()='%s'][@id='%s']",element, parent_id))
  newXMLNode('animateTransform', parent = parent_nd, 
             attrs = c('attributeName'=attr, attributeType="XML", attrs))
  invisible(svg)
  
}

add_rect <- function(svg, at=NA, ...){
  attrs <- expand.grid(..., stringsAsFactors = FALSE)
  svg_nd <- xpathApply(svg, "//*[local-name()='svg']")
  newXMLNode('rect', parent = svg_nd, attrs=attrs,at = at)
  
  invisible(svg)
}

add_text<- function(svg, text, ...){
  attrs <- expand.grid(..., stringsAsFactors = FALSE)
  svg_nd <- xpathApply(svg, "//*[local-name()='svg']")
  newXMLNode('text', parent = svg_nd, newXMLTextNode(text), attrs=attrs)
  
  invisible(svg)
}

add_ecmascript <- function(svg, text){
  svg_nd <- xpathApply(svg, "//*[local-name()='svg']")
  
  newXMLNode('script', at=0, parent = svg_nd, attrs=c(type='text/ecmascript'), 
             newXMLTextNode(paste0(text,collapse='\n'), cdata = TRUE))

  invisible(svg)
  
}

add_scene_buttons <- function(svg, form.factor='desktop'){
  root_nd <- xmlRoot(svg)
  g_in = newXMLNode('g',parent=root_nd,attrs = c(id='decrement-scene'))
  if (form.factor=='desktop'){
    newXMLNode('rect',parent=g_in, attrs = c(x='-50',width="35",height="547",fill="white",opacity="0.3"))
    newXMLNode('path',parent=g_in, attrs = c(d="M-25 293.5 L-40 273.5 L-25 253.5",style="stroke:grey;stroke-width:7;fill:none",'stroke-linecap'="round"))
    newXMLNode('rect',parent=g_in, attrs = c(x='-50',width="35",height="547",fill="white",opacity="0.0",onclick="decrementScene()"))
  } else {
    newXMLNode('rect',parent=g_in, attrs = c(x='-65',width="50",height="547",fill="white",opacity="0.3"))
    newXMLNode('path',parent=g_in, attrs = c(d="M-30 299 L-50 273.5 L-30 248",style="stroke:grey;stroke-width:12;fill:none",'stroke-linecap'="round"))
    newXMLNode('rect',parent=g_in, attrs = c(x='-65',width="50",height="547",fill="white",opacity="0.0",onclick="decrementScene()"))
  }
  
  g_dc = newXMLNode('g',parent=root_nd,attrs = c(id='increment-scene'))
  if (form.factor=='desktop'){
    newXMLNode('rect',parent=g_dc, attrs = c(x='555',width="35",height="547",fill="white",opacity="0.3"))
    newXMLNode('path',parent=g_dc, attrs = c(d="M565 293.5 L580 273.5 L565 253.5",style="stroke:grey;stroke-width:7;fill:none",'stroke-linecap'="round",onclick="incrementScene()"))
    newXMLNode('path',parent=g_dc, attrs = c(id="mouser-helper", d="m201.453995,112.872002l-183.068584,-100.156902l78.608601,195.193897l31.298012,-50.675995l61.883972,67.641998l23.437012,-22.837006l-63.26799,-66.993988l51.108978,-22.172005z", 
                                             fill="#ffffff", stroke="#000000", 'stroke-width'="8", 'stroke-linejoin'="round", opacity="0.6", transform="translate(555,280),scale(0.15,0.15)", class="hidden"))
    newXMLNode('rect',parent=g_dc, attrs = c(x='555',width="35",height="547",fill="white",opacity="0.0",onclick="incrementScene()"))
  } else {
    newXMLNode('rect',parent=g_dc, attrs = c(x='555',width="50",height="547",fill="white",opacity="0.3"))
    newXMLNode('path',parent=g_dc, attrs = c(d="M570 299 L590 273.5 L570 248",style="stroke:grey;stroke-width:12;fill:none",'stroke-linecap'="round",onclick="incrementScene()"))
    newXMLNode('path',parent=g_dc, attrs = c(id="mouser-helper", d="m201.453995,112.872002l-183.068584,-100.156902l78.608601,195.193897l31.298012,-50.675995l61.883972,67.641998l23.437012,-22.837006l-63.26799,-66.993988l51.108978,-22.172005z", 
                                             fill="#ffffff", stroke="#000000", 'stroke-width'="8", 'stroke-linejoin'="round", opacity="0.6", transform="translate(555,280),scale(0.15,0.15)", class="hidden"))
    newXMLNode('rect',parent=g_dc, attrs = c(x='555',width="50",height="547",fill="white",opacity="0.0",onclick="incrementScene()"))
  }
  invisible(svg)
  
}

add_picto_legend <- function(svg){
  root_nd <- xmlRoot(svg)
  g_nd = newXMLNode('g',parent=root_nd,attrs = c(id='mead-pictogram-legend',transform='translate(200,135)',class="legend-hidden"))
  newXMLNode('rect',parent=g_nd,attrs=c(x="150", y="270", width="130", height="45", stroke="#FFFFFF", fill="none"))
  newXMLNode('text', parent=g_nd, newXMLTextNode("Legend"), attrs=c(class='legend-text', x="215", y="278", fill="#FFFFFF", dy="0.7em", stroke="none", style="text-anchor: middle;"))
  newXMLNode('rect',parent=g_nd,attrs=c(x="156", y="300", width="10", height="10", rx="2", ry="2", fill="#1975d1", stroke="#1975d1", 'stroke-width'="1.5"))
  newXMLNode('text', parent=g_nd, newXMLTextNode("100,000 acre-feet"), attrs=c(class='small-text', x="175", y="300", fill="#FFFFFF", dy="0.7em", stroke="none", style="text-anchor: left;"))
  invisible(svg)
}

add_css <- function(svg, text){
  svg_nd <- xpathApply(svg, "//*[local-name()='svg']")
  
  newXMLNode('style', parent = svg_nd, attrs=c(type="text/css"), 
             newXMLTextNode(paste0(text,collapse='\n'), cdata = TRUE))
  
  invisible(svg)
  
}