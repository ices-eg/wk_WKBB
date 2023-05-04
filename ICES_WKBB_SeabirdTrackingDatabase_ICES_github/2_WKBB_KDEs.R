## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Mapping the global distribution of seabird populations
## R script to run kernel analysis (per species) 
## Ana Carneiro May 2018 + Beth Clark Mar 2020-May2022
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rm(list=ls()) 
getwd()

#dir.create("2_KDEs/")
#dir.create("2_KDEs/plots/")

lu=function (x=x) length(unique(x))
library(rgeos)
library(rgdal)
library(sp)
library(geosphere)
library(adehabitatHR)
library(raster)
library(tidyverse)
library(adehabitatHR)

#Read in land file for visualisation:
#Natural Earth land 1:10m polygons version 5.1.1 
#downloaded from www.naturalearthdata.com/
land <- rgdal::readOGR(dsn = "input_data/baselayer", layer = "ne_10m_land")

proj_wgs84 <- CRS(proj4string(land))

neafc <- rgdal::readOGR(dsn = "input_data/NEAFC", layer = "NEAFC_areas")
neafc_wgs84 <- sp::spTransform(neafc, CRS = proj_wgs84)

plot(neafc)

#remove banana and barents
plot(neafc[1,],col = "blue",add = T)
plot(neafc[2,],col = "blue",add = T)
plot(neafc[4,],col = "blue",add = T)

plot(neafc[c(3,5:18),],col = "red",add=T)

neafc_wgs84 <- neafc_wgs84[c(3,5:18),]
neafc_bbox <- neafc_wgs84@bbox

#create null grid
so.grid <- expand.grid(LON = seq(neafc_bbox[1], neafc_bbox[3], by=1), 
                       LAT = seq(neafc_bbox[2], neafc_bbox[4], by=1))

sp::coordinates(so.grid) <- ~LON+LAT
sp::proj4string(so.grid) <- proj4string(land)

mean_loc <- c((neafc_bbox[1]+neafc_bbox[3])/2,
              (neafc_bbox[2]+neafc_bbox[4])/2)
DgProj <- sp::CRS(paste0("+proj=laea +lon_0=",mean_loc[1],
                         " +lat_0=",mean_loc[2])) 

so.grid.proj <- sp::spTransform(so.grid, CRS=DgProj)
coords <- so.grid.proj@coords

c <- min(coords[,1])-1000000   ## to check my min lon
d <- max(coords[,1])+1000000   ## to check my max lon

e <- min(coords[,2])-1000000   ## to check my min lat
f <- max(coords[,2])+1000000   ## to check my max lat

a <- seq(c, d, by=5000)
b <- seq(e, f, by=5000)
null.grid <- expand.grid(x=a,y=b)
sp::coordinates(null.grid) <- ~x+y
sp::gridded(null.grid) <- TRUE
class(null.grid)


files <- list.files("1_species_tracks_clean");files

dataset_number <- 1
for(dataset_number in 3:length(files)){ #length(files)
  tracks_wgs <- read.csv(paste0("1_species_tracks_clean/",
                                files[dataset_number]))
  head(tracks_wgs)
  print(files[dataset_number])
  
  tracks_wgs$month <- as.factor(as.character
                                (substr(tracks_wgs$dtime,6,7)))
  
  sp::coordinates(tracks_wgs) <- ~longitude+latitude
  sp::proj4string(tracks_wgs) <- sp::proj4string(land)
  tracks <- sp::spTransform(tracks_wgs, CRS=DgProj)
  
  months <- sort(unique(tracks_wgs$month))
  print(summary(tracks_wgs$month))
  
  for (month_number in 1:length(months)){ #1:length(months)
    
    tracks_month <- tracks_wgs[tracks_wgs$month == months[month_number],]
    
    if(nrow(tracks_month) > 4){
      
      #plot(tracks)
      #plot(tracks_month, col = "red", add = T)
      #plot(neafc_wgs84,add=T)
      
      tracks_month$month <- factor(tracks_month@data$month)
      KDE_ref <- paste0(str_remove(files[dataset_number],".csv"), "_", 
                        months[month_number])
      
      tracks_proj <- spTransform(tracks_month, CRS=DgProj)
      
      kudl <- adehabitatHR::kernelUD(tracks_proj[,"month"], 
                                     grid = null.grid, h = 200000)  ## smoothing factor equals 200 km for GLS data
      #image(kudl)
      vud <- adehabitatHR::getvolumeUD(kudl)
      ## store the volume under the UD (as computed by getvolumeUD)
      ## of the first animal in fud
      fud <- vud[[1]]
      ## store the value of the volume under UD in a vector hr95
      hr95 <- as.data.frame(fud)[,1]
      ## if hr95 is <= 95 then the pixel belongs to the home range
      ## (takes the value 1, 0 otherwise)
      hr95 <- as.numeric(hr95 <= 95)
      ## Converts into a data frame
      hr95 <- data.frame(hr95)
      ## Converts to a SpatialPixelsDataFrame
      sp::coordinates(hr95) <- sp::coordinates(fud)
      sp::gridded(hr95) <- TRUE
      
      ## display the results
      kde_spixdf <- adehabitatHR::estUDm2spixdf(kudl)
      kern95 <- kde_spixdf
      
      stk_100 <- raster::stack(kern95)
      stk_95 <- raster::stack(hr95)
      
      sum_all_100 <- stk_100[[1]]
      sum_all_95 <- stk_95[[1]]
      
      sum_all_raw <- sum_all_100*sum_all_95
      
      rast <- sum_all_raw/sum(raster::getValues(sum_all_raw))
      rast[rast == 0] <- NA
      #plot(rast)
      
      KDERasName_sum <- paste0("2_KDEs/", KDE_ref, ".tif")
      
      #PLOT & SAVE ####
      rast_wgs84 <- raster::projectRaster(rast,crs=proj_wgs84, over = F)
      
      raster::writeRaster(rast_wgs84, filename = KDERasName_sum, 
                          format = "GTiff", overwrite = TRUE)
      
      ## Plot
      png(filename = paste0("2_KDEs/plots/", KDE_ref, ".png"))
      plot(rast_wgs84, main = KDE_ref)
      plot(neafc_wgs84, add=T)
      dev.off()
    }
  }
} 

