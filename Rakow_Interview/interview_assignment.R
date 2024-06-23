# Load required libraries
library(jsonlite)

# Set the working directory
setwd("/Users/artur/Dropbox/Football/Football_Analytics/Rakow_Interview")

# Read the JSON files
d_match_stats <- stream_in(file('player_match_stats_match_3891414.json'))
d_events <- stream_in(file('events_match_3891414.json')) 
d_lineup <- stream_in(file('lineups_match_3891414.json'))
