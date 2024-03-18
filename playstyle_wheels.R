# load libraries
library(worldfootballR)
library(tidyverse)


# Get the data for 7 leagues in season 2023/24
d <- fb_season_team_stats(country = c("ITA", "ENG", "FRA", "GER", "ESP", "POR", "NED"), 
                          gender = "M", 
                          season_end_year = 2024, 
                          tier = "1st", 
                          stat_type = c('standard'))

# get the possession data
d_possession <- fb_season_team_stats(country = c("ITA", "ENG", "FRA", "GER", "ESP", "POR", "NED"), 
                                   gender = "M", 
                                   season_end_year = 2024, 
                                   tier = "1st", 
                                   stat_type = c('possession'))

# add new variable that adds middle and attacking third touches to the main data frame
d$mid_att_touches_opponent <- d_possession$`Mid 3rd_Touches` + d_possession$`Att 3rd_Touches`


# subset stats for each team
d_for <- d %>%
  subset(Team_or_Opponent == 'team')
# subset stats against each team
d_against <- d %>%
  subset(Team_or_Opponent == 'opponent')


### Defense
## Chance prevention
# Calculate the percentile ranks (inverted for reverse variable)
ecdf_chance_prevention <- ecdf(d_against$npxG_Expected)  # Create the ECDF based on npxG
d_against$chance_prevention <- sapply(d_against$npxG_Expected, function(x) (1 - ecdf_chance_prevention(x)) * 100) # Apply ECDF to each X value to get percentiles

## Intensity
ecdf_intensity <- ecdf(d_against$mid_att_touches_opponent)  # Create the ECDF based on npxG
d_against$intensity <- sapply(d_against$mid_att_touches_opponent, function(x) (1 - ecdf_intensity(x)) * 100) # Apply ECDF to each X value to get percentiles




