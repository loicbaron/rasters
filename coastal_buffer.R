install.packages("remotes")
remotes::install_github("statnmap/cartomisc")

library(cartomisc)
library(dplyr)
library(ggplot2)
library(sf)

# https://statnmap.com/2020-07-31-buffer-area-for-nearest-neighbour/
# https://github.com/statnmap/cartomisc

# https://data.apps.fao.org/catalog/organization/fao-region-mapping
admin_shp <- st_read("data/ADMIN/admin.shp") %>% st_make_valid()
# geo_red_river <- dplyr::filter(
#   admin_shp, GEOLEVEL2 > 704001000 & GEOLEVEL2 < 704039000
# )
# geo_mekong <- dplyr::filter(
#   admin_shp, GEOLEVEL2 > 704082000 & GEOLEVEL2 < 704097000
# )

# locations <- rbind(geo_red_river, geo_mekong)
# saveRDS(locations, "data/objects/locations")

admin_shp <- read_sf("data/ADMIN/admin.shp")
st_is_longlat(admin_shp)
admin_shp <- st_transform(admin_shp, 3857)
st_is_longlat(admin_shp)
admin_shp <- st_make_valid(admin_shp)
admin_buf <- regional_seas(admin_shp, "GEOLEVEL2")
print(admin_buf, n = 300)
admin_buf$geometry[101]
res <- st_cast(admin_buf, "MULTIPOLYGON")
res$geometry[101]
print(res, n = 300)
st_write(res, "output/admin_buffer.shp", layer_options = "ENCODING=UTF-8", append = FALSE)

# # Define where to save the dataset
# extraWD <- tempdir()
# # Get some data available to anyone
# if (!file.exists(file.path(extraWD, "departement.zip"))) {
#   githubURL <- "https://github.com/statnmap/blog_tips/raw/master/2018-07-14-introduction-to-mapping-with-sf-and-co/data/departement.zip"
#   download.file(githubURL, file.path(extraWD, "departement.zip"))
#   unzip(file.path(extraWD, "departement.zip"), exdir = extraWD)
# }

# departements_l93 <- read_sf(dsn = extraWD, layer = "DEPARTEMENT")

# # Reduce dataset
# bretagne_l93 <- departements_l93 %>%
#   dplyr::filter(NOM_REG == "BRETAGNE")

# bretagne_regional_2km_l93 <- regional_seas(
#   x = bretagne_l93,
#   group = "NOM_DEPT",
#   dist = units::set_units(30, km), # buffer distance
#   density = units::set_units(0.5, 1 / km) # density of points (the higher, the more precise the region attribution)
# )

# ggplot() +
#   geom_sf(
#     data = bretagne_regional_2km_l93,
#     aes(colour = NOM_DEPT, fill = NOM_DEPT),
#     alpha = 0.25
#   ) +
#   geom_sf(
#     data = bretagne_l93,
#     aes(fill = NOM_DEPT),
#     colour = "grey20",
#     alpha = 0.5
#   ) +
#   scale_fill_viridis_d() +
#   scale_color_viridis_d() +
#   theme_bw()
