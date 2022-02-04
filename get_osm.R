#!/usr/bin/env Rscript
# Description: Extracts OSM data using the Overpass API
# Author: Clement Gorin
# Contact: gorinclem@gmail.com
# Version: 2022.02.04

# Packages
if(!require("pacman")) install.packages("pacman", repos = "https://cloud.r-project.org/")
pacman::p_load(curl, geojsonsf, RCurl, sf, stringr, tictoc, tmap)

# Functions ---------------------------------------------------------------

# Checks requirements
check_requirements <- function(server = "http://overpass-api.de/api/status") {
  cat("osmtogeojson", system("osmtogeojson --version"), "\n\n")
  cat(RCurl::getURL(server))
}

# Checks server availability
check_server <- function(server = "http://overpass-api.de/api/status") {
  status <- RCurl::getURL(server)
  slots  <- stringr::str_extract(status, "\\d(?= slots available now)")
  if(is.na(slots)) {
    wait <- stringr::str_extract(status, "\\d+(?= seconds)")
    cat(sprintf("Server: Waiting %s seconds...\n", wait))
    Sys.sleep(as.numeric(wait))
  }
}

# Extracts OSM data
get_osm <- function(query, server = "http://www.overpass-api.de/api/interpreter") {
  cat(sprintf("Query:\n%s\n", str_replace_all(query, ";", "\n")))
  check_server()
  tictoc::tic("Runtime")  
  query <- paste0(server, "?data=", URLencode(query))
  files <- sapply(c("osm", "geojson"), function(ext) tempfile(fileext = paste0(".", ext)))
  tryCatch(curl::curl_download(query, files["osm"]), error = function(.) message(.))
  system(paste("osmtogeojson", files["osm"], ">", files["geojson"]))
  response <- geojsonsf::geojson_sf(files["geojson"])
  response <- sf::st_make_valid(response)
  unlink(files, recursive = T)
  cat(sprintf("Features: %d\n", nrow(response)))
  tictoc::toc()
  return(response)
}