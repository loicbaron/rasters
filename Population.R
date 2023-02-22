library(raster)
library(sf)

locations <- readRDS("data/objects/locations")
# data source: https://data.humdata.org
population <- raster("data/Population/ita_general_2020.tif")

pop_extent <- crop(population, extent(locations)) ### crop to the extent
plot(pop_extent)
pop_roi <- mask(x = pop_extent, mask = locations) ### delimitation to the shape geometry
plot(pop_roi)
rf <- writeRaster(pop_roi, filename="data/Population/pop_roi.tif", format="GTiff", overwrite=TRUE)
