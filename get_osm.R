#!/usr/bin/env Rscript
# Description: Extracts OSM data using the Overpass API
# Author: Clement Gorin
# Contact: gorinclem@gmail.com
# Date: February 2021

# Packages
if(!require("pacman")) install.packages("pacman", repos = "https://cloud.r-project.org/")
pacman::p_load(curl, dplyr, geojsonsf, RCurl, sf, stringr, stringi, tictoc, tmap)

# Functions ---------------------------------------------------------------

# Checks API status
check_requirements <- function(server = "http://overpass-api.de/api/status") {
  cat("osmtogeojson", system("osmtogeojson --version"), "\n\n")
  cat(RCurl::getURL(server))    
}

# Extracts OSM data
get_osm <- function(query, server="http://www.overpass-api.de/api/interpreter") {
  cat("Query:\n", query, "\n")
  tictoc::tic("Runtime")  
  query <- paste0(server, "?data=", URLencode(query))
  files <- sapply(c("osm", "geojson"), function(ext) tempfile(fileext = paste0(".", ext)))
  tryCatch(curl::curl_download(query, files["osm"]), error = function(.) message(.))
  system(paste("osmtogeojson", files["osm"], ">", files["geojson"]))
  response <- geojsonsf::geojson_sf(files["geojson"])
  response <- sf::st_make_valid(response)
  unlink(files, recursive = T)
  cat("Features:", nrow(response), "\n")
  tictoc::toc()
  return(response)
}