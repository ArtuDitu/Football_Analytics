# Load required libraries
library(jsonlite)
library(tidyverse)
library(ggsoccer)

# Set the working directory
setwd("/Users/artur/Dropbox/Football/Football_Analytics/Rakow_Interview")

# Read the JSON files
d_match_stats <- stream_in(file('player_match_stats_match_3891414.json'))
d_events <- stream_in(file('events_match_3891414.json'))
d_lineup <- stream_in(file('lineups_match_3891414.json'))


# define half spaces and penalty area
penalty_x <- 102
penalty_y_min <- 18
penalty_y_max <- 62

# divide y (width) by 5 spaces (left, left half-space, middle, right half-space, right)
left_half_spaces_y_min <- 16
left_half_spaces_y_max <- 32
right_half_spaces_y_min <- 48
right_half_spaces_y_max <- 64

# select data
passes <- data.frame(d_events[d_events$type$id == 30,]$possession_team$name,
                     map_dbl(d_events[d_events$type$id == 30,]$location, 1),
                     map_dbl(d_events[d_events$type$id == 30,]$location, 2),
                     map_dbl(d_events[d_events$type$id == 30,]$pass$end_location, 1),
                     map_dbl(d_events[d_events$type$id == 30,]$pass$end_location, 2),
                     d_events[d_events$type$id == 30,]$pass$outcome$name)
colnames(passes) <- c('Team', 'pass_start_x', 'pass_start_y', 'pass_end_x', 'pass_end_y', 'pass_outcome')

# get passes from half spaces to the penalty box for each team
passes_half_spaces <- passes %>%
  filter(pass_start_x < penalty_x,
    (pass_start_y > left_half_spaces_y_min & pass_start_y < left_half_spaces_y_max) | 
           (pass_start_y > right_half_spaces_y_min & pass_start_y < right_half_spaces_y_max),
         pass_end_x > penalty_x & pass_end_x < 120,
         pass_end_y > penalty_y_min & pass_end_y < penalty_y_max)

teams <- unique(passes$Team)

nrow(passes_half_spaces[passes_half_spaces$Team == teams[1],])
nrow(passes_half_spaces[passes_half_spaces$Team == teams[2],])

# Convert Team to a factor and reverse the levels
passes_half_spaces$Team <- factor(passes_half_spaces$Team)
passes_half_spaces$Team <- factor(passes_half_spaces$Team, levels = rev(levels(passes_half_spaces$Team)))

# make a pitch to plot passes
ggplot(passes_half_spaces) +
  annotate_pitch(dimensions = pitch_statsbomb) +
  geom_segment(aes(x = pass_start_x, y = pass_start_y, xend = pass_end_x, yend = pass_end_y, colour = Team),
               arrow = arrow(length = unit(0.25, "cm"),
                             type = "closed")) +
  scale_color_brewer(palette = "Set1") +
  theme_pitch() +
  labs(title = 'Podania z półprzestrzeni do pola karnego')