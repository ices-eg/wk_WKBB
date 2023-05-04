rm(list=ls()) 

#dir.create("1_location_maps/")
#dir.create("1_species_tracks_clean/")

library(tidyverse)
library(sf)
#library(rnaturalearth)
#library(rnaturalearthdata)

files <- list.files("ICES_STDB");files

#plots
#Read in land file for visualisation:
#Natural Earth land 1:10m polygons version 5.1.1 
#downloaded from www.naturalearthdata.com/
land <- read_sf(dsn = "input_data/baselayer", layer = "ne_10m_land")

#From sharepoint
neafc <- read_sf(dsn = "input_data/NEAFC", layer = "NEAFC_areas")
land_proj <- st_transform(land, crs = st_crs(neafc))

#set up to plot data in NEAFC region + 200km
border <- 200000
dat_extent <- st_bbox(neafc) 

equinoxes <- read.csv("input_data/equinoxes.csv")
head(equinoxes)
equinoxes$mar <- as.POSIXct(equinoxes$mar, format = "%d/%m/%Y %H:%M:%S", tz = "GMT")
equinoxes$sep <- as.POSIXct(equinoxes$sep, format = "%d/%m/%Y %H:%M:%S", tz = "GMT")

#mark the start and end of the periods to filter out (it is asymmetrical)
equinoxes$mar_start <- equinoxes$mar - (21*24*60*60) #-21 days
equinoxes$mar_end <- equinoxes$mar + (7*24*60*60)    #+7 days
equinoxes$sep_start <- equinoxes$sep - (7*24*60*60)
equinoxes$sep_end <- equinoxes$sep + (21*24*60*60)

dat <- read.csv("input_data/05_Dataset_summary_with_owners_2023-02-09.csv")
head(dat)

dataset_list <- subset(dat,dataset_id %in% c(506, 507, 511, 628, 684, 
                                             974, 975, 980, 981, 982, 983, 
                                             1028, 1029, 1032, 1033, 1056, 
                                             1060, 1061, 1083, 1093, 
                                             1109, 1111, 1112, 1113, 1114,  
                                             1481, 1482, 
                                             1690, 1691, 1696, 1697, 1698,  
                                             1710, 1711, 1712, 1714, 1715, 
                                             1716, 1717, 1738))

species <- unique(dataset_list$scientific);species

species <- species[species != "Fulmarus glacialis"]
species <- species[species != "Uria lomvia"]

i <- 1
#3 failed
for(i in 4:length(species)){
  sp_df <- subset(dataset_list, scientific == species[i])
  
  dataset_ids <- as.numeric(str_split_fixed(files,"_",n=3)[,2])
  
  sum(match(sp_df$dataset_id,dataset_ids),na.rm=T) > 0
  
  if(sum(match(sp_df$dataset_id,dataset_ids),na.rm=T) > 0){
    sp_df$filenames <- files[match(sp_df$dataset_id,dataset_ids)]
    
    sp_df <- subset(sp_df, !(is.na(filenames)))
    
    print(sp_df)
    
    Data<-do.call("rbind",lapply(as.character(paste0("ICES_STDB/", 
                                                     sp_df$filenames)),
                                 read.csv,stringsAsFactors = F)) 
    Data$time_gmt <- ifelse(is.na(Data$time_gmt),"00:00:00",Data$time_gmt)
    Data$dtime <- paste(Data$date_gmt, Data$time_gmt)
    Data$dtime <- as.POSIXct(Data$dtime, format = "%Y-%m-%d %H:%M:%S", tz = "GMT")
    
    Data <- Data %>% drop_na(latitude, longitude, dtime)
    
    Data$year <- substr(Data$dtime,1,4)
    
    devices <- unique(Data$device)
    devices
    
    
    if("GLS" %in% devices){  
      
      Data_GLS <- subset(Data, device == "GLS")
      Data_not_GLS  <- subset(Data, device != "GLS")
      
      years <- unique(Data_GLS$year)
      
      k <- 1
      for(k in 1:length(years)){
        
        yr <- subset(Data_GLS, Data_GLS$year == years[k])
        
        df_mar <- subset(yr, dtime < equinoxes$mar_start[equinoxes$year == years[k]] |
                           dtime > equinoxes$mar_end[equinoxes$year == years[k]] ) 
        df_sep <- subset(df_mar, dtime < equinoxes$sep_start[equinoxes$year == years[k]] |
                           dtime > equinoxes$sep_end[equinoxes$year == years[k]] ) 
        if(k == 1){
          df_allyrs <- df_sep
        } else {
          df_allyrs <- rbind(df_allyrs,df_sep)
        }
        
      }
      
      filtered <- rbind(df_allyrs,Data_not_GLS)
      
    } else {
      filtered <- Data
    }
    
    #save clean data
    write.csv(filtered,paste0("1_species_tracks_clean/STDB_",sp_df$common[1],".csv"),
              row.names = F)
    
    sp_dat <- filtered %>%
      st_as_sf(coords = c("longitude","latitude"),
               crs = 4326) 
    
    sp_dat_proj <- st_transform(sp_dat, crs = st_crs(neafc))
    
    col_dat <- filtered %>%
      st_as_sf(coords = c("lon_colony","lat_colony"),
               crs = 4326) 
    
    col_dat_proj <- st_transform(col_dat, crs = st_crs(neafc))
    
    tracks <- sp_dat_proj %>%
      arrange(bird_id,track_id,dtime) %>% 
      group_by(track_id) %>%
      summarise(do_union = FALSE) %>%
      st_cast("LINESTRING")
    
    sp_map <- ggplot()+
      geom_sf(data = tracks, alpha = 0.2, color = "orange")+
      geom_sf(data = sp_dat_proj,aes(color = "orange"),
              alpha = 0.5, size = 2, shape = 20)+
      #scale_color_brewer(palette = "Set1", aesthetics = "color",
      #                   type="qual")+
      #geom_sf(data = eez_proj,
      #        color = "blue", size = 0.5, alpha = 0)+
      geom_sf(data = neafc,
              color = "blue", size = 0.5, alpha = 0)+
      geom_sf(data = land_proj, fill = "darkgrey")+
      geom_sf(data = col_dat_proj, 
              color = "red",shape = 18, size = 6)+
      coord_sf(xlim = c(dat_extent$xmin-border,
                        dat_extent$xmax+border),
               ylim = c(dat_extent$ymin-border,
                        dat_extent$ymax+border))+
      ggtitle(paste0(sp_df$common[1],", ",sp_df$scientific[1])) +
      theme(panel.background = element_rect(fill = 'lightblue2'),
            legend.position = "position.none");sp_map
    
    ggsave(filename = paste0("1_location_maps/",sp_df$scientific[1],".png"),
           plot = sp_map, dpi = 300)  
  }
  
  metadata <- sp_df %>% select(dataset_id,common,scientific,device,country,site_name,colony_name,lat_colony,lon_colony,primary_owner,co_owners)
  
  if(i == 1){
    metadata_all <- metadata
  } else {
    metadata_all <- rbind(metadata_all,metadata)
  }
} 

write.csv(metadata_all,"1_STBD_metadata.csv")

