### Part 3 - Make some maps!    ###########################
# Maps using GGplot and the geom_sf() function

### first - simple map with default bounds   ##############################
our_map <- ggplot()+
  geom_sf(data = us_and_can)+ 
  geom_sf(data = cities, 
          fill = "wheat3")+
  geom_sf(data = lake_erie, 
          fill = "#c5dfed")

our_map

### next - better map, specify bounds  ###############
our_map_2 <- our_map+
  scale_x_continuous(limits = c(catch_map_bounds["xmin"],  #define bounds for map
                                catch_map_bounds["xmax"]))+
  scale_y_continuous(limits = c(catch_map_bounds["ymin"], 
                                catch_map_bounds["ymax"]))+
  geom_text(aes(x = -82.8, 
                y = 41.415, 
                label = "OHIO"), #add "OHIO" label - note, not a simple feature!
            fontface = "bold", 
            size = 10, 
            color = "grey")+
  geom_text(aes(x = -82.95, 
                y = 41.625, 
                label = "LAKE ERIE"), #add "LAKE ERIE" label
            fontface = "bold", 
            size = 10, 
            color = "slategrey")

our_map_2
# note size of labels in preview pane (vs what will be saved) 

### Now - add data      ###############################
our_map_3 <- our_map_2+
  geom_sf(data = capture_sites, # points for capture sites
          aes(size = n_bass_caught), #vary size of point by n_bass_caught
          fill = "lightgreen", 
          color = "black", 
          shape = 21,
          stroke = 1.2)+
  geom_sf(data = release_site, #point for release site
          shape = 24, 
          fill = "#7bccc4", 
          color = "black", 
          size = 3, 
          stroke = 1.2)+
  geom_sf_label(data = release_site, #label for release site
                label = "Release site", 
                nudge_y = c(-.015), # offset from the point itself
                alpha = .85, 
                fontface = "bold")+
  geom_sf(data = us_and_can, #add US/CAN border
          fill = NA, 
          lty = 2, 
          lwd = 2, 
          col = "slategrey")+
  theme(axis.title = element_blank()) #remove axis titles

our_map_3

### Refine legend, add a scale bar & north arrow, tinker with theme settings (e.g. size of text)    ###############################
our_map_4 <- our_map_3+
  scale_size_continuous(name = "  Bass\ncaught (n)", #custom legend
                        breaks = c(1,3,5), 
                        labels = c("1-2     ", "3-4     ", "5-6"), 
                        range = c(2,5))+
  annotation_scale(unit_category = "metric", # add scale bar
                   location = "bl")+
  annotation_north_arrow(which_north = "true", # add orth arrow
                         height = unit(0.7, "cm"),
                         width = unit(0.7, "cm"),
                         pad_y = unit(0.75, "cm"),
                         location = "bl")+
  theme(legend.position = c(.05,           #fine-tune map components
                            .911),
        legend.text = element_text(size = 12),
        legend.key = element_blank(),
        legend.spacing.y = unit(.1, "mm"), 
        legend.box.background = element_rect(color = "black", 
                                             fill = "white")) 

our_map_4



### Save map as PDF    ################################
# you can also use the "ggsave" function or another graphics device like PNG (see below). 
#
#     PDF is used here because it's commonly accepted by journals.

#PDF color map
pdf("figures/figure 1.pdf", 
    width = 10, height = 7, 
    colormodel = "srgb") #colormodel = "grey" or "srgb"
  par(mar=c(5,3,2,2)+0.1) #to trim margins
  our_map_4
dev.off()

#PDF greyscale map - so you can publish color figs and not pay for them!
pdf("figures/figure 1 greyscale.pdf", 
    width = 10, height = 7, 
    colormodel = "grey") #colormodel = "grey" or "srgb"
  par(mar=c(5,3,2,2)+0.1) 
  our_map_4
dev.off()

#or as a PNG (easier for quick previews, sending in emails, etc.)
png(filename = "figures/figure 1.png",
    width = 10, height = 7, 
    units = "in",
    res = 400)
  our_map_4
dev.off()

