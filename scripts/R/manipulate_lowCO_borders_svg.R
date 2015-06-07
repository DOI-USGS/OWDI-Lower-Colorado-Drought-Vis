#' @param svg_file a file.path for svg file
#' @param ele_names a character vector equal in length to the number of path elements to name
#' @import XML
name_svg_elements <- function(svg_file, ele_names){
  require(XML)

  xml_doc <- xmlParse(svg_file, useInternalNode=TRUE)
  path_nodes <- xpathApply(xml_doc, "//*[local-name()='path']")
  attrs <- xmlAttrs(path_nodes[[2]])
  
  removeAttributes(path_nodes[[2]])
  addAttributes(path_nodes[[2]], .attrs = c(id=ele_names[1], attrs['d'])) # drop style and others
  
}