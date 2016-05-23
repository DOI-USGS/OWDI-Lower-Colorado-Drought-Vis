library(whisker)
source("scripts/R/read_translation.R")

ver_file <- file("VERSION")
version <- readLines(ver_file, n = 1, warn = FALSE)
close(ver_file)

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

utah <- readLines("src_data/utah.svg")

for (lang in c("en", "es")) {
  isEn <- lang == "en"
  isEs <- lang == "es"
  data <- list(tr=translation[[lang]], lang=lang, locale=locale[[lang]], isEn=isEn, isEs=isEs,
               version=version)
  cat(whisker.render(template = template, partials = partials, data = data),
      file=paste0("public_html/", lang, "/index.html"))
  
  # also template the utah svg
  cat(whisker.render(template = utah, data = data), 
      file=file.path("public_html", lang, "img", "utah.svg"))
}
