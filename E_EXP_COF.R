library(cleaner)
library(raster)
library(sf)
library(terra)

source("helpers.R")


locations <- readRDS("data/objects/locations")

landcover <- rast("data/ESA_Landcover/VNM.tif")
landcover_roi <- mask(x = landcover, mask = locations)
plot(landcover_roi)
# data source: World Bank
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
storm_surge <- rast("data/StormSurge/ss_muis_rp0100m.tif")
storm_surge_roi <- mask(x = storm_surge, mask = locations)
storm_surge_roi <- project(storm_surge_roi, landcover_roi)
plot(storm_surge_roi)
# 10 = Tree cover / 20 = Shrubland / 30 = Grassland 
# 80 = Permanent water bodies / 90 = Herbaceous wetland / 95 = Mangroves / 100 = Moss and lichen
rclmat <- matrix(c(9, 31, 1, 79, 101, 1), ncol=3, byrow=TRUE)
ecosystems <- classify(landcover_roi, rclmat, others=NA)
plot(ecosystems)
storm_surge_ecosystems <- mask(storm_surge_roi, ecosystems)
plot(storm_surge_ecosystems)

### zonal statistics using "raster"
sum_storm_surge <- extract(storm_surge_ecosystems, locations, fun = sum, na.rm=TRUE) %>% na_replace()

# library(terra)
# r <- rast(ras)
# v <- vect(sp)
# extract(r, v, "sum")
locations$cnt <- sum_storm_surge[,2]
locations$freq <- locations$cnt / as.numeric(locations$area)
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/E_EXP_COF_storm_surge.shp", layer_options = "ENCODING=UTF-8", append = FALSE)
