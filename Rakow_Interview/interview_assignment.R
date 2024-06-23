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

# take all xG values and check the outcome of the shot and which team 
xG <- data.frame(d_events[shots_xg,]$shot$statsbomb_xg, 
                 d_events[shots_xg,]$shot$outcome$name,
                 d_events[shots_xg,]$possession_team$name)
colnames(xG)<- c('xG', 'Outcome','Team') # add column names

# which rows in xG table are goals
goals <- which(xG$Outcome == 'Goal')

teams <- unique(xG$Team)
empty_row <- data.frame(xG = NA, Outcome = NA, Team = NA, teamOneDiff = 0, teamTwoDiff = 0, 
                        teamOneFor = 0, teamTwoFor = 0, teamOneAgainst = 0, teamTwoAgainst = 0)
xG$teamOneDiff <- NA
xG$teamTwoDiff <- NA
xG$teamOneFor <- NA
xG$teamOneAgainst <- NA
xG$teamTwoFor <- NA
xG$teamTwoAgainst <- NA

xG <- rbind(empty_row, xG)

for (shot in 2:nrow(xG)){
  if (xG$Team[shot] == teams[1]){
    xG$teamOneDiff[shot] <- xG$teamOneDiff[shot-1] + xG$xG[shot]
    xG$teamOneFor[shot] <- xG$teamOneFor[shot-1] + xG$xG[shot]
    
    xG$teamTwoDiff[shot] <- xG$teamTwoDiff[shot-1] - xG$xG[shot]
    xG$teamTwoAgainst[shot] <- xG$teamTwoAgainst[shot-1] + xG$xG[shot]
  } 
  if (xG$Team[shot] == teams[2]){
    xG$teamTwoDiff[shot] <- xG$teamTwoDiff[shot-1] + xG$xG[shot]
    xG$teamTwoFor[shot] <- xG$teamTwoFor[shot-1] + xG$xG[shot]
    
    xG$teamOneDiff[shot] <- xG$teamOneDiff[shot-1] - xG$xG[shot]
    xG$teamOneAgainst[shot] <- xG$teamOneAgainst[shot-1] + xG$xG[shot]
  }

}


  




