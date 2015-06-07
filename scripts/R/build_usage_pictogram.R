#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param values numeric vector of values to picto-scale
#' @param scale scale of values to single picto-icon
#' @import XML
usage_bar_pictogram <- function(svg, values, scale=100000){
  
  root_nd <- xmlRoot(svg)

  def_id <- newXMLNode('defs', parent=root_nd)
  pat_1 <- newXMLNode('pattern', parent=def_id,
                      attrs = c(id="empty-picto-pattern", x="2", y="98", width="14", height="14", patternUnits="userSpaceOnUse"))
  newXMLNode('rect', parent=pat_1,
             attrs = c(x="2.5",y="2.5",'rx'="2", 'ry'="2", width="9", height="9", 'stroke'='none','fill'='#FFFFFF'))
  pat_1 <- newXMLNode('pattern', parent=def_id,
                      attrs = c(id="full-picto-pattern", x="2", y="98", width="14", height="14", patternUnits="userSpaceOnUse"))
  newXMLNode('rect', parent=pat_1,
             attrs = c(x="2",y="2",'rx'="2", 'ry'="2", width="10", height="10", 'stroke'='#0066CC','stroke-width'='2','fill'='#0066CC'))
  
  g_id <- newXMLNode('g', parent=root_nd,
             attrs = c('id'="picto-plot-axis",'stroke'='#000000',fill='none',
                       'stroke-width'='2.5', 'transform'="translate(50,280)"))
  newXMLNode('path', parent=g_id,
             attrs=c('d'="M0 0 L0 100 l300 0", 'id'="picto-axes"))
  
  newXMLNode('rect',parent=g_id,
             attrs=c(x="0", y="29", width="15", height="70", style="stroke:none;fill:url(#full-picto-pattern);"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="0", y="29", width="15", height="6.8", style="stroke:none;fill:url(#empty-picto-pattern);"))
  
  newXMLNode('rect',parent=g_id,
             attrs=c(x="14", y="58", width="15", height="42", style="stroke:none;fill:url(#full-picto-pattern);"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="14", y="58", width="15", height="2.8", style="stroke:none;fill:url(#empty-picto-pattern);"))
  
  newXMLNode('rect',parent=g_id,
             attrs=c(x="28", y="58", width="15", height="42", style="stroke:none;fill:url(#full-picto-pattern);"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="28", y="58", width="15", height="7.8", style="stroke:none;fill:url(#empty-picto-pattern);"))
  
  invisible(svg)
  
}