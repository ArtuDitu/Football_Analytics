# Load required libraries
library(jsonlite)
library(tidyverse)


# Set the working directory
setwd("/Users/artur/Dropbox/Football/Football_Analytics/Rakow_Interview")

# Read the JSON files
d_match_stats <- stream_in(file('player_match_stats_match_3891414.json'))
d_events <- stream_in(file('events_match_3891414.json'))
d_lineup <- stream_in(file('lineups_match_3891414.json'))

shots <- data.frame(d_events[which(d_events$shot$body_part$id == 37), ]$play_pattern$id,
                    d_events[which(d_events$shot$body_part$id == 37), ]$player$name)
colnames(shots) <- c('Play_Pattern', 'Name')

shots <- shots %>%
  filter(Play_Pattern %in% c(2,3,4,7,9))

lineups1 <- data.frame(d_lineup$lineup[1]) %>%
  select(player_name, player_height)

lineups2 <- data.frame(d_lineup$lineup[2])  %>%
  select(player_name, player_height)
lineups <- rbind(lineups1, lineups2)


result <- shots %>%
  inner_join(lineups, by = c("Name" = "player_name")) %>%
  arrange(player_height)

print(result[result$player_height == min(result$player_height),]$Name)




