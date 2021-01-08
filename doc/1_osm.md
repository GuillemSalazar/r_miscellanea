---
title: "Rail transport network of the three largest cities in Spain"
---

Plotting the rail transport network of Madrid, Barcelona and Valencia. Code available [here](https://github.com/GuillemSalazar/r_miscellanea/blob/gh-pages/code/osmdata.R).

![osm](../images/1_osm.png)

### How to:

OpenStreetMap ([OSM](https://www.openstreetmap.org/)) is a global open access mapping project, which is free and open. The [osmdata](https://cran.r-project.org/web/packages/osmdata/index.html) R package provides access to the vector data underlying OSM and thus allows us to easily produce a virtual infinite variety of maps, depending on the objects to be plotted.

Here I combined several functions from the *osmdata* package to download the vector data for the street grid of a given city and its rail transport network. In brief, the function `getbb()` allows us to to find the bounding box associated with the city name and the function `add_osm_feature()` allows us to define the desired OSM features we want to extract, which are accessed through an overpass query using the `opq()` and `osmdata_sf()` functions. Thus, the following code downloads the vector data for the subway network of Barcelona:

```{R}
library(osmdata)

subway <- getbb("Barcelona")%>%
    opq()%>%
    add_osm_feature(key = "railway", value=c("subway","tram","funicular")) %>%
    osmdata_sf()
```

I used this approach to build a function (`get_city_data()`) which downloads the street grid of a given city and its rail transport network and stores the information into a list that can be used for plotting maps using the [ggplot2](https://ggplot2.tidyverse.org) package. I recursively used this function for Madrid, Barcelona and València and combined the plots with the help of the [patchwork](https://github.com/thomasp85/patchwork) package.