library(cleaner)
library(raster)
library(sf)

source("helpers.R")


locations <- readRDS("data/objects/locations")
# data source: World Bank
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
storm_surge <- raster("data/StormSurge/ss_muis_rp0100m.tif")

# Other dataset to consider
# https://www.frontiersin.org/articles/10.3389/fmars.2020.00263/full
# data: https://zenodo.org/record/3660927#.Y1JwOuzMKDU
# Mesh Layer QGIS: https://gis.stackexchange.com/questions/357159/cannot-open-netcdf-file-in-qgis

storm_surge_extent <- crop(storm_surge, extent(locations)) ### crop to the extent
storm_surge_roi <- mask(x = storm_surge_extent, mask = locations) ### delimitation to the shape geometry
plot(storm_surge_roi)

### zonal statistics using "raster"
locations$cnt <- extract(storm_surge_roi, locations, fun = mean, na.rm=TRUE) %>% na_replace()

# library(terra)
# r <- rast(ras)
# v <- vect(sp)
# extract(r, v, "mean")

locations$freq <- locations$cnt * locations$pop
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/S_EXP_COF_storm_surge.shp", layer_options = "ENCODING=UTF-8", append = FALSE)
