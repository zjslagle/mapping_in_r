### Part 3 - Make some maps!    ###########################
# Maps using GGplot and the geom_sf() function



### Figure 1. West basin of LE with angler catch locations    ###############################
ggplot()+
  scale_x_continuous(limits = c(catch_map_bounds$xmin, catch_map_bounds$xmax))+
  scale_y_continuous(limits = c(catch_map_bounds$ymin, catch_map_bounds$ymax))+
  geom_sf(data = us_and_can)+
  geom_sf(data = lake_erie, fill = "#c5dfed")+ 
  geom_sf(data = cities, fill = "wheat3")+
  geom_text(aes(x = -82.8, y = 41.415, label = "OHIO"),fontface = "bold", size = 10, color = "grey")+
  geom_text(aes(x = -82.95, y = 41.65, label = "LAKE ERIE"),fontface = "bold", size = 10, color = "slategrey")+
  geom_sf(data = capture_sites, aes(size = n_bass_caught),
             fill = "lightgreen", color = "black", shape = 21, stroke = 1.2)+
  geom_sf(data = release_site, shape = 24, fill = "#7bccc4", color = "black", size = 3, stroke = 1.2)+
  geom_sf_label(data = release_site, label = "Release site", nudge_y = c(-.015), alpha = .85, family = "Times", fontface = "bold")+
  geom_sf(data = us_and_can, fill = NA, lty = 2, lwd = 2, col = "slategrey")+ #add US/CAN border
  scale_size_continuous(name = "  Bass\ncaught (n)", breaks = c(1,3,5), labels = c("1-2     ", "3-4     ", "5-6"), range = c(2,5))+
  scale_shape_manual(name = "", label = "Acoustic receiver", values = c("temp" = 21))+
  scale_fill_manual(name = "", label = "Acoustic receiver", values = c("temp2" = "#0868ac"))+
  ggsn::scalebar(dist = 5, model = "WGS84",location = "topleft", dist_unit = "km", 
                 x.min = -83.17094, y.min = 41.40593, x.max = -82.587, y.max = 41.734189,
                 st.dist = .03, anchor = c(x = -83.17, y = 41.69), family = "Times", transform = TRUE,
                 border.size = .5)+
  guides(size = guide_legend(order = 1), shape = guide_legend(order = 2), fill = guide_legend(order = 2))+
  theme(legend.position = c(.179,.935), text = element_text(family = "Times"), #axis.text = element_blank(), axis.ticks = element_blank(), 
        axis.title = element_blank(), legend.direction = "horizontal",
        legend.background = element_blank(), #controls individual legends' backgrounds (don't want)
        legend.key = element_rect(fill = "white"), #controls combined legend background (YES)
        legend.text = element_text(size = 12), legend.box = "horoizontal", 
        legend.spacing.y = unit(.1, "mm"), legend.box.background = element_rect(color = "black", fill = "white"),) -> fish_capture_ggmap 
