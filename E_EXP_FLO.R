library(raster)
library(sf)

source("helpers.R")


locations <- readRDS("data/objects/locations")
# data source: UNEP
# # https://wesr.unepgrid.ch/?project=MX-XVK-HPH-OGN-HVE-GGN&language=en
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
floods <- rast("data/Floods/fl_hazard_100_yrp.tif")
landcover <- rast("data/ESA_Landcover/VNM.tif")
ecosystems <- classify(landcover, c(10, 20, 30, 90, 95, 100))
plot(ecosystems)
my_raster <- crop(floods, ecosystems)
plot(my_raster)
my_raster_clip <- mask(x = r2, mask = admin_with_buffer) ### delimitation to the shape geometry
plot(my_raster_clip)

### zonal statistics using "raster"
locations$cnt <- extract(my_raster_clip, locations, fun = mean)

# library(terra)
# r <- rast(ras)
# v <- vect(sp)
# extract(r, v, "mean")

locations$freq <- locations$cnt / locations$area
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/E_EXP_FLO_floods.shp", layer_options = "ENCODING=UTF-8", append = FALSE)
