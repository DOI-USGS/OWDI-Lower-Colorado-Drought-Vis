#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param ele_names a character vector equal in length to the number of path elements to name
#' @param keep.attrs a character vector of attributes to keep in original paths
#' @import XML
name_svg_elements <- function(svg, ele_names, keep.attrs = c('d')){
  require(XML)

  path_nodes <- xpathApply(svg, "//*[local-name()='path']")
  for (i in 2:length(path_nodes)){
    attrs <- xmlAttrs(path_nodes[[i]])
    
    removeAttributes(path_nodes[[i]])
    addAttributes(path_nodes[[i]], .attrs = c(id=ele_names[i-1], attrs['d'])) # drop style and others
  }
  
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
  # remove viewBox node
  #removeNodes(xpathApply(svg, sprintf("//*[local-name()='path']/parent::node()"))[[1]])
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
add_animation <- function(svg, attr, parent_id, ...){
  attrs <- expand.grid(..., stringsAsFactors = FALSE)
  parent_nd <- xpathApply(svg, sprintf("//*[local-name()='path'][@id='%s']",parent_id))
  newXMLNode('animate', parent = parent_nd, 
             attrs = c('attributeName'=attr, attrs))
  invisible(svg)
  
}