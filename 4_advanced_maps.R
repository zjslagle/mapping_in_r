### Part 4 - Advanced Maps     #################################

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
  scale_x_continuous(limits = c(basin_bounds["xmin"], 
                                basin_bounds["xmax"]))+
  scale_y_continuous(limits = c(basin_bounds["ymin"], 
                                basin_bounds["ymax"]))+
  geom_point(data = bass_tracks, 
             aes(x = longitude, 
                 y = latitude, 
                 group = date),
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

#create animation!
# WARNING - this may take a long time!
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
