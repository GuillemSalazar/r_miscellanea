library(ggplot2)
library(osmdata)
library(patchwork)
library(extrafont)

# Define variables
cities<-c("Madrid","Barcelona","València")
out_file_path<-"../images/1_osm.png"
plot_width<-13*3
plot_height<-6.5*3
bckg_color<-"white"
subway_color<-"#c42658"
train_color<-"#c0ae48"
street_color<-"black"
title_color<-"black"

# Create a function to retrieve data related to the streets and rail network of a specific city
get_city_data<-function(city=NULL){
  cat("Retrieving data for ",city,":\n")
  cat("Retrieving data on big streets\n")
  big_streets <- getbb(city)%>%
    opq()%>%
    add_osm_feature(key = "highway", 
                    value = c("motorway", "primary", "motorway_link", "primary_link")) %>%
    osmdata_sf()
  
  cat("Retrieving data on medium streets\n")
  med_streets <- getbb(city)%>%
    opq()%>%
    add_osm_feature(key = "highway", 
                    value = c("secondary", "tertiary", "secondary_link", "tertiary_link")) %>%
    osmdata_sf()
  
  cat("Retrieving data on small streets\n")
  small_streets <- getbb(city)%>%
    opq()%>%
    add_osm_feature(key = "highway", 
                    value = c("residential", "living_street",
                              "unclassified",
                              "service", "footway"
                    )) %>%
    osmdata_sf()

  cat("Retrieving data on railways\n")
  subway <- getbb(city)%>%
    opq()%>%
    add_osm_feature(key = "railway", value=c("subway","tram","funicular")) %>%
    osmdata_sf()
  railway <- getbb(city)%>%
    opq()%>%
    add_osm_feature(key = "railway", value=c("rail")) %>%
    osmdata_sf()
  coords<-as.numeric(unlist(strsplit(small_streets$bbox,",")))
  
  cat("Combining data\n")
  return(list(city_name=city,big_streets=big_streets,med_streets=med_streets,small_streets=small_streets,subway=subway,railway=railway,coords=coords))
  cat("DONE\n\n")
}

# Extract the information for several cities and make the individual plots
plot_list<-list(NULL)
for (i in 1:length(cities)){
  toplot<-get_city_data(cities[i])
  plot_list[[i]]<-ggplot() +
    geom_sf(data = toplot$big_streets$osm_lines,inherit.aes = FALSE,color = street_color,size=0.1) +
    geom_sf(data = toplot$med_streets$osm_lines,inherit.aes = FALSE,color = street_color,size=0.1) +
    geom_sf(data = toplot$small_streets$osm_lines,inherit.aes = FALSE,color = street_color,size=0.1) +
    geom_sf(data = toplot$subway$osm_lines,inherit.aes = FALSE,color = subway_color,size=0.5,alpha=0.6) +
    geom_sf(data = toplot$railway$osm_lines,inherit.aes = FALSE,color = train_color,size=0.5,alpha=0.6) +
    theme_void() +
    coord_sf(xlim = toplot$coords[c(2,4)],ylim = toplot$coords[c(1,3)]) +
    labs(title = toplot$city_name,
         subtitle=paste(round(mean(toplot$coords[c(1,3)]),2),"ºN, ",round(mean(toplot$coords[c(2,4)]),2),"ºE")) +
    theme(plot.background = element_rect(fill=bckg_color,color=bckg_color),
          plot.title = element_text(size = 18, color=title_color,family = "Bernard MT Condensed",vjust=-5,hjust=0.5),
          plot.subtitle = element_text(size = 10, color=title_color,family = "Bernard MT Condensed",face = "italic",vjust=-5,hjust=0.5))
  
}

# Combine the plots
g_final<-wrap_plots(plot_list) + plot_layout(nrow = 1) + plot_annotation(title = "Rail transport network of the three biggest cities in Spain",
                                                                         subtitle="Guillem Salazar (@GuillemSalazar)\nData: OpenStreetMaps",
                                                                         theme=theme(plot.title = element_text(size = 22, color=title_color,family = "Bernard MT Condensed",hjust=.5),
                                                                                     plot.subtitle = element_text(size = 10, color=title_color,family = "Bernard MT Condensed",hjust=.5),
                                                                                     plot.background = element_rect(fill=bckg_color,color=bckg_color)))
# Save the plot
ggsave(filename = out_file_path,g_final,width = plot_width,height = plot_height,units = "cm")
