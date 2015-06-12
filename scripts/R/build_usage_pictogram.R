#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param values numeric vector of values to picto-scale
#' @param scale scale of values to single picto-icon
#' @import XML
usage_bar_pictogram <- function(svg, values, scale=100000, group_name, group_styles){
  
  root_nd <- xmlRoot(svg)
  
  y_axis_location <- 680
  x_axis_length <- 300
  x_axis_location <- 25
  
  bin_full <- 10
  bin_empty <- 9
  bin_buffer <- 4
  y_offset <- -(bin_full+bin_empty)*10-4
  x_offset <- -2

  def_id <- newXMLNode('defs', parent=root_nd)
  pat_1 <- newXMLNode('pattern', parent=def_id,
                      attrs = c(id="empty-picto-pattern", width=bin_full+bin_buffer, height=bin_full+bin_buffer, patternUnits="userSpaceOnUse"))
  newXMLNode('rect', parent=pat_1,
             attrs = c(x=(bin_full-bin_empty+bin_buffer)/2,y=(bin_full-bin_empty+bin_buffer)/2,'rx'="2", 'ry'="2", width=bin_empty, height=bin_empty, 'stroke'='none','fill'='#FFFFFF'))
  pat_1 <- newXMLNode('pattern', parent=def_id,
                      attrs = c(id="full-picto-pattern", width=bin_full+bin_buffer, height=bin_full+bin_buffer, patternUnits="userSpaceOnUse"))
  newXMLNode('rect', parent=pat_1,
             attrs = c(x=bin_buffer/2,y=bin_buffer/2,'rx'="2", 'ry'="2", width=bin_full, height=bin_full, 'stroke'='#0066CC','stroke-width'='2','fill'='#0066CC'))
  
  g_id <- newXMLNode('g', parent=root_nd,
             attrs = c('id'=group_name, group_styles, 'transform'=sprintf("translate(%1.1f,%1.1f)",x_axis_location,y_axis_location)))
  axes <- newXMLNode('path', parent=g_id,
             attrs=c('d'=sprintf("M%f %f l0 %f l%f 0",x_offset, 2*y_offset, -y_offset, x_axis_length), 'id'="picto-axes"))
  newXMLNode("text", parent = g_id, newXMLTextNode('Water user contracts'),
             attrs = c(id="x-pictogram-label",x=x_axis_length/2,y=y_offset+12, 'fill'='#000000', dy=".3em",'stroke'='none', style="text-anchor: middle;"))
  newXMLNode("text", parent = g_id, newXMLTextNode('Total water use'),
             attrs = c(id="y-pictogram-label",x=-15,y=y_offset/2, 'fill'='#000000', dy=".3em",'stroke'='none', style="text-anchor: middle;",
                       'transform'="rotate(-90,-15,-97.5),translate(200,0)"))
  
  for (i in 1:length(values)){
    
    num_full <- ceiling(values[i]/scale)
    frac_full <- num_full-values[i]/scale
    x = (bin_full+bin_buffer)*(i-1)
    height_full <- (bin_full+bin_buffer)*num_full
    newXMLNode('rect',parent=g_id,
               attrs=c(x=x, y=y_offset-height_full-bin_buffer/2, width=bin_full+bin_buffer, height=height_full, style="stroke:none;fill:url(#full-picto-pattern);"))
    
    empty_height <- (bin_buffer)/2+(bin_empty+2)*frac_full #stroke-width included here
    newXMLNode('rect',parent=g_id,
               attrs=c(x=x, y=y_offset-height_full-bin_buffer/2, width=bin_full+bin_buffer, height=empty_height, style="stroke:none;fill:url(#empty-picto-pattern);"))
    
  }
  
  invisible(svg)
  
}