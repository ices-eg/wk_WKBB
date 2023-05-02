
parentgridlevel = 0.5
finalgrid_level = 0.25

csquare_grid =  CSquare( csquare_centroid$X,csquare_centroid$Y,parentgridlevel)

## piece of code to hack for the special case of 0.25degree
add_quadrant <- function(lon, lat, parent_grid, kid_grid){
  lon_id <- 1+trunc((lon %% parent_grid )/kid_grid)
  lat_id <- parent_grid/kid_grid - trunc((lat %% parent_grid )/kid_grid)
  quadrant_id <- function(x,y,parent_grid,kid_grid){
    val = paste0("_", (y-1) * parent_grid/kid_grid + x)
    return(val)
  }
  out <- sapply(1:length(lon), function(x) quadrant_id(lon_id[x],lat_id[x],parentgridlevel,finalgrid_level))
  return(out)
}

test <- add_quadrant(lon=csquare_centroid$X, lat=csquare_centroid$Y, parent_grid = 0.5, kid_grid=0.25)

csquare_grid_new <- sapply(1:length(csquare_grid), function(x) paste0(csquare_grid[x], test[x]))

head(data.frame(lon=csquare_centroid$X, lat=csquare_centroid$Y, ID=csquare_grid, ID_new=csquare_grid_new))
