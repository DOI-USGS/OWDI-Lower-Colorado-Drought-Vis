
build_state_pictos <- function(svg, scale=100000){
  
  picto_lw <<- '1.5'
  root_nd <- xmlRoot(svg)
  
  add_california(root_nd,scale)
  g_id <- newXMLNode('g',parent=root_nd,
             attrs=c(id="allocation-picto-highlight-3", class='hidden', stroke="none", fill="yellow"))
#   newXMLNode('rect',parent=g_id,
#              attrs=c(x="154", y="270", width="28", height="14", rx="3", ry="3"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="199", y="214", width="56", height="14", rx="3", ry="3"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="269", y="200", width="14", height="14", rx="3", ry="3"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="157", y="104", width="14", height="14", rx="3", ry="3"))
  
  g_id <- newXMLNode('g',parent=root_nd,
                     attrs=c(id="allocation-picto-highlight-2", class='hidden', stroke="none", fill="yellow"))
#   newXMLNode('rect',parent=g_id,
#              attrs=c(x="168", y="270", width="14", height="14", rx="3", ry="3"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="199", y="214", width="56", height="14", rx="3", ry="3"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="157", y="104", width="14", height="14", rx="3", ry="3"))
  
  g_id <- newXMLNode('g',parent=root_nd,
                     attrs=c(id="allocation-picto-highlight-1", class='hidden', stroke="none", fill="yellow"))
#   newXMLNode('rect',parent=g_id,
#              attrs=c(x="168", y="270", width="14", height="14", rx="3", ry="3"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="199", y="214", width="56", height="14", rx="3", ry="3"))
  newXMLNode('rect',parent=g_id,
             attrs=c(x="157", y="104", width="14", height="14", rx="3", ry="3"))
  
  add_nevada(root_nd,scale)
  add_arizona(root_nd,scale)
  add_mexico(root_nd,scale)

  invisible(svg)
}

block_picto <- function(parent, x, y, rx='2',ry='2',number,width = 10, height=10, perc_full=100,...){
  
  
  bin_full <<- 10
  bin_buffer <<- 4
  args <- expand.grid(...,stringsAsFactors = F)
  
  fill_height = height*perc_full/100
  y_bucket = bin_full+y+bin_full-bin_buffer/2
  y_fill <- bin_full+y+bin_full-bin_buffer/2+(100-perc_full)/100*bin_full
  # draws horizontal block of pictograms
  for (i in seq_len(number)){
    newXMLNode('rect',parent=parent,
               attrs=c(x=x+(bin_full+bin_buffer)*(i-1)+bin_buffer/2, y=y_fill, width=width, height=fill_height, 
                       rx=rx,ry=ry, args))
  }
  invisible(y-(bin_full+bin_buffer))
}

add_nevada <- function(root_nd,scale){
  # nevada - 3
  NV_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='Nevada-pictos','stroke'='#1975d1','stroke-width'=picto_lw,'fill'='#1975d1',class='hidden'))
  y_start = 102
  x_start = 157
  y = block_picto(NV_id,x=x_start,y=y_start,number=1)
  block_picto(NV_id,x=x_start-14,y=y,number=1)
  block_picto(NV_id,x=x_start,y=y,number=1,'fill'='none')
  
  NV_nrm <- newXMLNode('g', parent=NV_id,
                       attrs = c('id'='Nevada-pictos-normal',class='shown'))
  # -- full bucket, then partials
  block_picto(NV_nrm,x=x_start,y=y,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
  
  NV_srt <- newXMLNode('g', parent=NV_id,
                       attrs = c('id'='Nevada-pictos-shortage1',class='shown'))
  block_picto(NV_srt,x=x_start,y=y,number=1,rx="0",ry="0",perc_full = (1-13000/scale)*100,'stroke'='none')
  
  NV_srt <- newXMLNode('g', parent=NV_id,
                       attrs = c('id'='Nevada-pictos-shortage2',class='shown'))
  block_picto(NV_srt,x=x_start,y=y,number=1,rx="0",ry="0",perc_full = (1-17000/scale)*100,'stroke'='none')
  NV_srt <- newXMLNode('g', parent=NV_id,
                       attrs = c('id'='Nevada-pictos-shortage3',class='shown'))
  block_picto(NV_srt,x=x_start,y=y,number=1,rx="0",ry="0",perc_full = (1-20000/scale)*100,'stroke'='none')
  
  m_id = newXMLNode('g', parent=NV_id,
                    attrs = c('id'='nevada-mouseovers', opacity='0', visibility='hidden'))
  newXMLNode('rect',parent=m_id,
             attrs=c(x="143", y="104", width="28", height='28', onmouseover="displayAllocationName(evt,'Nevada');highlightState(evt,'Nevada')",
                     onmouseout="hideAllocationName(evt);lowlightState(evt,'Nevada')"))
}

add_california <- function(root_nd,scale){
  CA_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='California-pictos','stroke'='#1975d1','stroke-width'=picto_lw,'fill'='#1975d1',class='hidden'))
  y_start = 183
  x_start = 112
  y = block_picto(CA_id,x=x_start,y=y_start,number=3)
  y = block_picto(CA_id,x=x_start,y=y,number=3)
  y = block_picto(CA_id,x=x_start-28,y=y,number=5)
  y = block_picto(CA_id,x=x_start-56,y=y,number=7)
  y = block_picto(CA_id,x=x_start-56,y=y,number=6)
  y = block_picto(CA_id,x=x_start-70,y=y,number=6)
  y = block_picto(CA_id,x=x_start-70,y=y,number=5)
  y = block_picto(CA_id,x=x_start-84,y=y,number=5)
  y = block_picto(CA_id,x=x_start-84,y=y,number=4)
  
  m_id = newXMLNode('g', parent=CA_id,
             attrs = c('id'='california-mouseovers', opacity='0', visibility='hidden'))
  newXMLNode('rect',parent=m_id,
             attrs=c(x="28", y="87", width="70", height='56', onmouseover="displayAllocationName(evt,'California');highlightState(evt,'California')",
                     onmouseout="hideAllocationName(evt);lowlightState(evt,'California')"))
  newXMLNode('rect',parent=m_id,
             attrs=c(x="98", y="115", width="28", height='28', onmouseover="displayAllocationName(evt,'California');highlightState(evt,'California')",
                     onmouseout="hideAllocationName(evt);lowlightState(evt,'California')"))
  newXMLNode('rect',parent=m_id,
             attrs=c(x="56", y="143", width="98", height='42', onmouseover="displayAllocationName(evt,'California');highlightState(evt,'California')",
                     onmouseout="hideAllocationName(evt);lowlightState(evt,'California')"))
  newXMLNode('rect',parent=m_id,
             attrs=c(x="112", y="185", width="42", height='28', onmouseover="displayAllocationName(evt,'California');highlightState(evt,'California')",
                     onmouseout="hideAllocationName(evt);lowlightState(evt,'California')"))
}

add_arizona <- function(root_nd,scale){
  # arizona - 28
  AR_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='Arizona-pictos','stroke'='#1975d1','stroke-width'=picto_lw,'fill'='#1975d1',class='hidden'))
  x_start = 199
  y_start = 198
  y = block_picto(AR_id,x=x_start,y=y_start,number=4, 'fill'='none')
  block_picto(AR_id,x=x_start+14*5,y=y,number=1, 'fill'='none')
  y = block_picto(AR_id,x=x_start,y=y,number=5)
  y = block_picto(AR_id,x=x_start,y=y,number=6)
  y = block_picto(AR_id,x=x_start,y=y,number=6)
  block_picto(AR_id,x=x_start,y=y,number=6)
  
  AR <- newXMLNode('g', parent=AR_id,
                       attrs = c('id'='Arizona-pictos-normal',class='shown'))
  # -- full bucket, then partials
  block_picto(AR,x=x_start,y=y_start,number=4,rx="0",ry="0",perc_full = 100,'stroke'='none')
  block_picto(AR,x=x_start+14*5,y=y_start-14,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
  
  AR <- newXMLNode('g', parent=AR_id,
                      attrs = c('id'='Arizona-pictos-shortage1',class='shown'))
  block_picto(AR,x=x_start,y=y_start,number=1,rx="0",ry="0", perc_full = (1-20000/scale)*100,'stroke'='none')
  block_picto(AR,x=x_start+14*5,y=y_start-14,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
  
  AR <- newXMLNode('g', parent=AR_id,
                   attrs = c('id'='Arizona-pictos-shortage2',class='shown'))
  block_picto(AR,x=x_start,y=y_start,number=1,rx="0",ry="0", perc_full = 0,'stroke'='none')
  block_picto(AR,x=x_start+14*5,y=y_start-14,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')

  AR <- newXMLNode('g', parent=AR_id,
                   attrs = c('id'='Arizona-pictos-shortage3',class='shown'))
  block_picto(AR,x=x_start+14*5,y=y_start-14,number=1,rx="0",ry="0", perc_full = (1-80000/scale)*100,'stroke'='none')
  m_id = newXMLNode('g', parent=AR_id,
                    attrs = c('id'='arizona-mouseovers', opacity='0', visibility='hidden'))
  newXMLNode('rect',parent=m_id,
             attrs=c(x="199", y="158", width="84", height='70', onmouseover="displayAllocationName(evt,'Arizona');highlightState(evt,'Arizona')",
                     onmouseout="hideAllocationName(evt);lowlightState(evt,'Arizona')"))
}

add_mexico <- function(root_nd,scale){
  # mexico- 15
  MX_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='Mexico-pictos','stroke'='#1975d1','stroke-width'=picto_lw,'fill'='#1975d1',class='hidden'))
  x_start = 70
  y_start = 254
  block_picto(MX_id,x=x_start+14*6,y=y_start,number=2,'fill'='none')
  y = block_picto(MX_id,x=x_start+28,y=y_start,number=4)
  y = block_picto(MX_id,x=x_start,y=y,number=5)
  y = block_picto(MX_id,x=x_start,y=y,number=4)
  
  MX <- newXMLNode('g', parent=MX_id,
                   attrs = c('id'='Mexico-pictos-normal',class='shown'))
  # -- full bucket, then partials
  block_picto(MX,x=x_start+14*6,y=y_start,number=2,rx="0",ry="0",perc_full = 100,'stroke'='none')
  
#   # -- add highlighter div on bottom --
#   
#   
#   MX <- newXMLNode('g', parent=MX_id,
#                    attrs = c('id'='Mexico-pictos-shortage1',class='shown'))
#   
#   
#   block_picto(MX,x=x_start+14*6,y=y_start,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
#   block_picto(MX,x=x_start+14*7,y=y_start,number=1,rx="0",ry="0", perc_full = (1-50000/scale)*100,'stroke'='none')
#   
#   MX <- newXMLNode('g', parent=MX_id,
#                    attrs = c('id'='Mexico-pictos-shortage2',class='shown'))
#   block_picto(MX,x=x_start+14*6,y=y_start,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
#   block_picto(MX,x=x_start+14*7,y=y_start,number=1,rx="0",ry="0", perc_full = (1-70000/scale)*100,'stroke'='none')
#   
#   MX <- newXMLNode('g', parent=MX_id,
#                    attrs = c('id'='Mexico-pictos-shortage3',class='shown'))
#   block_picto(MX,x=x_start+14*6,y=y_start,number=1,rx="0",ry="0",perc_full = (1-25000/scale)*100,'stroke'='none')
  
  m_id = newXMLNode('g', parent=MX_id,
                    attrs = c('id'='mexico-mouseovers', opacity='0', visibility='hidden'))
  newXMLNode('rect',parent=m_id,
             attrs=c(x="70", y="242", width="70", height='28', onmouseover="displayAllocationName(evt,'Mexico');highlightState(evt,'mexico')",
                     onmouseout="hideAllocationName(evt);lowlightState(evt,'mexico')"))
  newXMLNode('rect',parent=m_id,
             attrs=c(x="98", y="270", width="84", height='14', onmouseover="displayAllocationName(evt,'Mexico');highlightState(evt,'mexico')",
                     onmouseout="hideAllocationName(evt);lowlightState(evt,'mexico')"))
  
}