library(whisker)
source("scripts/R/read_translation.R")

src <- "src_data/html"
template <- NULL
partials <- list()

locale <- list(en="en_US", es="es_MX")

for (file in dir(src)) {
  name <- strsplit(file, ".mustache", fixed=TRUE)[[1]]
  if (name == "index") {
    template <- readLines(paste(src, file, sep="/"))
  } else {
    partials[[name]] <- readLines(paste(src, file, sep="/"))
  }
}
for (lang in c("en", "es")) {
  data <- list(tr=translation[[lang]], lang=lang, locale=locale[[lang]])
  cat(whisker.render(template = template, partials = partials, data = data),
      file=paste0("public_html/", lang, "/index.html"))
}