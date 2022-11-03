install.packages("remotes")
remotes::install_github("statnmap/cartomisc")
library(cartomisc)
library(dplyr)
library(sf)

# https://data.apps.fao.org/catalog/organization/fao-region-mapping
admin_shp <- st_read("data/ADMIN/admin.shp") %>% st_make_valid()

st_is_longlat(admin_shp)
admin_shp <- st_transform(admin_shp, 3857)
st_is_longlat(admin_shp)

# https://statnmap.com/2020-07-31-buffer-area-for-nearest-neighbour/
# https://github.com/statnmap/cartomisc
admin_buffer <- regional_seas(
  admin_shp,
  "GEOLEVEL2",
  dist = units::set_units(5, km),
  density = units::set_units(0.1, 1 / km)
) %>% st_cast("MULTIPOLYGON")

st_write(
  admin_buffer,
  "output/admin_buffer.shp",
  layer_options = "ENCODING=UTF-8",
  append = FALSE
)
# admin_buffer <- st_read("output/admin_buffer.shp")
admin_with_buffer <- rbind(admin_shp[c("GEOLEVEL2", "geometry")], admin_buffer) %>%
  group_by(GEOLEVEL2) %>%
  summarise()

admin_with_buffer <- admin_with_buffer %>%
  left_join(st_drop_geometry(admin_shp), by = "GEOLEVEL2") %>%
  st_as_sf()

st_write(
  admin_with_buffer,
  "output/admin_with_buffer.shp",
  layer_options = "ENCODING=UTF-8",
  append = FALSE
)
