library(jsonlite)


## earthquake data set
earthquakes <- fromJSON(
  "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson",
  simplifyVector = FALSE
)
