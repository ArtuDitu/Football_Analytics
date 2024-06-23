# Load required libraries
library(jsonlite)

# Set the working directory
setwd("/Users/artur/Dropbox/Football/Football_Analytics/Rakow_Interview")

# Read the JSON files
d_match_stats <- stream_in(file('player_match_stats_match_3891414.json'))
d_events <- stream_in(file('events_match_3891414.json')) 
d_lineup <- stream_in(file('lineups_match_3891414.json'))


# question #1
# events with shots for both teams
shots_xg <- !is.na(d_events$shot$statsbomb_xg) # take all events that is not NA for xG variable
xG <- data.frame(d_events[shots_xg,]$shot$statsbomb_xg, d_events[shots_xg,]$shot$outcome$name) # take all xG values and check the outcome of the shot

team <- d_events[shots_xg,]$possession_team$name # get the team possessing the ball

xG_teams <- data.frame(xG,team)
