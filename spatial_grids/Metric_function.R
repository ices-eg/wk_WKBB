################################################################
## A little function to take the input data on seabird density
## or fishing effort and re-scale between 0 and 1 based on the
## empirical / modeled cumulative distribution
## Empirical could be OK if not too many extremes
## Fitting a specific distribution (e.g. lognormal) might be better
## if several extremes
#################################################################

### Applying the cumulative distribution (either empirical or by fitting a model)
### Currently, there are: weibull, gamma, lognormal and student-t distributions

library(fitdistrplus)

test_dist <- function(data, fitting=TRUE){
  if (fitting == TRUE){
    fitW <- fitdist(data, "weibull")
    fitg <- fitdist(data, "gamma")
    fitln <- fitdist(data, "lnorm")
    fitst <- fitdist(data, "t", start=list(ncp=mean(data),df=3))
    summary(fitW)
    summary(fitg)
    summary(fitln)
    summary(fitst)
    cdfcomp(list(fitW, fitg, fitln,fitst), legendtext=c("Weibull", "gamma", "lognormal", "student-t"))
    denscomp(list(fitW, fitg, fitln,fitst), legendtext=c("Weibull", "gamma", "lognormal", "student-t"))
    return(list(Weibull=coef(fitW),
                gamma= coef(fitg),
                lognormal= coef(fitln),
                student= coef(fitst)))
  }

  if (fitting == FALSE){
    P = ecdf(data)
    plot(seq(min(data), max(data), by=0.01), P(seq(min(data), max(data), by=0.01)))
  }
}

### Example data
  data(groundbeef)
  serving <- groundbeef$serving

### Applying the function to the data
### the important thing here is to aggregate all data across time and month
### this is so that the metric is bounded between 0 and 1 (and becomes comparable across time and area)

  out <- test_dist(data = serving, fitting =TRUE)

### based on the plot on distribution fitting, choose which one to use
### Here the data could be at each time step and NEAFC area
  plot(seq(1,200,by=1), dlnorm(seq(1,200,by=1), meanlog=out$lognormal[1], sdlog=out$lognormal[2]), type="l")
  metric <- plnorm(data, meanlog=out$lognormal[1], sdlog=out$lognormal[2])
