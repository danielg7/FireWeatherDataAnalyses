
#This lesson will teach time series plotting and
# spatial mapping for air quality monitoring information
# lesson derived from PWFSLSmoke documentation and
# https://cran.r-project.org/web/packages/PWFSLSmoke/vignettes/Maps_and_Timeseries_Plots.html
install.packages("PWFSLSmoke")
install.packages('MazamaSpatialUtils')
library("PWFSLSmoke")
library('MazamaSpatialUtils')

#first example: the Camp Fire
camp_fire <-
  monitor_loadAnnual(2018) %>%
  monitor_subset(stateCodes = 'CA') %>%
  monitor_subset(tlim = c(20181108,20181123))

monitor_leaflet(camp_fire)

Sacramento <-
  camp_fire %>%
  monitor_subset(monitorIDs = '060670010_01')

monitor_timeseriesPlot(
  Sacramento,
  style='aqidots',
  pch=16,
  xlab="2018"
)
addAQIStackedBar()
addAQILines()
addAQILegend(cex=0.4)
title("Sacramento Smoke")

Sacramento_area <-
  camp_fire %>%
  monitor_subsetByDistance(
    longitude = Sacramento$meta$longitude,
    latitude = Sacramento$meta$latitude,
    radius = 50
  )
monitor_leaflet(Sacramento_area)


# Example 2: Northwest Megafires in 2015
PacNW <- Northwest_Megafires

# can you do this?
as.data.frame(Northwest_Megafires)

#okay, no. But how about this?
Sacramento$meta
df <-Sacramento$meta
head(df)

df2 <- meta$longitude
df2

# moving on

PacNW_24 <- monitor_rollingMean(PacNW, width=24)
monitor_map(PacNW_24, slice=max)
addAQILegend(title="Max AQI", cex=0.4)

# Let's create an interactive "leaflet"
monitor_leaflet(PacNW_24, slice=max)
NezPerceIDs <- c("160571012_01","160690012_01","160690013_01",
                 "160690014_01","160490003_01","160491012_01")
NezPerce <- monitor_subset(PacNW, monitorIDs=NezPerceIDs)
monitor_timeseriesPlot(NezPerce, style='gnats', xlab = "Month")
addAQILines()
addAQILegend(cex=0.4)
#####
### Now just look at the month of August
PacNW <- monitor_subset(PacNW,
                        tlim=c(20150801,20150831),
                        timezone="America/Los_Angeles")
PacNW_24 <- monitor_subset(PacNW_24,
                           tlim=c(20150801,20150831),
                           timezone="America/Los_Angeles")
NezPerce <- monitor_subset(NezPerce,
                           tlim=c(20150801,20150831),
                           timezone="America/Los_Angeles")
layout(matrix(seq(6)))
par(mar=c(1,1,1,1))
for (monitorID in NezPerceIDs) {
  siteName <- NezPerce$meta[monitorID,'siteName']
  monitor_dailyBarplot(NezPerce, monitorID=monitorID, main=siteName, axes=FALSE)
}
# this will set our plot window back to normal
par(mar=c(5,4,4,2)+.1)
layout(1)

# Supposed we know where fires are on the map
# and want to plot them alongside air quality
#Let's create a variable that shows us the mean air quality
# for sites that nearly continuously monitor AQI
PacNW_dailyAvg <- monitor_dailyStatistic(PacNW,
                                         FUN=mean, minHours=20)
# add in fire lats and longs
fireLons <- c(-118.461, -117.679, -120.039, -119.002, -119.662)
fireLats <- c(48.756, 46.11, 47.814, 48.338, 48.519)
monitor_staticmap(PacNW_dailyAvg,
                  centerLon = -118, centerLat = 47,
                  maptype = "terrain", zoom = 6,
                  slice = max)
addIcon('redFlame', fireLons, fireLats,
        expansion = .004)
addAQILegend(cex = 0.7)
title("August, 2015", line = -1.5, cex.main = 1.5)


#exercise
# (1) create a leaflet for Washington state air quality
# from March to September, 2017


#(2) Create a timeseries plot of Seattle Air Quality


# (3) create a zone map of 30km around Seattle for this period
