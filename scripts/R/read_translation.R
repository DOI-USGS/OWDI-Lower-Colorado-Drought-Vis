library(xml2)

translation <- list()

lookupTranslation <- function(key, lang) {
  out = translation[[lang]][[key]]
  if (is.null(out))
    return(paste0('***',key,'***'))
  else
    return(out)
  
}

lt <- lookupTranslation

for (lang in c("en", "es")) {
  # read back xml file
  xml <- as_list(read_xml(paste0("src_data/full_text.", lang, ".xml")))
  xml <- lapply(xml, function(x){if (is.list(x))unlist(x)})
  xml <- xml[!sapply(xml, is.null)]
  
  translation[[lang]] <- xml
}