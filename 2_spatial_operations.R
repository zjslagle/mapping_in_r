### Part 2 - Spatial operations    ###########################

### Subset geometry based on location  ##################
# define bounding box for our map. It is useful to have both a named vector (to define the actual map) and
#   a simple feature box to subset other simple features
# easy bounding box coords - https://boundingbox.klokantech.com/

#named vector
catch_map_bounds <- c(xmin = -83.17094, 
                      ymin = 41.40593, 
                      xmax = -82.587291, 
                      ymax = 41.734189)

# simple feature - bounding box
catch_map_box <- st_bbox(catch_map_bounds) %>% 
  st_as_sfc() %>% #as a simple feature
  st_set_crs(4326) 

mapview(catch_map_box)

cities

#get intersection (i.e., overlap) between geometries: functionally, this subsets "cities" that fall within
#       the "catch_map_box" bounding box
cities <- st_intersection(cities, catch_map_box)
#note error messages
cities

#we can also do this with polygons, lines, etc.:
st_intersection(lake_erie, catch_map_box) %>% plot


### Create "range" circles around release site   ########################
release_radius_bad = st_buffer(release_site, dist = .1) 
#units are from CRS, so in this case units = degrees
#error - this is a geographic coordinate system (i.e., on a sphere), so can't measure correctly
mapview(release_radius_bad)

# can find relevant UTM projection using code found here: https://geocompr.robinlovelace.net/reproj-geo-data.html
release_radius <- st_transform(release_site, crs = 32617) %>%   #reproject into projected coord sys
                  st_buffer(dist = 10000)   #creates a circle around BR with radius = 10 km (units = meters)

#compare the two:
mapview(release_radius_bad)+mapview(release_radius)

### Make lines and measure distance b/t capture and release sites    ###########

transport_lines <- capture_sites %>%
  st_union(release_site) %>% # "union" with release site
  st_cast("LINESTRING") %>%   # "cast" into a linestring
  mutate(dist = round(st_length(.), 1)) # calc distance of each line

transport_lines

