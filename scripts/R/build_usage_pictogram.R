#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param values numeric vector of values to picto-scale
#' @param scale scale of values to single picto-icon
#' @import XML
usage_bar_pictogram <- function(svg, values, value_mouse, value_contract, scale=100000, group_name, group_styles, language){
  
  picto_lw <- '1.5'
  
  root_nd <- xmlRoot(svg)
  
  y_axis_location <- 680
  x_axis_length <- 300
  x_axis_location <- 25
  
  bin_full <- 10
  bin_empty <- 9
  bin_buffer <- 4
  y_offset <- -(bin_full+bin_empty)*10-4
  x_offset <- -2

  g_id <- newXMLNode('g', parent=root_nd,
             attrs = c('id'=group_name, group_styles ))
  ax_g <- newXMLNode('g', parent=g_id, attrs = c('transform'=sprintf("translate(%1.1f,%1.1f)",x_axis_location,y_axis_location)))
  axes <- newXMLNode('path', parent=ax_g,
             attrs=c('d'=sprintf("M%1.1f %1.1f l0 %1.1f l%1.1f 0",x_offset, 3*y_offset,-2*y_offset,x_axis_length), 'id'="picto-axes"))
  newXMLNode("text", parent = ax_g, newXMLTextNode('  '),
             attrs = c(class="label", id="picto-info",x="55",y="-290", 'fill'='#FFFFFF', 'stroke'='none', style="text-anchor: left;"))
  newXMLNode("text", parent = ax_g, newXMLTextNode('  '),
             attrs = c(class="label", id="picto-value",x="55",y="-290", 'fill'='#FFFFFF', dy='-1.0em','stroke'='none', style="text-anchor: left;"))
    
  newXMLNode("text", parent = ax_g, newXMLTextNode(lt('x-pictogram-label', language)),
             attrs = c(id="x-pictogram-label",x=x_axis_length/2,y=y_offset+12, 'fill'='#FFFFFF', dy=".3em",'stroke'='none', style="text-anchor: middle;"))
  sub.label.x <- c('es'=lt('x-pictogram-sub-label-metric',language), 'en'=lt('x-pictogram-sub-label-imperial',language))
  newXMLNode("text", parent = ax_g, newXMLTextNode(sub.label.x[[language]]),
             attrs = c(id="x-pictogram-sub-label",x=x_axis_length/2,y=y_offset+12, 'fill'='#FFFFFF', dy="1.5em",'stroke'='none', style="text-anchor: middle;"))
  
  newXMLNode("text", parent = ax_g, newXMLTextNode(lt('y-pictogram-label',language)),
             attrs = c(id="y-pictogram-label",x=-15,y=y_offset/2, 'fill'='#FFFFFF', dy=".3em",'stroke'='none', style="text-anchor: middle;",
                       'transform'="rotate(-90,-15,-97.5),translate(280,0)"))

  
  for (i in 1:length(values)){
    
    g_pict_par <- newXMLNode('g', parent=g_id, attrs = c(id = paste0('picto-usage-parent-',i), 'transform'=sprintf("translate(%1.1f,%1.1f)",x_axis_location,486))) # need to calc this...
    
    num_full <- ceiling(values[i]/scale)
    frac_full <- 1-(num_full-values[i]/scale)
    x = (bin_full+bin_buffer)*(i-1)+bin_buffer/2
  
    # -- add highlighter div on bottom --
    newXMLNode('rect',parent=g_pict_par,
               attrs=c(x=x-bin_buffer/2,y=-(bin_full+bin_buffer)*num_full-bin_buffer/2, 
                       width=bin_full+bin_buffer, height=(bin_full+bin_buffer)*num_full, 
                       rx='3',ry='3','stroke-width'='0','fill'='#00CC99', opacity='0.0',id = paste0('picto-highlight-',i)))
    
    g_picto <- newXMLNode('g', parent=g_pict_par, attrs = c(id = paste0('picto-usage-',i),'stroke'='#0066CC','stroke-width'=picto_lw,'fill'='#0066CC'))
    # -- create empties -- 
    for (j in seq_len(num_full-1)){
      newXMLNode('rect',parent=g_picto,
                 attrs=c(x=x,y=-(bin_full+bin_buffer)*j, width=bin_full, height=bin_full, 
                         rx='2',ry='2'))
    }
    j = num_full
    # -- partial fill --
    newXMLNode('rect',parent=g_picto,
               attrs=c(x=x,y=-(bin_full+bin_buffer)*j+bin_full*(1-frac_full), width=bin_full, height=bin_full*frac_full, 
                       rx='0',ry='0','stroke'='none'))
    # -- full bucket outline --
    newXMLNode('rect',parent=g_picto,
               attrs=c(x=x,y=-(bin_full+bin_buffer)*j, width=bin_full, height=bin_full, 
                       rx='2',ry='2','fill'='none'))
    # -- add clear mouseover rect on top --
    units <- c('en'=lt('mead-pictogram-legend-units-imperial',language), 'es'=lt('mead-pictogram-legend-units-metric',language))
    on_mouseovr <- sprintf("displayPictoName(evt, '%s');displayPictoValue(evt, '%s %s');document.getElementById('picto-highlight-%s').setAttribute('opacity','0.8');document.getElementById('usage-%s').setAttribute('opacity','0.8');",
                           value_mouse[i], value_contract[i], units[[language]], i, i)
    on_mouseout <- sprintf("hidePictoName(evt);hidePictoValue(evt);document.getElementById('picto-highlight-%s').setAttribute('opacity','0.0');document.getElementById('usage-%s').setAttribute('opacity','0.0');",i,i)
    newXMLNode('rect',parent=g_pict_par,
               attrs=c(id = paste0('picto-',i),x=x-bin_buffer/2,y=-(bin_full+bin_buffer)*num_full-bin_buffer/2, 
                       width=bin_full+bin_buffer, height=(bin_full+bin_buffer)*num_full, 
                       rx='3',ry='3','stroke-width'='0','fill'='#00CC99', opacity='0.0', onmouseover=on_mouseovr, onmouseout=on_mouseout))
  }
  
  invisible(svg)
  
}