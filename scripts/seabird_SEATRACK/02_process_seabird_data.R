
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## WKBB - ICES workshop, Copenhagen, May 1-4 2023
##
## SEABIRD DATA 
## Load and process SEATRACK dataset (NEAS)
##
## questions: arnaud.tarroux@nina.no
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## reference for dataset: https://doi.org/10.3354/meps13854


## Prepare workspace ----
##~~~~~~~~~~~~~~~~~~~

  require(terra); require(sf); require(dplyr); require(tidyr); require(ggplot2); require(ggspatial); require(tidyterra)
  
  # List six species covered by SEATRACK dataset (latin names)
    species <- c("Alle_alle", "Fratercula_arctica", "Fulmarus_glacialis", "Rissa_tridactyla", "Uria_aalge", "Uria_lomvia")
  
  # Load and dissolve NEAFC areas
    read_sf("data/ICES_areas/NEAFC_areas.shp") %>%
      st_transform(crs = "EPSG:4326") %>%
      st_union() %>%
      st_cast("POLYGON") %>%
      st_as_sf() ->
    NEAFC_area
    
    NEAFC_area$name <- c("area1", "area3", "area2")
  
  # Define threshold density (bird/km2) for bird presence
    thresh = 0.01
    
  
## Produce data table for ByRA ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  # Extract seabird density data, bind to CSquare grid, compute presence/absence, and export as CSV
    for(spp in species){
  
     # Shortened species name
       spp2 <- tolower(paste0(substr(strsplit(spp, "_")[[1]][1], 1,2), substr(strsplit(spp, "_")[[1]][2], 1, 3)))
       
     # Load seabird distribution data
       rB.s <- terra::rast(paste0("data/seabird/SeabirdDensity_2012-19_", spp, "_stack.tif"))

     # Extract and format seabird data for each NEAFC area
       output <- NULL
      
       for(area in c('area1', 'area2', 'area3')){
  
         # Load CSquare grid
           st_read('data/ICES_areas/csquare_grid_0_25_neafc_areas.geojson') %>%
             dplyr::filter(neafc_area == area) %>%
             dplyr::select(fid, neafc_area, csquare, csquare_div, lon, lat) %>%
             as.data.frame() %>%
             dplyr::select(neafc_area, csquare, csquare_div, lon, lat) ->
           CSquare.grid
   
         # Crop seabird data to NEAFC area of interest
           rB.s %>%
             terra::crop(NEAFC_area[NEAFC_area$name == area,], mask = TRUE) ->
           rB.s.neafc # raster stack, 1 layer/month
           
         # Transfom absolute values into relative densities (N bird/km2)
           rB.s.neafc <- rB.s.neafc/cellSize(rB.s.neafc, unit = 'km')
          
         # Determine presence/absence (binary) for each month and for entire year (in any month)
           terra::extract(rB.s.neafc, CSquare.grid[, c('lon', 'lat')], xy = TRUE) %>%
             dplyr::bind_cols(CSquare.grid) %>%
             dplyr::select(-x, -y) %>%
             dplyr::mutate_at(2:13, list( ~case_when(. > thresh ~ 1, TRUE ~ 0))) %>%
             dplyr::select(Jan:Dec) %>% 
             dplyr::rename_with(~ paste0(.x, "_bin")) ->
           bird.out.tmp
            
           terra::extract(rB.s.neafc, CSquare.grid[, c('lon', 'lat')], xy = TRUE) %>%
             dplyr::bind_cols(CSquare.grid) %>%
             dplyr::bind_cols(bird.out.tmp) %>%
             dplyr::rowwise() %>%
             dplyr::mutate(yearRound_pres = case_when(
                   Jan_bin == 1 | Feb_bin == 1 | Mar_bin == 1 | Apr_bin == 1 | May_bin == 1 | Jun_bin == 1 | Jul_bin == 1 | Aug_bin == 1 | Sep_bin == 1 | Oct_bin == 1 | Nov_bin == 1 | Dec_bin == 1 ~ 1,
                   TRUE ~ 0)) %>%
             as.data.frame() %>%
             dplyr::select(-x, -y, -ID, csquare, csquare_div, lon, lat, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec,
                           Jan_bin, Feb_bin, Mar_bin, Apr_bin, May_bin, Jun_bin, Jul_bin, Aug_bin, Sep_bin, Oct_bin, Nov_bin, Dec_bin, yearRound_pres) %>%
             dplyr::bind_rows(output, .) ->
           output
       }
       write.csv(output, paste0('outputs/', spp2, '_CSquareGrid_densities.csv'),  row.names = FALSE)
       rm(output); gc()
    }
  
  
  
## Produce data table for ToR b) ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  # Extract seabird density data, bind to CSquare grid, compute presence/absence, and export as CSV
    for(spp in species){
  
     # Shortened species name
       spp2 <- tolower(paste0(substr(strsplit(spp, "_")[[1]][1], 1,2), substr(strsplit(spp, "_")[[1]][2], 1, 3)))
       
     # Load seabird distribution data
       rB.s <- terra::rast(paste0("data/seabird/SeabirdDensity_2012-19_", spp, "_stack.tif"))

     # Extract and format seabird data for each NEAFC area
       out.long <- NULL
      
       for(area in c('area1', 'area2', 'area3')){
  
         # Load CSquare grid
           st_read('data/ICES_areas/csquare_grid_0_25_neafc_areas.geojson') %>%
             dplyr::filter(neafc_area == area) %>%
             dplyr::select(fid, neafc_area, csquare, csquare_div, lon, lat) %>%
             as.data.frame() %>%
             dplyr::select(neafc_area, csquare, csquare_div, lon, lat) ->
           CSquare.grid
   
         # Crop seabird data to NEAFC area of interest
           rB.s %>%
             terra::crop(NEAFC_area[NEAFC_area$name == area,], mask = TRUE) ->
           rB.s.neafc # raster stack, 1 layer/month
           
         # Transfom absolute values into relative densities (N bird/km2)
           rB.s.neafc <- rB.s.neafc/cellSize(rB.s.neafc, unit = 'km')
          
         # Extract seabird density data in NEAFC area of interest and pivot to long table
           terra::extract(rB.s.neafc, CSquare.grid[, c('lon', 'lat')], xy = TRUE) %>%
             dplyr::bind_cols(CSquare.grid) %>%
             dplyr::select(-x, -y) %>%
             tidyr::pivot_longer(cols = Jan:Dec,  names_to = "month", values_to = "bird_per_km2") %>%
             dplyr::select(month, lon, lat, csquare, csquare_div, bird_per_km2) %>%
             dplyr::bind_rows(out.long, .)->
           out.long
       
       }
  
       write.csv(out.long, paste0('outputs/', spp2, '_CSquareGrid_densities_long.csv'),  row.names = FALSE)
       rm(out.long); gc()
  
    }  
  
  