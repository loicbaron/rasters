library(cleaner)
library(raster)
library(sf)

source("helpers.R")

locations <- readRDS("data/objects/locations")
# https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_physexp&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
# population affected
# my_raster <- raster("data/Cyclones/cy_physexp.tif")

# https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_frequency&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
my_raster <- raster("data/Cyclones/cy_frequency.tif")

r2 <- crop(my_raster, extent(locations)) ### crop to the extent
my_raster_clip <- mask(x = r2, mask = locations) ### delimitation to the shape geometry
plot(my_raster_clip)

### zonal statistics using "raster"
locations$cnt <- extract(my_raster_clip, locations, fun = mean, na.rm = TRUE) %>% na_replace()

# library(terra)
# r <- rast(ras)
# v <- vect(sp)
# extract(r, v, "mean")

locations$freq <- locations$cnt * locations$pop
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/S_EXP_CYC_cyclones.shp", layer_options = "ENCODING=UTF-8", append = FALSE)

# Other dataset
# https://risk.preventionweb.net/download/Cyclonic%20wind_RT100years_g152.zip
