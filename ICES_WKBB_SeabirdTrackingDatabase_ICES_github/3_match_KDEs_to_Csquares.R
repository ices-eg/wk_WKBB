## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Mapping the global distribution of seabird populations
## R script to aggregate results into a 5x5 degree grid
## Ana Carneiro and Anne-Sophie Bonnet-Lebrun
## July 2018
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Adapted by Beth Clark Mar 2020 for overlap with 1x1 degree plastics data
#Adapted for matching SEATRACK rasters at ICES WKBB workshop Copenhagen 1-4 May 2023


rm(list=ls()) 
################ LOADING PACKAGES ###################

library(raster)
library(rgdal)
library(cowplot)
library(stringr)
library(RColorBrewer)
library(viridis)
library(sp)
library(sf)
library(tidyverse)
library(terra)

sessionInfo()
#R version 4.1.2 (2021-11-01)
#Platform: x86_64-w64-mingw32/x64 (64-bit)
#Running under: Windows 10 x64 (build 19044)
#
#Matrix products: default
#
#locale:
#  [1] LC_COLLATE=English_United Kingdom.1252  LC_CTYPE=English_United Kingdom.1252    LC_MONETARY=English_United Kingdom.1252
#  [4] LC_NUMERIC=C                            LC_TIME=English_United Kingdom.1252    

#attached base packages:
#  [1] stats     graphics  grDevices utils     datasets  methods   base     

#other attached packages:
#  [1] viridis_0.6.2      viridisLite_0.4.0  RColorBrewer_1.1-2 stringr_1.4.0      cowplot_1.1.1      rgdal_1.4-8        raster_3.1-5      
#  [8] sp_1.3-2          

#loaded via a namespace (and not attached):
#  [1] Rcpp_1.0.8       pillar_1.7.0     compiler_4.1.2   tools_4.1.2      lifecycle_1.0.1  tibble_3.1.6     gtable_0.3.0     lattice_0.20-45 
#  [9] pkgconfig_2.0.3  rlang_1.0.1      cli_3.3.0        DBI_1.1.2        gridExtra_2.3    dplyr_1.0.8      generics_0.1.2   vctrs_0.3.8     
#  [17] grid_4.1.2       tidyselect_1.1.2 glue_1.6.2       R6_2.5.1         fansi_1.0.2      ggplot2_3.3.5    purrr_0.3.4      magrittr_2.0.2  
#  [25] scales_1.1.1     codetools_0.2-18 ellipsis_0.3.2   assertthat_0.2.1 colorspace_2.0-3 utf8_1.2.2       stringi_1.7.6    munsell_0.5.0   
#  [33] crayon_1.5.0    


######### GENERAL DIRECTIONS AND FILES ##############

#Create blank raster
blank_raster <- raster()

#Read in neafc file:
neafc <- read_sf(dsn = "input_data/NEAFC", layer = "NEAFC_areas")
neafc_wgs84 <- st_transform(neafc, crs = 4326)

#remove banana and barents
plot(neafc[1,],col = "blue",add = T)
plot(neafc[2,],col = "blue",add = T)
plot(neafc[4,],col = "blue",add = T)

plot(neafc[c(3,5:18),],col = "red",add=T)

neafc_wgs84 <- neafc_wgs84[c(3,5:18),]
#neafc_bbox <- neafc_wgs84@bbox
## DIRECTION TO YOUR RASTERS 
dir_rasters <- "2_KDEs"

## DIRECTION TO YOUR RESULTS
dir_1by1 <- "3_aggregate_grid"

dir.create(dir_1by1) 
dir.create(paste0(dir_1by1,"/maps/"))

####### CONVERT INTO A 1X1 DEGREE RESOLUTION ########

csquare_neafc = st_read(dsn = '.\\input_data\\csquare_grid_0_25_neafc_areas.geojson')

files <- list.files(dir_rasters, full.names = TRUE,pattern=".*\\.tif$"); files

i <- 2
for (i in 1:length(files)){
  
  raster_bird_month <- raster(files[i])
  
  #plot(raster_bird_month)

  rast_points <- rasterToPoints(raster_bird_month)
  rast_points <- rast_points %>% as.data.frame()
  ras_to_point <- rast_points %>% st_as_sf(coords = c('x','y'), crs = 4326)
  ras_to_point_csq <- ras_to_point %>% st_join(.,csquare_neafc, 
                                             join = st_intersects,left = T)
  names(ras_to_point_csq)[1] <- "bird_prob"
  #ras_to_point_csq %>% mutate(idx = row_number()) %>% 
  #  as.data.frame() %>% distinct(csquare_div,idx ) %>%
  #  group_by(csquare_div) %>% tally()
  
  out <- ras_to_point_csq%>%mutate(idx = row_number()) %>% as.data.frame() %>%
    group_by(csquare, neafc_area, csquare_div) %>%
    summarise(bird_prob = mean(bird_prob, na.rm = T))
  
  head(out)
  
  out_geom <- csquare_neafc %>% left_join(out,by = c('csquare_div') )
  
  bird_month_label <- str_remove(files[i],".tif") %>% str_remove(.,"2_KDEs/")
  
  out$species <- substr(bird_month_label,start = 6, stop = nchar(bird_month_label)-3)
  out$month <- substr(bird_month_label, start = nchar(bird_month_label)-1, 
                                        stop = nchar(bird_month_label))
  
  head(out)
  
  bbox_neafc <- st_bbox(neafc_wgs84$geometry)
  
  map_b <- ggplot(out_geom) + 
    geom_sf(aes(fill = bird_prob), size = 0.001) +
    scale_fill_viridis() +
    theme_bw()+
    xlim(bbox_neafc$xmin[[1]],bbox_neafc$xmax[[1]])+
    ylim(bbox_neafc$ymin[[1]],bbox_neafc$ymax[[1]])+
    labs(title=bird_month_label,fill = "Probability\n of use");map_b
  
  ggsave(filename = paste0("3_aggregate_grid/maps/",
                           bird_month_label,".png"),
         plot = map_b, dpi = 300, width = 5.6, height = 6.4) 
  
  head(out)
  
  out <- as.data.frame(out)

  write.csv(out,paste0("3_aggregate_grid/",bird_month_label,
                        ".csv"),row.names = F)
  
  print(bird_month_label)
}

#Put all csvs in one file
output_files <- list.files("3_aggregate_grid/", full.names = TRUE,pattern=".*\\.csv$"); output_files


Data<-do.call("rbind",lapply(as.character(output_files),
                             read.csv,stringsAsFactors = F)) 

head(Data)

table(Data$species,Data$month)

write.csv(Data,"3_SeabirdTrackingDatabase_distributions.csv")

#SEATRACK
#probabibilty multiplied by colonies size, across entire range
#took the range of the entire species, all colonies
#then modelled each colony separately and overlapped
#a lot of corrections to fill 


