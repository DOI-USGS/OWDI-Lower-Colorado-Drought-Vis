library(whisker)

src <- "src_data/html"
template <- NULL
partials <- list()
data <- list(tr=tr, lang="en", locale="en_US")
for (file in dir(src)) {
  name <- strsplit(file, ".mustache", fixed=TRUE)[[1]]
  if (name == "index") {
    template <- readLines(paste(src, file, sep="/"))
  } else {
    partials[[name]] <- readLines(paste(src, file, sep="/"))
  }
}

cat(whisker.render(template = template, partials = partials, data = data), file="public_html/en/index.html")
