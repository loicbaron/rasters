library(raster)
library(sf)

source("helpers.R")


locations <- readRDS("data/objects/locations")
# https://energydata.info/dataset/global-coastal-flood-hazard
# https://www.frontiersin.org/articles/10.3389/fmars.2020.00263/full

# data: https://zenodo.org/record/3660927#.Y1JwOuzMKDU
# Mesh Layer QGIS: https://gis.stackexchange.com/questions/357159/cannot-open-netcdf-file-in-qgis
my_raster <- raster("data/StormSurge/ss_muis_rp0100m.tif")

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
st_write(locations, "output/S_EXP_COF_floods.shp", layer_options = "ENCODING=UTF-8", append = FALSE)
