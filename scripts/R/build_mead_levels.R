add_mead_levels <- function(svg, group_name, group_styles){
  full_mead_path <- 'M 535 20 L 535 450 L 400 450 L280 20'
  
  def_nd <- xpathApply(svg, "//*[local-name()='defs']")[[1]]
  clip_nd <- newXMLNode('clipPath', parent = def_nd, attrs=c(id="Mead-clip"))
  newXMLNode('path', parent = clip_nd, attrs=c(d=full_mead_path, stroke='none'))
  
  svg_nd <- xpathApply(svg, "//*[local-name()='svg']")
  g_id <- newXMLNode('g', parent = svg_nd, attrs=c(id='Mead-2D'))
  newXMLNode('rect', parent = g_id, attrs=c(x='280',y='20',width='255',height='430', fill='#0066CC',stroke='none','clip-path'="url(#Mead-clip)"))
  newXMLNode('path', parent = g_id, attrs=c(d=full_mead_path, fill='none','stroke-width'="2.5",stroke='#FFFFFF'))

  invisible(svg)
}