library(yaml)
library(jsonlite)

metafile <- "scripts/METADATA.yaml"
jsonOutput <- "public_html/data/metadata.json"
markdownOutput <- "METADATA.md"

metadata <- yaml.load_file(metafile)

write_json(metadata, jsonOutput)
write_markdown(metadata, markdownOutput)

write_json <- function(metadata.list, json.file) {
  fh <- file(json.file, "wt")
  jsonText <- toJSON(metadata.list, auto_unbox = TRUE, pretty=TRUE)
  cat(jsonText, file=fh)
  close(fh)
}

write_markdown <- function(metadata.list, md.file) {
  
}