library(rvest)
library(readr)

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
excl <- c("North America[27]", "Europe[28]", "North America", "Oceania[3]", "TOTAL")
shows <- shows[!(shows[,1] %in% excl), ]

# combine with manual lat/longs
stadiums <- read_csv("riverTour.csv")
lat  <- as.data.frame(stadiums$Latitude)
long <- as.data.frame(stadiums$Longitude)
shows <- cbind(shows, lat, long)

# rename columns
colnames(shows) <- c("Date", "City", "Country", "Venue", "Attendance", "Revenue", "Latitude", "Longitude")

