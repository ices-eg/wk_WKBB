### Create C-Square grid
 
library(sf)
library(dplyr)
library(ggplot2)


st_re



lon = c(-7,-11)
lat = c(55,56)
coord_bbox = data.frame(lon, lat)
bbox_aoi =  coord_bbox %>% st_as_sf(coords = c("lon","lat"), crs = 4326) %>%
  st_bbox() %>% st_as_sfc() %>% st_sf( id  = 1, label = 'bbox' ) %>% st_set_crs(4326)


cell.s.w = 0.25
cell.s.h = 0.25
#bbox_aoi = pl_sfc
grid_0_05  = st_make_grid( bbox_aoi,  cellsize = cell.s.w, square = TRUE, offset = c(-5,45)  ) #%>% as(Class = "Spatial")
grid_0_25  = st_make_grid( bbox_aoi,  cellsize = cell.s.w, square = TRUE, offset = c(-5,45)  ) #%>% as(Class = "Spatial")

plot( grid_0_5)



ggplot(data= grid_0_05) + geom_sf() + 
  coord_sf(xlim = c(5, 10), ylim = c(50, 55), expand = FALSE)


## Identify C-Square geocode 

csquare_centroid  = st_centroid ( grid_0_05) %>% st_coordinates() %>%as.data.frame()
csquare_0_25_centroid  = st_centroid ( grid_0_25) %>% st_coordinates() %>%as.data.frame()


csquare_grid =  CSquare ( csquare_centroid$X, csquare_centroid$Y,  0.05 )

csquare_0_25_grid =  CSquare ( csquare_0_25_centroid$X, csquare_0_25_centroid$Y,  0.5 )


csquares_0_25 = st_bind_cols( grid_0_25, csquare_0_25_grid)

csquares_0_25_b = st_bind_cols( csquares_0_25, csquares_0_25 %>% st_centroid()%>%
                  dplyr::mutate(lon = sf::st_coordinates(.)[,1],
                                lat = sf::st_coordinates(.)[,2])%>%
                  select ( lon, lat ) ) -> test



st_bind_cols(csquares_0_25,  csquares_0_25%>%st_coordinates()%>%as_tibble()%>% select(X, Y) ) 
 
csquares_0_05 = st_bind_cols( grid_0_05, csquare_grid)



csquare_grid =  CSquare ( csquare_centroid$X, csquare_centroid$Y,  0.5 )

csquares_0_25_grid =  csquares_0_25_b%>%filter ( csquare_0_25_grid  == '1400:350:1' ) %>% 
                      as.data.frame()%>%
                      #group_by(csquare_0_25_grid ) %>% 
                      ungroup() %>%
                      dplyr::arrange(  csquare_0_25_grid, lon, lat   )    %>%
                      mutate ( rn = row_number() ) %>%
                      mutate ( c_square_0_25_tag = paste ( csquare_0_25_grid, rn,sep = "_"))



csquares_0_25_grid %>%st_write(., 'csq_025_grid.geojson', driver="GeoJSON",  append=FALSE)
 
