library(rvest)      # web scraping 
library(readr)      # fast I/O
library(dplyr)      # data wrangling
library(geosphere)  # great circle distances

# set working directory
wd <- "~/Documents/Repos/webScraping/"
setwd(wd)

# current score location
url <- "https://en.wikipedia.org/wiki/The_River_Tour_2016"

# scrape scores as list
shows_scrape <- url %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="mw-content-text"]/table[2]') %>%
  html_table(fill = T)

# return the required list elements
date       <- as.data.frame(shows_scrape[[1]][[1]])
city       <- as.data.frame(shows_scrape[[1]][[2]])
country    <- as.data.frame(shows_scrape[[1]][[3]])
venue      <- as.data.frame(shows_scrape[[1]][[4]])
attendance <- as.data.frame(shows_scrape[[1]][[6]])
revenue    <- as.data.frame(shows_scrape[[1]][[7]])

# combine into data frame
shows <- cbind(date, city, country, venue, attendance, revenue)

# clean data frame
excl  <- c("North America[27]", "Europe[28]", "North America", "Oceania[3]", "TOTAL")
shows <- shows[!shows[, 1] %in% excl, ]

# combine with manual lat/longs
stadiums <- read_csv("riverTour.csv")
lat      <- as.data.frame(stadiums$Latitude)
long     <- as.data.frame(stadiums$Longitude)
shows    <- cbind(shows, lat, long)

# rename columns
colnames(shows) <- c("Date", "City", "Country", "Venue", "Attendance", "Revenue", "Latitude",
                     "Longitude")

# add columns with previous show's long/lat
shows %>% 
  mutate(Prev_Latitude  = lag(Latitude, n = 1L),
         Prev_Longitude = lag(Longitude, n = 1L)) %>% 
  slice(2:n()) ->
shows

# define longs/lats for distance calc
long1 <- shows$Longitude
long2 <- shows$Prev_Longitude
lat1  <- shows$Latitude
lat2  <- shows$Prev_Latitude

# define point matrices
p1 <- matrix(c(long1, lat1), ncol = 2)
p2 <- matrix(c(long2, lat2), ncol = 2)

# add column with straight line distance and write file to app directory
shows %>% 
  mutate(Dist_kms = distCosine(p1, p2, r = 6378137)/1000,
         Dist_mls = distCosine(p1, p2, r = 6378137)/1609) %>% 
  write_csv("~/Documents/Repos/shinyApps/riverTourMap/data/shows.csv")






