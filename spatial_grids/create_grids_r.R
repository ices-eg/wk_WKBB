### intro



### Create C-Square grid
 
library(sf)
library(ggplot2)

source(CSquares.R)



lon = c(2,3)
lat = c(55,56)
coord_bbox = data.frame(lon, lat)
bbox_aoi =  coord_bbox %>% st_as_sf(coords = c("lon","lat"), crs = 4326) %>%
  st_bbox() %>% st_as_sfc() %>% st_sf( id  = 1, label = 'bbox' ) %>% st_set_crs(4326)


cell.s.w = 0.05
cell.s.h = 0.05
#bbox_aoi = pl_sfc
grid_0_05  = st_make_grid( bbox_aoi,  cellsize = cell.s.w, square = TRUE, offset = c(-5,45)  ) #%>% as(Class = "Spatial")
plot( grid_0_05)

ggplot(data= grid_0_05) + geom_sf() + 
  coord_sf(xlim = c(5, 10), ylim = c(50, 55), expand = FALSE)


## Identify C-Square geocode 

csquare_centroid  = st_centroid ( grid_0_05) %>% st_coordinates() %>%as.data.frame()

csquare_grid =  CSquare ( csquare_centroid$X, csquare_centroid$Y,  0.05 )
 
csquares_0_05 = st_bind_cols( grid_0_05, csquare_grid)


 


