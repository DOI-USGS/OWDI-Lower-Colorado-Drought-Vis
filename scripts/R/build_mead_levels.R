add_mead_levels <- function(svg, mead_poly, mead_water_styles, mead_border_styles, group_id, water_id, border_id){
  full_mead_path <- sprintf('M %1.0f %1.0f L %1.0f %1.0f L %1.0f %1.0f L %1.0f %1.0f', 
                            mead_poly[[1]],mead_poly[[2]],mead_poly[[3]],mead_poly[[4]],mead_poly[[5]],mead_poly[[6]],mead_poly[[7]],mead_poly[[8]])
  
  def_nd <- xpathApply(svg, "//*[local-name()='defs']")[[1]]
  clip_nd <- newXMLNode('clipPath', parent = def_nd, attrs=c(id="Mead-clip"))
  newXMLNode('path', parent = clip_nd, attrs=c(d=full_mead_path, stroke='none'))
  
  svg_nd <- xpathApply(svg, "//*[local-name()='svg']")
  g_id <- newXMLNode('g', parent = svg_nd, attrs=c(id=group_id, opacity='0'))
  newXMLNode('rect', parent = g_id, attrs=c(id=water_id, x='280',y='20',width='255',height='430',mead_water_styles ))
  newXMLNode('path', parent = g_id, attrs=c(id=border_id, d=full_mead_path, mead_border_styles))

  invisible(svg)
}

get_mead_yval <- function(mead_poly, storage){
  peak_storage = 27.6 # in maf
  peak_elevation = mead_poly[[2]] # in px
  total_height <- mead_poly[[4]]-mead_poly[[2]] # in px
  storage_scaled <- total_height * (1-storage/peak_storage)
  
  yval <- peak_elevation + storage_scaled
  return(yval)
  
}