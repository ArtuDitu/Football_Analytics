# load libraries
library(worldfootballR)
library(tidyverse)


# Get the data for 7 leagues in season 2023/24
d <- fb_season_team_stats(country = c("ITA", "ENG", "FRA", "GER", "ESP", "POR", "NED"), gender = "M", season_end_year = 2024, tier = "1st", stat_type = 'standard')
# subset stats for each team
d_for <- d %>%
  subset(Team_or_Opponent == 'team')
# subset stats against each team
d_against <- d %>%
  subset(Team_or_Opponent == 'opponent')




