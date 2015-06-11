library(leafletR)
df <- sp::SpatialPointsDataFrame(
  cbind(
    (runif(20) - .5) * 10 - 90.620130,  # lng
    (runif(20) - .5) * 3.8 + 25.638077  # lat
  ),
  data.frame(type = factor(
    ifelse(runif(20) > 0.75, "pirate", "ship"),
    c("ship", "pirate")
  ))
)
################################################################################
#leafletR implementation
################################################################################
df_gjson <- toGeoJSON(df)

play_leafletR <- leafletR::leaflet(data=df_gjson,
                                   dest=".",
                                   incl.data=TRUE,
                                   controls="all")
play_leafletR
