### Part 4 - Advanced Maps     #################################

### Add inset map     ######################################

#define new, wider bounding box
great_lakes_bounds <- c(xmin = -92.63, 
                        ymin = 41.18, 
                        xmax = -75.9, 
                        ymax = 49.37)

# make inset map - 
inset_map <- ggplot()+
  scale_x_continuous(limits = c(great_lakes_bounds["xmin"], 
                                great_lakes_bounds["xmax"]))+
  scale_y_continuous(limits = c(great_lakes_bounds["ymin"], 
                                great_lakes_bounds["ymax"]))+
  geom_sf(data = us_and_can, #plot land
          fill = "white")+        
  geom_sf(data = great_lakes, #plot great lakes
          fill = "#9ECAE1", 
          col = "black")+  
  geom_sf(data = catch_map_box, #adds a box around our main map area
          col = "black", 
          fill = NA)+
  theme_minimal()+
  theme(axis.text = element_blank(),#remove graticule (degrees/axis labels)
        panel.border = element_rect(fill = NA,
                                       color = "black", #add black border around map
                                       linewidth = 2)) 
  
inset_map

# Save PDF map, "print" inset map in viewport over main map
pdf("figures/Figure 1 with inset map.pdf", width = 10, height = 7)
  our_map_4+
    theme(legend.position = c(.368,    #adjust legend position
                              .911))
  print(inset_map, 
        vp = viewport(x = 0.22,        # now add inset over main map (uses package gridextra)
                     y = 0.85, 
                     width = 0.3, 
                     height = 0.3))
dev.off()



### Animated map - where do the bass go?    ######################

#load animation package
library(gganimate)

#import locations for daily positions of bass from GLATOS array
bass_tracks <- read_csv("data/bass_basinwide_tracks.csv", 
                          na = c(".","NA"))

bass_tracks 
# Note - we are not making this into a simple feature, 
#        those are more complicated to animate.


# broader bounding box
basin_bounds <- c(xmin = -83.3, 
                 ymin = 41.38, 
                 xmax = -81.9, 
                 ymax = 41.9)

#set up the animation
animated_bass_setup <- our_map_2+ 
  scale_x_continuous(limits = c(basin_bounds["xmin"], #add new, broader bounds
                                basin_bounds["xmax"]))+ # (this does throw an error, it'll be OK)
  scale_y_continuous(limits = c(basin_bounds["ymin"], 
                                basin_bounds["ymax"]))+
  geom_point(data = bass_tracks, 
             aes(x = longitude, 
                 y = latitude, 
                 group = date), #need to group by the factor we're animating over
             pch = 21, 
             color = "black", 
             fill = "darkgreen", 
             size = 5)+         # next line creates title for month of animation
  labs(title = "{unique(bass_tracks$month[which(bass_tracks$date == as.Date(closest_state))])}")+
  transition_states(date,                   # variable to animate over
                    transition_length = 1, 
                    state_length = 1, 
                    wrap = FALSE)+
  enter_fade()+ #these control how smooth things animate etc.
  exit_fade()+
  ease_aes('cubic-in-out')+ 
  shadow_trail(alpha = .4, 
               size = 2)

# Create animation!  #########################################
# WARNING - this may take a long time! Takes ~12 minutes on my PC, this can take way longer if 
#           plotting a complicated map or lots of data. 
animated_bass = animate(animated_bass_setup, 
                        nframes = 813, # number of frames
                        fps = 18, #frames per second
                        width = 800, 
                        height = 600, 
                        units = "px", 
                        device = "png",
                        start_pause = 20, #pause in frames at start/end
                        end_pause = 20) 


# Note - to save time when animating maps, it is best practice to
#       trim your simple features down to only the areas displayed.
#       Maps will take longer to animate if they are plotting the
#       entire US (vs a portion that you cut from an existing
#       geometry using st_intersection)

# Another note - animation (w/ transition_states) needs number of frames 
#       to be similar to row number, otherwise will give error about matching row numbers

#and save animation
anim_save("figures/figure 2 bass movement.gif", 
          animation = animated_bass)
