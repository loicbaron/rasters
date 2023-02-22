library(cleaner)
library(raster)
library(sf)

source("helpers.R")

locations <- readRDS("data/objects/locations")
# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
floods <- raster("data/Floods/fl_hazard_100_yrp.tif")

floods_extent <- crop(floods, extent(locations)) ### crop to the extent
floods_roi <- mask(x = floods_extent, mask = locations) ### delimitation to the shape geometry
plot(floods_roi)

### zonal statistics using "raster"
locations$cnt <- extract(floods_roi, locations, fun = mean, na.rm=TRUE) %>% na_replace()

# library(terra)
# r <- rast(ras)
# v <- vect(sp)
# extract(r, v, "mean")

locations$freq <- locations$cnt * locations$pop
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/S_EXP_FLO_floods.shp", layer_options = "ENCODING=UTF-8", append = FALSE)
