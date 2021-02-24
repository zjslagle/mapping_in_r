####  Mapping in R    #####################
#
#     Part 1 - loading data and Coordinate rreference systems   
#
#     Feb 26, 2021 - Ohio Chapter AFS - Zak Slagle (Ohio Division of Wildlife, Sandusky)
#
#     Most of this is based on the online book Geocomputation with R (Lovelace, Nowosad, and Muenchow 2017)
#       available: https://geocompr.robinlovelace.net/
#
#     See the readme for other credits: https://github.com/zjslagle/mapping_in_r
#
#     This code demonstrates map building using the R packages sf() and ggplot(), which allow users to import and plot 
#     shapefiles and user waypoints, project map features into different projections, and perform spatial operations.
#     Users can also create publication-quality maps that include scale bars and inset maps, make animated maps,
#     and create leaflet-style interactive maps.
#
#
#     We will use data, and recreate a figure, from a Smallmouth Bass tournament release project in Lake Erie:
#       Slagle, Z. J., M. D. Faust, K. R. Keretz, and M. R. DuFour. 2020. Post-tournament dispersal of smallmouth bass 
#       in western Lake Erie. Journal of Great Lakes Research 46(1):198–206.
#     


###  Packages              #######################################################
# RUN THIS CODE BEFORE THE WORKSHOP, IF POSSIBLE:
#install packages if necessary
if (!require('sf')) install.packages('sf');  # Simple Features package
if (!require('grid')) install.packages('grid');  # required for printing inset map on active graphics device
if (!require('mapview')) install.packages('mapview'); # quick interactive maps
if (!require('ggsn')) install.packages('ggsn'); # north arrows and scale bars in GGplot maps
if (!require('gganimate')) install.packages('gganimate'); # animations!
if (!require('tidyverse')) install.packages('tidyverse'); # contains ggplot and many other useful packages
# END

# Load packages (need to do this to load package if it was just installed)
library('sf')
library('grid')
library("mapview")
library("ggsn")
library('readxl') # part of the tidyverse
library('tidyverse')



###   Read in Shapefiles     #########################################

# read in shapefiles. All "ne_..." files are from https://www.naturalearthdata.com/ which has loads of free basemaps
us_and_can = st_read("shapefiles/ne_10m_admin_1_states_provinces.shp") 
cities = st_read("shapefiles/ne_10m_urban_areas.shp") #city polygons
city_names <- st_read("shapefiles/ne_10m_populated_places_simple.shp")
great_lakes <- st_read("shapefiles/ne_10m_lakes.shp")
lake_erie <- st_read("shapefiles/Lake_Erie_Shoreline.shp")

# filter out only data we need
us_and_can <- us_and_can %>% filter(gu_a3 == "CAN"|gu_a3 == "USA") #filter out US and CAN only
great_lakes <- great_lakes %>% filter(name_alt == "Great Lakes") # Great Lakes only (otherwise, this is all lakes)
city_names <- city_names %>% filter(adm1name == "Ohio") #Ohio city names only

  # quick sidenote about pipes (%>%): line 50 is equivalent to:
  us_and_can <- filter(us_and_can, gu_a3 == "CAN"|gu_a3 == "USA")


### What is a Simple Feature?    #########################################
#Let's take a look at what a "simple feature" is:
city_names
class(city_names)
str(city_names) # combo of a dataframe and the geometry belonging to each observation
plot(city_names)
st_geometry(city_names)

plot(great_lakes)
st_geometry(great_lakes)

# easiest way to error check locations - use the package/command "mapview"
mapview(city_names)
  #if this doesn't work, you may need to install the "gdtools" package


###   Read in other data    ############################

#import locations for bass captured in tournament, also summarize by site
capture_sites <- read_excel("data/capture_locations.xlsx", na = c(".","NA")) %>%
  group_by(Location_name, Longitude, Latitude) %>%
  summarize(n_bass_caught = n())

capture_sites

#transform data frame into a simple feature
capture_sites <- capture_sites %>% st_as_sf(coords = c("Longitude", "Latitude"))

capture_sites
# note that we skipped an important step here - see below!

#create a new point by hand for the Shelby Street Boat Ramp, the release site for the bass
release_site = st_as_sf(data.frame(Name = "Shelby St Boat Ramp", 
                                   "Latitude" = 41.454647, 
                                   "Longitude" = -82.723714),
                        coords = c("Longitude", "Latitude"), 
                        crs = 4326)


### The Importance of Coordinate Reference System (CRS)   ###########################

# try to plot sites
mapview(capture_sites)
#what CRS are we using?
st_crs(capture_sites)

st_crs(4326) # AKA WGS 84; this is the most common geographic CRS in the world.
# this is a Geographic Reference System, so it's a globe

capture_sites <-  st_set_crs(capture_sites, 4326) # Set the proper CRS

mapview(capture_sites)

# What if we mess this up?
st_crs(32617) # AKA UTM zone 17N
# This is a Projected Reference System, so it's flat.

# What do the two look like, side by side?
mapview(capture_sites)+mapview(capture_sites %>% st_set_crs(32617))
# note the error we get - this isn't the correct way to do this!

# To transform between reference systems:
capture_sites %>% 
  st_transform(32617) %>%
  mapview
#this becomes important in two cases:
#     2) if we want to transform our simple feature - for example, draw range circles
#     around a point, get a centroid, make a buffer, or subset a polygon, etc. - because projected
#     ref systems use regular distance units (e.g., meters) while Geographic reference systems measure
#     using degrees.

# transform back to WGS 84
capture_sites <- st_transform(capture_sites, 4326)

# I highly recommend reading the section on Coordinate systems in Geocomputation with R.
#     (https://geocompr.robinlovelace.net/spatial-class.html#crs-intro)
#    This is a very important concept for all mapping applications (not just R)
