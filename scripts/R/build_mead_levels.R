add_mead_levels <- function(svg, mead_poly, mead_water_styles, mead_border_styles, group_id, water_id, border_id){
  full_mead_path <- sprintf('M %1.0f %1.0f L %1.0f %1.0f L %1.0f %1.0f L %1.0f %1.0f', 
                            mead_poly[[1]],mead_poly[[2]],mead_poly[[3]],mead_poly[[4]],mead_poly[[5]],mead_poly[[6]],mead_poly[[7]],mead_poly[[8]])
  
  def_nd <- xpathApply(svg, "//*[local-name()='defs']")[[1]]
  clip_nd <- newXMLNode('clipPath', parent = def_nd, attrs=c(id="Mead-clip"))
  newXMLNode('path', parent = clip_nd, attrs=c(d=full_mead_path, stroke='none'))
  
  svg_nd <- xpathApply(svg, "//*[local-name()='svg']")
  g_id <- newXMLNode('g', parent = svg_nd, attrs=c(id=group_id, 'class'="hidden"))
  newXMLNode('rect', parent = newXMLNode('g', parent=g_id,attrs=c('clip-path'="url(#Mead-clip)")), attrs=c(id=water_id, x='280',y='20',width='255',height='430',mead_water_styles ))
  
  newXMLNode('path', parent = g_id, attrs=c(id=border_id, d=full_mead_path, mead_border_styles))
  t_id <- newXMLNode('g',parent=g_id, attrs = c(id = "mead-elevation-text-position"))
  newXMLNode('text', parent = t_id, newXMLTextNode('  '), attrs = c(id = "mead-elevation-text", class='small-text', x='528', fill='#FFFFFF',dy="2.8em",stroke='none',style='text-anchor:end;'))
  newXMLNode('text', parent = t_id, newXMLTextNode('  '), attrs = c(id = "mead-condition-text", class='small-text', x="528", fill='#FFFFFF',dy="4.2em",stroke='none',style='text-anchor:end;'))
  newXMLNode('text', parent = g_id, newXMLTextNode('  '),attrs = c(id = "mead-storage-text", class='label', x='463',y='425',fill='#FFFFFF',stroke='none',style='text-anchor:middle;'))
  newXMLNode('text', parent = g_id, newXMLTextNode('(million acre feet)'),attrs = c(id = "mead-storage-text", class='small-text', x='463',y='425',fill='#FFFFFF',dy="1.2em",stroke='none',style='text-anchor:middle;'))
  newXMLNode('text', parent = g_id, newXMLTextNode('  '),attrs = c(id = "allocation-info", class='label', x='55',y='450',fill='#FFFFFF',stroke='none',style='text-anchor:start;'))
  newXMLNode('text', parent = g_id, newXMLTextNode('  '),attrs = c(id = "allocation-value", class='label', x='375',y='520',fill='#FFFFFF',stroke='none',style='text-anchor:middle;'))
  newXMLNode('text', parent = g_id, newXMLTextNode('  '),attrs = c(id = "allocation-state", class='label', x='55',y='400',fill='none',stroke='none',style='text-anchor:start;'))
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

add_sankey_lines <- function(svg){
  root_nd <- xmlRoot(svg)
  g_id = newXMLNode('g',parent=root_nd,at=3,attrs = c('id'='sankey-lines','class'='hidden'))
  newXMLNode('path',parent=g_id, attrs = c(d="M91 275 C 90 490, 330 480, 405 440", stroke="#458B00", 'stroke-width'="7.5", fill="none", id='mexico-sankey', class='sankey-line'))
  newXMLNode('path',parent=g_id, attrs = c(d="M290 200 C 325 200, 330 480, 405 440", stroke="#990000", 'stroke-width'="14", fill="none", id='arizona-sankey', class='sankey-line'))
  newXMLNode('path',parent=g_id, attrs = c(d="M155 220 C 210 270, 230 250 290 340 S 330 480, 405 440", stroke="#990000", 'stroke-width'="22", fill="none", id='california-sankey', class='sankey-line'))
  newXMLNode('path',parent=g_id, attrs = c(d="M190 120 C 250 100, 280 120, 290 130 S 320 180, 340 280 S 370 430, 405 440", stroke="#990000", 'stroke-width'="3", fill="none", id='nevada-sankey', class='sankey-line'))
  
  g_id = newXMLNode('g',parent=root_nd,attrs = c('id'='sankey-mouseovers','opacity'='0'))
  newXMLNode('path',parent=g_id, attrs = c(d="M91 275 C 90 490, 330 480, 405 440", stroke="#458B00", 'stroke-width'="14", fill="none", onmouseover="displayAllocationName(evt,'Mexico')", onmouseout="hideAllocationName(evt,'Mexico')"))
  newXMLNode('path',parent=g_id, attrs = c(d="M290 200 C 325 200, 330 480, 405 440", stroke="#990000", 'stroke-width'="14", fill="none", onmouseover="displayAllocationName(evt,'Arizona')", onmouseout="hideAllocationName(evt,'Arizona')"))
  newXMLNode('path',parent=g_id, attrs = c(d="M155 220 C 210 270, 230 250 290 340 S 330 480, 405 440", stroke="#990000", 'stroke-width'="22", fill="none", onmouseover="displayAllocationName(evt,'California')", onmouseout="hideAllocationName(evt,'California')"))
  newXMLNode('path',parent=g_id, attrs = c(d="M190 120 C 250 100, 280 120, 290 130 S 320 180, 340 280 S 370 430, 405 440", stroke="#990000", 'stroke-width'="14", fill="none", onmouseover="displayAllocationName(evt,'Nevada')", onmouseout="hideAllocationName(evt,'Nevada')"))
  
  invisible(svg)
  
}