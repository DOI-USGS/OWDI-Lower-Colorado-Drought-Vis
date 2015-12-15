library(XML)

infile <- "src_data/full_text.tsv"
outfile <- "src_data/full_text.en.xml"

cleanText <- function(x) {
  x <- gsub('\x89|\xd5', "'", x, perl = TRUE)
  x <- gsub('\xd0', "-", x, perl = TRUE)
  x <- gsub('\xd2|\xd3', '"', x, perl = TRUE)
  x <- iconv(x, "UTF-8", "ASCII", sub="")
}

translation <- read.table(infile, sep="\t", stringsAsFactors = FALSE, header = TRUE, quote = "\"")
doc <- suppressWarnings(xmlTree("fullText"))
apply(translation, 1, function(row) {
  doc$addNode(row[[1]], cleanText(row[[2]]))
})
saveXML(doc, file=outfile)