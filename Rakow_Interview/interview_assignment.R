# Load required libraries
library(jsonlite)
library(tidyverse)
library(gridExtra)

# Set the working directory
setwd("/Users/artur/Dropbox/Football/Football_Analytics/Rakow_Interview")

# Read the JSON files
d_match_stats <- stream_in(file('player_match_stats_match_3891414.json'))
d_events <- stream_in(file('events_match_3891414.json'))
d_lineup <- stream_in(file('lineups_match_3891414.json'))

# Question #1: Analyze events with shots for both teams
# Filter events with xG values (shots)
shots_xg <- !is.na(d_events$shot$statsbomb_xg)

# Create a dataframe with xG values, outcomes, teams, and minutes of the shots
xG <- data.frame(d_events[shots_xg,]$shot$statsbomb_xg, 
                 d_events[shots_xg,]$shot$outcome$name,
                 d_events[shots_xg,]$possession_team$name,
                 d_events[shots_xg,]$minute)
colnames(xG) <- c('xG', 'Outcome', 'Team', 'Minute')

# Add initial row with minute 0 and accumulated xG of 0 for each team
teams <- unique(xG$Team)
initial_rows <- data.frame(
  xG = 0,
  Outcome = NA,
  Team = teams,
  Minute = 0
)
xG <- rbind(initial_rows, xG)

# Convert Team to a factor and reverse the levels
xG$Team <- factor(xG$Team)
xG$Team <- factor(xG$Team, levels = rev(levels(xG$Team)))

# Calculate accumulated xG for each team over time
xG <- xG %>%
  arrange(Team, Minute) %>%
  group_by(Team) %>%
  mutate(accumulated_xG = cumsum(xG))

# Find the maximum minute in the match
max_minute <- max(xG$Minute)

# Add final row with maximum minute for each team
final_rows <- xG %>%
  group_by(Team) %>%
  summarize(Minute = max_minute, accumulated_xG = last(accumulated_xG), .groups = 'drop') %>%
  mutate(xG = 0, Outcome = NA)
xG <- rbind(xG, final_rows)

# Filter data for goals
goals <- xG %>%
  filter(Outcome == "Goal")

# Calculate the score for each team
score <- goals %>%
  group_by(Team) %>%
  summarise(Goals = n()) %>%
  ungroup()

# Ensure both teams are in the score data frame
score <- complete(score, Team, fill = list(Goals = 0))

# Create a label for the game score
game_score_label <- paste(score$Team[1], score$Goals[1], "-", score$Goals[2], score$Team[2])

# Plot accumulated xG over time for each team using step lines
ggplot(xG, aes(x = Minute, y = accumulated_xG, color = Team, group = Team)) +
  geom_step(size = 1.5) +
  geom_point(data = goals, aes(x = Minute, y = accumulated_xG, fill = Team), size = 3, shape = 21) +
  geom_text(data = goals, aes(x = Minute, y = accumulated_xG, 
                              label = paste0("xG: ", sprintf("%.2f", xG))), 
            vjust = -2, hjust = 0.75, size = 4, color = "black") +  # Increase text size for goal xG values
  geom_text(data = final_rows, aes(x = Minute, y = accumulated_xG, 
                                   label = sprintf("%.2f", accumulated_xG), color = Team), 
            hjust = -0.3, size = 6, show.legend = FALSE) +  # Increase text size for final xG values
  labs(title = game_score_label,
       x = "Minuta",
       y = "xG") +
  scale_y_continuous(breaks = seq(0, max(xG$accumulated_xG) * 1.2, by = 0.25)) +  # Set y-axis breaks every 0.25
  scale_x_continuous(breaks = seq(0, max(xG$Minute), by = 15)) +  # Set x-axis breaks every 15 minutes
  scale_color_brewer(palette = "Set1") +  # Apply a color palette to the lines and points
  scale_fill_brewer(palette = "Set1") +   # Ensure the fill color matches the line color
  coord_cartesian(clip = 'off') +  # Ensure text annotations are not clipped
  theme_minimal() +
  theme(legend.title = element_blank(),
        legend.position = "right",
        legend.text = element_text(size = 14),  # Increase legend text size
        legend.key.size = unit(1.5, "lines"),   # Increase legend key size
        title = element_text(size = 14),
        plot.margin = unit(c(1, 2, 1, 1), "lines"))

# Calculate the difference between xG for each score change

# Function to calculate xG difference at the time of each goal
calculate_xG_difference <- function(goals, xG) {
  results <- data.frame()
  
  for (i in 1:nrow(goals)) {
    goal_event <- goals[i, ]
    goal_minute <- goal_event$Minute
    scoring_team <- goal_event$Team
    
    # Get the state of the game at the goal minute for both teams
    game_state <- xG %>%
      filter(Minute <= goal_minute) %>%
      group_by(Team) %>%
      summarise(accumulated_xG = last(accumulated_xG)) %>%
      ungroup()
    
    # Ensure both teams are included in the game state
    if (nrow(game_state) == 2) {
      team1 <- game_state$Team[1]
      team2 <- game_state$Team[2]
      xg_team1 <- game_state$accumulated_xG[1]
      xg_team2 <- game_state$accumulated_xG[2]
      
      difference <- abs(xg_team1 - xg_team2)
      
      result_row <- data.frame(
        Minute = goal_minute,
        Team1 = team1,
        Team2 = team2,
        accumulated_xG_Team1 = xg_team1,
        accumulated_xG_Team2 = xg_team2,
        xG_difference = difference
      )
      
      results <- rbind(results, result_row)
    }
  }
  
  # Order the results by minute
  results <- results %>%
    arrange(Minute)
  
  return(results)
}

# Calculate the xG differences for goals
goal_differences <- calculate_xG_difference(goals, xG)

# Print the results
print(goal_differences)


