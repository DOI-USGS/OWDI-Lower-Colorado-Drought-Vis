
build_state_pictos <- function(svg, scale=100000){
  
  picto_lw <- '1.5'
  root_nd <- xmlRoot(svg)
  
  # california - 44
  CA_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='California-pictos','stroke'='#0066CC','stroke-width'=picto_lw,'fill'='#0066CC',opacity='0'))
  y_start = 193
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
  
  
  # nevada - 3
  NV_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='Nevada-pictos','stroke'='#0066CC','stroke-width'=picto_lw,'fill'='#0066CC',opacity='0'))
  y_start = 112
  x_start = 157
  y = block_picto(NV_id,x=x_start,y=y_start,number=1)
  block_picto(NV_id,x=x_start-14,y=y,number=1)
  NV_shr_id <- newXMLNode('g', parent=NV_id,
                      attrs = c('id'='Nevada-pictos-normal'))
  # -- full bucket, then partials
  block_picto(NV_shr_id,x=x_start,y=y,number=1,'fill'='none')
  block_picto(NV_shr_id,x=x_start,y=y,number=1,rx="0",ry="0",perc_full = 50,'stroke'='none')
  
#   NV_normal <- newXMLNode('g', parent=NV_id,
#                           attrs = c('id'='Nevada-pictos-normal','fill'='none'))
#   block_picto(NV_shr_id,x=x_start,y=y,rx='0',ry='0',number=1)
  
  
  # arizona - 28
  AR_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='Arizona-pictos','stroke'='#0066CC','stroke-width'=picto_lw,'fill'='#0066CC',opacity='0'))
  x_start = 199
  y_start = 208
  y = block_picto(AR_id,x=x_start,y=y_start,number=4)
  y = block_picto(AR_id,x=x_start,y=y,number=6)
  y = block_picto(AR_id,x=x_start,y=y,number=6)
  y = block_picto(AR_id,x=x_start,y=y,number=6)
  y = block_picto(AR_id,x=x_start,y=y,number=6)
  
  # mexico- 15
  MX_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='Mexico-pictos','stroke'='#0066CC','stroke-width'=picto_lw,'fill'='#0066CC',opacity='0'))
  x_start = 70
  y_start = 264
  y = block_picto(MX_id,x=x_start+28,y=y_start,number=6)
  y = block_picto(MX_id,x=x_start,y=y,number=5)
  y = block_picto(MX_id,x=x_start,y=y,number=4)

  
  
  invisible(svg)
}

block_picto <- function(parent, x, y, rx='2',ry='2',number,width = 10, height=10, perc_full=100,...){
  
  
  bin_full <- 10
  bin_buffer <- 4
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