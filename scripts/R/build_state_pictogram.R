
build_state_pictos <- function(svg, scale=100000){
  
  picto_lw <<- '1.5'
  root_nd <- xmlRoot(svg)
  
  add_california(root_nd,scale)
  add_nevada(root_nd,scale)
  add_arizona(root_nd,scale)
  add_mexico(root_nd,scale)

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

add_nevada <- function(root_nd,scale){
  # nevada - 3
  NV_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='Nevada-pictos','stroke'='#0066CC','stroke-width'=picto_lw,'fill'='#0066CC',opacity='0'))
  y_start = 102
  x_start = 157
  y = block_picto(NV_id,x=x_start,y=y_start,number=1)
  block_picto(NV_id,x=x_start-14,y=y,number=1)
  block_picto(NV_id,x=x_start,y=y,number=1,'fill'='none')
  
  NV_nrm <- newXMLNode('g', parent=NV_id,
                       attrs = c('id'='Nevada-pictos-normal'))
  # -- full bucket, then partials
  block_picto(NV_nrm,x=x_start,y=y,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
  
  NV_srt <- newXMLNode('g', parent=NV_id,
                       attrs = c('id'='Nevada-pictos-shortage1'))
  block_picto(NV_srt,x=x_start,y=y,number=1,rx="0",ry="0",perc_full = (1-13000/scale)*100,'stroke'='none')
  
  NV_srt <- newXMLNode('g', parent=NV_id,
                       attrs = c('id'='Nevada-pictos-shortage2'))
  block_picto(NV_srt,x=x_start,y=y,number=1,rx="0",ry="0",perc_full = (1-17000/scale)*100,'stroke'='none')
  NV_srt <- newXMLNode('g', parent=NV_id,
                       attrs = c('id'='Nevada-pictos-shortage3'))
  block_picto(NV_srt,x=x_start,y=y,number=1,rx="0",ry="0",perc_full = (1-20000/scale)*100,'stroke'='none')
  
}

add_california <- function(root_nd,scale){
  CA_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='California-pictos','stroke'='#0066CC','stroke-width'=picto_lw,'fill'='#0066CC',opacity='0'))
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
  
}

add_arizona <- function(root_nd,scale){
  # arizona - 28
  AR_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='Arizona-pictos','stroke'='#0066CC','stroke-width'=picto_lw,'fill'='#0066CC',opacity='0'))
  x_start = 199
  y_start = 198
  y = block_picto(AR_id,x=x_start,y=y_start,number=4, 'fill'='none')
  block_picto(AR_id,x=x_start+14*5,y=y,number=1, 'fill'='none')
  y = block_picto(AR_id,x=x_start,y=y,number=5)
  y = block_picto(AR_id,x=x_start,y=y,number=6)
  y = block_picto(AR_id,x=x_start,y=y,number=6)
  block_picto(AR_id,x=x_start,y=y,number=6)
  
  AR <- newXMLNode('g', parent=AR_id,
                       attrs = c('id'='Arizona-pictos-normal'))
  # -- full bucket, then partials
  block_picto(AR,x=x_start,y=y_start,number=4,rx="0",ry="0",perc_full = 100,'stroke'='none')
  block_picto(AR,x=x_start+14*5,y=y_start-14,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
  
  AR <- newXMLNode('g', parent=AR_id,
                      attrs = c('id'='Arizona-pictos-shortage1'))
  block_picto(AR,x=x_start,y=y_start,number=1,rx="0",ry="0", perc_full = (1-20000/scale)*100,'stroke'='none')
  block_picto(AR,x=x_start+14*5,y=y_start-14,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
  
  AR <- newXMLNode('g', parent=AR_id,
                   attrs = c('id'='Arizona-pictos-shortage2'))
  block_picto(AR,x=x_start,y=y_start,number=1,rx="0",ry="0", perc_full = 0,'stroke'='none')
  block_picto(AR,x=x_start+14*5,y=y_start-14,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')

  AR <- newXMLNode('g', parent=AR_id,
                   attrs = c('id'='Arizona-pictos-shortage3'))
  block_picto(AR,x=x_start+14*5,y=y_start-14,number=1,rx="0",ry="0", perc_full = (1-80000/scale)*100,'stroke'='none')
  
}

add_mexico <- function(root_nd,scale){
  # mexico- 15
  MX_id <- newXMLNode('g', parent=root_nd,
                      attrs = c('id'='Mexico-pictos','stroke'='#0066CC','stroke-width'=picto_lw,'fill'='#0066CC',opacity='0'))
  x_start = 70
  y_start = 254
  block_picto(MX_id,x=x_start+14*6,y=y_start,number=2,'fill'='none')
  y = block_picto(MX_id,x=x_start+28,y=y_start,number=4)
  y = block_picto(MX_id,x=x_start,y=y,number=5)
  y = block_picto(MX_id,x=x_start,y=y,number=4)
  
  MX <- newXMLNode('g', parent=MX_id,
                   attrs = c('id'='Mexico-pictos-normal'))
  # -- full bucket, then partials
  block_picto(MX,x=x_start+14*6,y=y_start,number=2,rx="0",ry="0",perc_full = 100,'stroke'='none')
  
  MX <- newXMLNode('g', parent=MX_id,
                   attrs = c('id'='Mexico-pictos-shortage1'))
  block_picto(MX,x=x_start+14*6,y=y_start,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
  block_picto(MX,x=x_start+14*7,y=y_start,number=1,rx="0",ry="0", perc_full = (1-50000/scale)*100,'stroke'='none')
  
  MX <- newXMLNode('g', parent=MX_id,
                   attrs = c('id'='Mexico-pictos-shortage2'))
  block_picto(MX,x=x_start+14*6,y=y_start,number=1,rx="0",ry="0",perc_full = 100,'stroke'='none')
  block_picto(MX,x=x_start+14*7,y=y_start,number=1,rx="0",ry="0", perc_full = (1-70000/scale)*100,'stroke'='none')
  
  MX <- newXMLNode('g', parent=MX_id,
                   attrs = c('id'='Mexico-pictos-shortage3'))
  block_picto(MX,x=x_start+14*6,y=y_start,number=1,rx="0",ry="0",perc_full = (1-25000/scale)*100,'stroke'='none')
  
}