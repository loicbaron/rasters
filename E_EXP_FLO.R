library(cleaner)
library(raster)
library(sf)

source("helpers.R")


locations <- readRDS("data/objects/locations")

landcover <- rast("data/ESA_Landcover/VNM.tif")
landcover_roi <- mask(x = landcover, mask = admin_with_buffer)
plot(landcover_roi)
# data source: UNEP
# # https://wesr.unepgrid.ch/?project=MX-XVK-HPH-OGN-HVE-GGN&language=en
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
floods <- rast("data/Floods/fl_hazard_100_yrp.tif")
floods_roi <- mask(x = floods, mask = admin_with_buffer)
floods_roi <- project(floods_roi, landcover_roi)
plot(floods_roi)
# 10 = Tree cover / 20 = Shrubland / 30 = Grassland
# 80 = Permanent water bodies / 90 = Herbaceous wetland / 95 = Mangroves / 100 = Moss and lichen
rclmat <- matrix(c(9, 31, 1, 79, 101, 1), ncol = 3, byrow = TRUE)
ecosystems <- classify(landcover_roi, rclmat, others = NA)
plot(ecosystems)
floods_ecosystems <- mask(floods_roi, ecosystems)
plot(floods_ecosystems)

### zonal statistics using "raster"
# Should we use admin_with_buffer?
sum_floods <- extract(floods_ecosystems, locations, fun = sum, na.rm = TRUE) %>% na_replace()

# library(terra)
# r <- rast(ras)
# v <- vect(sp)
# extract(r, v, "mean")

locations$cnt <- sum_floods[, 2]
locations$freq <- locations$cnt / as.numeric(locations$area)
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/E_EXP_FLO_floods.shp", layer_options = "ENCODING=UTF-8", append = FALSE)
