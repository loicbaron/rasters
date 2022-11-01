library(dplyr)
library(ggplot2)
library(sf)
library(terra)

# Get the Macro tile from ESA worldcover 2020
# https://worldcover2020.esa.int/downloader
# direct link for Asia:
# https://worldcover2020.esa.int/data/archive/ESA_WorldCover_10m_2020_v100_60deg_macrotile_S30E060.zip
dir <- "data/ESA_Landcover/ESA_WorldCover_10m_2020_v100_60deg_macrotile_S30E060"
raster_files <- list.files(
    normalizePath(dir),
    pattern = "\\.(tif|tiff)$",
    ignore.case = TRUE,
    full.names = TRUE
)

v <- terra::vrt(raster_files,
    filename = "data/ESA_Landcover/VNM.vrt"
)
roi <- st_read("data/ADMIN/admin.shp") %>%
    st_make_valid() %>%
    summarise()

buffer <- st_buffer(
    roi,
    dist = units::set_units(5, km)
) %>% st_cast()

roi_with_buffer <- st_union(roi, buffer)

# my_blue <- "#1e73be"
# ggplot() +
#     geom_sf(data = buffer, fill = "#1e73be", alpha = 0.2, colour = "#1e73be") +
#     geom_sf(data = roi, colour = "#1e73be", fill = NA)

r <- terra::crop(v, roi_with_buffer)
terra::writeRaster(r, filename = "data/ESA_Landcover/VNM.tif")
