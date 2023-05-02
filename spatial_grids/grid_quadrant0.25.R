
csquare_grid =  CSquare( csquare_centroid$X, csquare_centroid$Y,  0.5 )

## piece of code to hack for the special case of 0.25degree
add_quadrant <- function(lon,lat){
  val1 <- trunc((lon %% 0.25 ) *2 /0.25)
  val2 <- trunc((lat %% 0.25 ) *2 /0.25)
  quadrant_id <- function(x,y){
    val = ifelse((x ==0 & y==0), "_1",
                 ifelse((x ==1 & y==0), "_2",
                        ifelse((x ==0 & y==1), "_3",
                               "_4")))
    return(val)
  }
  out <- sapply(1:length(lon), function(x) quadrant_id(val1[x],val2[x]))
  return(out)
}

test <- add_quadrant(lon=csquare_centroid$X, lat=csquare_centroid$Y)

csquare_grid_new <- sapply(1:length(csquare_grid), function(x) paste0(csquare_grid[x], test[x]))
