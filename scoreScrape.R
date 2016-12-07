library(rvest)
library(dplyr)
library(readr)

# set working directory
wd <- "~/Documents/Repos/shinyApps/nraaResults/data/"
setwd(wd)

# current score location
url <- "https://www.nraa.com.au/the-canberra-queens-prize-2016-act-results/"

# scrape scores as list
scores_scrape <- url %>%
  read_html() %>%
  html_nodes(xpath = '/html/body/div[1]/div[2]/div[1]/table') %>%
  html_table(fill = T)

# return the only list element as data frame
scores <- scores_scrape[[1]]

# return only rows with score data
excl <- c("Target Rifle - A"
          , "Target Rifle - B"
          , "Target Rifle - C"
          , "F Standard - A"
          , "F Standard - B"
          , "F Open - FO"
          , "F/TR - A")

# shift initial grade down
scores$Row   <- row.names(scores)
scores$Grade <- lag(scores$Place, n = 1L)

# grade indexes
traRow <- grep(excl[1], scores$Grade)
trbRow <- grep(excl[2], scores$Grade)
trcRow <- grep(excl[3], scores$Grade)
fsaRow <- grep(excl[4], scores$Grade)
fsbRow <- grep(excl[5], scores$Grade)
fopRow <- grep(excl[6], scores$Grade)
ftrRow <- grep(excl[7], scores$Grade)

# fill grades
scores$Grade <- ifelse(as.integer(scores$Row) < trbRow, excl[1],
                  ifelse(as.integer(scores$Row) < trcRow, excl[2],
                    ifelse(as.integer(scores$Row) < fsaRow, excl[3],
                      ifelse(as.integer(scores$Row) < fsbRow, excl[4], 
                        ifelse(as.integer(scores$Row) < fopRow, excl[5],
                          ifelse(as.integer(scores$Row) < ftrRow, excl[6], 
                            excl[7]))))))

# select columns
scores %>%
  select(Grade
         , Place
         , `Last Name`
         , `Preferred Name`
         , Club
         , State
         , Info
         , Score)%>%
  mutate(Year = as.character(readline("Enter year:"))) %>%
  mutate(Championship = readline("Enter Association eg. NRAA:")) %>%
  mutate(Match = readline("Enter Leadup, Queens or Grand:")) %>%
  select(Year
         , Championship
         , Match
         , Grade
         , Place
         , `Last Name`
         , `Preferred Name`
         , Club
         , State
         , Info
         , Score) %>%
  filter(!(Place %in% excl)) ->
scores2

# append to data file
write_csv(scores2, "nraaResults.csv", append = TRUE)