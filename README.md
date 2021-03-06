# Extract OpenStreetMap data

Clement Gorin, gorinclem@gmail.com

The script `get_osm.R` contains functions to extract [OpenStreetMap](https://www.openstreetmap.org) data as a simple feature object in R using the [Overpass](https://overpass-turbo.eu) API. 

## Prerequisites

The script requires the [osmtogeojson](https://tyrasd.github.io/osmtogeojson) command-line utility.

```bash
#!/usr/bin/env bash

sudo apt install npm
npm install -g osmtogeojson
```

## Usage

This example extracts amenities cafes, bars and restaurants in Lyon, France. The queries are written using the [Overpass Query Language](https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_QL).

```r
#!/usr/bin/env Rscript

# Sources get_osm.R
source("https://raw.githubusercontent.com/goclem/get_osm/main/get_osm.R")

# Extracts OSM data
check_requirements()
query    <- "area[admin_level=8][name=Lyon]->.a;nwr[amenity~\'^(cafe|bar|restaurant)$\'](area.a);out center;"
response <- get_osm(query)
response <- subset(response, select = c(id, amenity, name))

# Plots extracted data
tmap_mode("view")
tm_shape(response) +
  tm_dots("amenity")
```

<img src="example.jpeg" width="500" height="500">

Make sure to respect the OpenStreetMap [terms of use](https://wiki.osmfoundation.org/wiki/Terms_of_Use).