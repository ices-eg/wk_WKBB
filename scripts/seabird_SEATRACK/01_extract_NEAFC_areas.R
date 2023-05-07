
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## WKBB - ICES workshop, Copenhagen, May 1-4 2023
##
## SEABIRD DATA 
##
## Load and format NEAFC-area data (vector data)
##
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

require(dplyr); require(sf)

ices_areas <- read_sf("data/ices_areas/ICES_Areas_20160601_cut_dense_3857.shp")

NEAFC_descr <- readxl::read_xlsx("data/ices_areas/NEAFC_areas_description.xlsx")

ices_areas %>%
 slice(49:66) %>% # extract only areas of interest
 left_join(NEAFC_descr, by = c("Area_Full" = "ICES Code")) %>%
  select(Area_Full, Area_km2, Description) %>%
  rename(AreaCode = Area_Full, Descr = Description) ->
NEAFC_areas

## write as GeoJSON
   # write_sf(NEAFC_areas, "outputs/NEAFC_areas_TEST.geojson")
   # read_sf("outputs/NEAFC_areas_TEST.geojson")
