library(XML)

infile <- "src_data/full_text.tsv"
outfile <- "src_data/full_text.en.xml"

translation <- read.table(infile, sep="\t", stringsAsFactors = FALSE, header = TRUE, quote=NULL)
doc <- suppressWarnings(xmlTree("fullText"))
apply(translation, 1, function(row) {
  doc$addNode(row[[1]], row[[2]])
})
saveXML(doc, file=outfile)
