### Create C-Square grid
 
library(sf)
library(dplyr)
library(ggplot2)


cell_resolution = 0.25

## bounding box area limits definition

lon = c(-7,11)
lat = c(64,77)
coord_bbox = data.frame(lon, lat)
bbox_aoi =  coord_bbox %>% 
            st_as_sf(coords = c("lon","lat"), crs = 4326) %>%
            st_bbox() %>% st_as_sfc() %>% 
            st_sf( id  = 1, label = 'bbox' ) %>%
            st_set_crs(4326)

## create the grid
 
grid  = st_make_grid( bbox_aoi,  cellsize = 0.25, square = TRUE, offset = c(min(lon),min(lat))  ) #%>% as(Class = "Spatial")

## plot the grid 
 
  ggplot(data= grid ) + geom_sf() + 
  coord_sf(xlim = lon, ylim = lat, expand = FALSE)


## Identify C-Square geocode 
   
  
  
#  csquare_grid =  CSquare ( csquare_centroid$X, csquare_centroid$Y,  0.05 )
  
 
grid_centroid  = st_centroid ( grid) %>% st_coordinates() %>%as.data.frame()

grid_csquares =  CSquare ( grid_centroid$X, grid_centroid$Y,  0.5 )

grid_0_25_csquare_0_5 = st_bind_cols( grid, csquare_0_5 = grid_csquares )

csquares_0_25_centroids = st_bind_cols( grid_0_25_csquare_0_5,  grid_0_25_csquare_0_5 %>% st_centroid()%>%
                          dplyr::mutate(lon = round( sf::st_coordinates(.)[,1] , 5 ) ,
                                        lat = round( sf::st_coordinates(.)[,2] , 5 ) ) %>%
                          select ( lon, lat ) )  



csquares_0_25_grid =  csquares_0_25_centroids%>% 
                      group_by(csquare_0_5 ) %>% 
                      dplyr::arrange(  csquare_0_5,   -lat  ,  lon    )    %>%
                      mutate ( rn = row_number() ) %>%
                      mutate ( c_square_0_25_tag = paste ( csquare_0_5, rn,sep = "_")) 

csquares_0_25_grid %>%st_write(., 'csq_025_grid_final.geojson', driver="GeoJSON",  append=FALSE)
