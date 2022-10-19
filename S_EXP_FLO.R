library(raster)
library(sf)

source("helpers.R")


locations <- readRDS("data/objects/locations")
my_raster <- raster("data/Floods/fl_hazard_100_yrp.tif")

r2 <- crop(my_raster, extent(locations)) ### crop to the extent
my_raster_clip <- mask(x = r2, mask = locations) ### delimitation to the shape geometry
plot(my_raster_clip)

### zonal statistics using "raster"
locations$cnt <- extract(my_raster_clip, locations, fun = mean)

# library(terra)
# r <- rast(ras)
# v <- vect(sp)
# extract(r, v, "mean")

locations$freq <- locations$cnt / locations$pop
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/S_EXP_FLO_floods.shp", layer_options = "ENCODING=UTF-8", append = FALSE)
