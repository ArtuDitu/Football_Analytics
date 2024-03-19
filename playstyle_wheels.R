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

# get the miscellaneous data
d_misc <- fb_season_team_stats(country = c("ITA", "ENG", "FRA", "GER", "ESP", "POR", "NED"), 
                                     gender = "M", 
                                     season_end_year = 2024, 
                                     tier = "1st", 
                                     stat_type = c('misc'))

# get the defensive action data
d_defense <- fb_season_team_stats(country = c("ITA", "ENG", "FRA", "GER", "ESP", "POR", "NED"), 
                               gender = "M", 
                               season_end_year = 2024, 
                               tier = "1st", 
                               stat_type = c('defense'))

# get the passing type data
d_passing_types <- fb_season_team_stats(country = c("ITA", "ENG", "FRA", "GER", "ESP", "POR", "NED"), 
                               gender = "M", 
                               season_end_year = 2024, 
                               tier = "1st", 
                               stat_type = c('passing_types'))

# get the passing data
d_passing <- fb_season_team_stats(country = c("ITA", "ENG", "FRA", "GER", "ESP", "POR", "NED"), 
                                        gender = "M", 
                                        season_end_year = 2024, 
                                        tier = "1st", 
                                        stat_type = c('passing'))

# get the advanced goalkeeping data
d_keeper_adv <- fb_season_team_stats(country = c("ITA", "ENG", "FRA", "GER", "ESP", "POR", "NED"), 
                                        gender = "M", 
                                        season_end_year = 2024, 
                                        tier = "1st", 
                                        stat_type = c('keeper_adv'))



## Create new variables that are required to calculate metrics for the plot

# append new variable that adds middle and attacking third touches to the main data frame
d$mid_att_touches_opponent <- d_possession$`Mid 3rd_Touches` + d_possession$`Att 3rd_Touches`

# append opponent offside to the main data frame
d$offsides_opponent <- d_misc$Off

# append opponent through balls to the main data frame
d$through_balls_opponent <- d_passing_types$TB_Pass_Types

# append defensive actions of goalkeepers outside of the box
d$goalkeeper_outBox <- d_keeper_adv$`#OPA_Sweeper`

# append passes into final third made by opponent
d$final_third_passes_opponent <- d_passing$Final_Third

# append goalkeeper passes longer than 40 yards (it's measured in %)
d$launch <- d_keeper_adv$Att_Launched/ (d_keeper_adv$Att_Goal_Kicks + d_keeper_adv$`Att (GK)_Passes`)

# append press resistance variable 
d$tackles_def_mid_opponent <- d_defense$`Def 3rd_Tackles` + d_defense$`Mid 3rd_Tackles`
d$touches_def_mid <- d_possession$`Def 3rd_Touches` + d_possession$`Mid 3rd_Touches`

# append central progression variable
d$central_progression <- (d_passing_types$Crs_Pass_Types/ d_passing_types$Live_Pass_Types) * 100


# subset stats for each team
d_for <- d %>%
  subset(Team_or_Opponent == 'team')
# subset stats against each team
d_against <- d %>%
  subset(Team_or_Opponent == 'opponent')

# calculate a variable 'High Line'. it's a sum of conceded offsides, throught balls and goalkeeper actions outside of the box devided by all opponent passes into the final third
d_against$high_line <- (d_against$offsides_opponent + 
                        d_against$through_balls_opponent + 
                        d_for$goalkeeper_outBox) / d_against$final_third_passes_opponent

# append press resistance variable 
d_for$press_resistance <- d_for$touches_def_mid / d_against$tackles_def_mid_opponent

### Defense
## Chance prevention
# Calculate the percentile ranks (inverted for reverse variable)
ecdf_chance_prevention <- ecdf(d_against$npxG_Expected)  # Create the ECDF based on npxG
d_against$chance_prevention <- sapply(d_against$npxG_Expected, function(x) (1 - ecdf_chance_prevention(x)) * 100) # Apply ECDF to each X value to get percentiles

## Intensity
ecdf_intensity <- ecdf(d_against$mid_att_touches_opponent)  # Create the ECDF based on npxG
d_against$intensity <- sapply(d_against$mid_att_touches_opponent, function(x) (1 - ecdf_intensity(x)) * 100) # Apply ECDF to each X value to get percentiles

## High Line
# Calucalte the percentile ranks
ecdf_high_line <- ecdf(d_against$high_line)  # Create the ECDF based on npxG
d_against$high_line_percentile <- sapply(d_against$high_line, function(x) ecdf_high_line(x) * 100) # Apply ECDF to each X value to get percentiles

### Possession
## Deep build-up
ecdf_deep_buildup <- ecdf(d_for$launch)  # Create the ECDF based on npxG
d_for$deep_buildup <- sapply(d_for$launch, function(x) (1 - ecdf_deep_buildup(x)) * 100) # Apply ECDF to each X value to get percentiles

## Press resistance
ecdf_press_resistance <- ecdf(d_for$press_resistance)  # Create the ECDF based on npxG
d_for$press_resistance_percentile <- sapply(d_for$press_resistance, function(x) ecdf_press_resistance(x) * 100) # Apply ECDF to each X value to get percentiles

## Possession
ecdf_possession <- ecdf(d_for$Poss)  # Create the ECDF based on npxG
d_for$possession <- sapply(d_for$Poss, function(x) ecdf_possession(x) * 100) # Apply ECDF to each X value to get percentiles


### Progression
## central progression 
ecdf_central_progression <- ecdf(d_for$central_progression)  # Create the ECDF based on npxG
d_for$central_progression_percentile <- sapply(d_for$central_progression, function(x) (1 - ecdf_central_progression(x)) * 100) # Apply ECDF to each X value to get percentiles

