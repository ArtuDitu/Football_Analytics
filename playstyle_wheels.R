# load libraries
library(worldfootballR)
library(tidyverse)
library(fmsb)
library(ggradar)
library(extrafont)


##Get the data for 7 leagues in season 2023/24

# standard stats
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

# get the shooting data
d_shooting <- fb_season_team_stats(country = c("ITA", "ENG", "FRA", "GER", "ESP", "POR", "NED"), 
                                     gender = "M", 
                                     season_end_year = 2024, 
                                     tier = "1st", 
                                     stat_type = c('shooting'))



## Create new variables that are required to calculate metrics for the plot

# create new variable that adds middle and attacking third touches to the main data frame
d$mid_att_touches_opponent <- d_possession$`Mid 3rd_Touches` + d_possession$`Att 3rd_Touches`

# create opponent offside to the main data frame
d$offsides_opponent <- d_misc$Off

# create opponent through balls to the main data frame
d$through_balls_opponent <- d_passing_types$TB_Pass_Types

# create defensive actions of goalkeepers outside of the box
d$goalkeeper_outBox <- d_keeper_adv$`#OPA_Sweeper`

# create passes into final third made by opponent
d$final_third_passes_opponent <- d_passing$Final_Third

# create goalkeeper passes longer than 40 yards (it's measured in %)
d$launch <- d_keeper_adv$Att_Launched/ (d_keeper_adv$Att_Goal_Kicks + d_keeper_adv$`Att (GK)_Passes`)

# create press resistance variable 
d$tackles_def_mid_opponent <- d_defense$`Def 3rd_Tackles` + d_defense$`Mid 3rd_Tackles`
d$touches_def_mid <- d_possession$`Def 3rd_Touches` + d_possession$`Mid 3rd_Touches`

# create central progression variable
d$central_progression <- (d_passing_types$Crs_Pass_Types/ d_passing_types$Live_Pass_Types) * 100

# create circulate variable
d$circulate <- (d_possession$PrgDist_Carries + d_passing$PrgDist_Total) / d_passing$TotDist_Total

# create variable touches in final third
d$touches_final <- d_possession$`Att 3rd_Touches`

# create variable for patient attack
d$patient_attack <- (d_shooting$Sh_Standard / d_possession$`Att 3rd_Touches`) * 100

# create variable for shot quality
d$shot_quality <- d_shooting$xG_Expected / d_shooting$Sh_Standard



# subset stats for each team
d_for <- d %>%
  subset(Team_or_Opponent == 'team')
# subset stats against each team
d_against <- d %>%
  subset(Team_or_Opponent == 'opponent')

## Create new variables that are required to calculate metrics for the plot (split for/against required)

# calculate a variable 'High Line'. it's a sum of conceded offsides, throught balls and goalkeeper actions outside of the box devided by all opponent passes into the final third
d_against$high_line <- (d_against$offsides_opponent + 
                        d_against$through_balls_opponent + 
                        d_for$goalkeeper_outBox) / d_against$final_third_passes_opponent

# append press resistance variable 
d_for$press_resistance <- d_for$touches_def_mid / d_against$tackles_def_mid_opponent

# create variable field tilt
d_for$field_tilt <- (d_for$touches_final / (d_for$touches_final + d_against$touches_final)) * 100

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
## Central progression 
ecdf_central_progression <- ecdf(d_for$central_progression)  # Create the ECDF based on npxG
d_for$central_progression_percentile <- sapply(d_for$central_progression, function(x) (1 - ecdf_central_progression(x)) * 100) # Apply ECDF to each X value to get percentiles

## Circulate
ecdf_circulate <- ecdf(d_for$circulate)  # Create the ECDF based on npxG
d_for$circulate_percentile <- sapply(d_for$circulate, function(x) (1 - ecdf_circulate(x)) * 100) # Apply ECDF to each X value to get percentiles

## Field tilt
ecdf_field_tilt <- ecdf(d_for$field_tilt)  # Create the ECDF based on npxG
d_for$field_tilt_percentile <- sapply(d_for$field_tilt, function(x) ecdf_field_tilt(x) * 100) # Apply ECDF to each X value to get percentiles

### Attack
## Chance creation
ecdf_chance_creation <- ecdf(d_for$npxG_Per_Minutes)  # Create the ECDF based on npxG
d_for$chance_creation <- sapply(d_for$npxG_Per_Minutes, function(x) ecdf_chance_creation(x) * 100) # Apply ECDF to each X value to get percentiles

## Patient attack
ecdf_patient_attack <- ecdf(d_for$patient_attack)  # Create the ECDF based on npxG
d_for$patient_attack_percentile <- sapply(d_for$patient_attack, function(x) (1 - ecdf_patient_attack(x)) * 100) # Apply ECDF to each X value to get percentiles

## Shot Quality
ecdf_shot_quality <- ecdf(d_for$shot_quality)  # Create the ECDF based on npxG
d_for$shot_quality_percentile <- sapply(d_for$shot_quality, function(x)  ecdf_shot_quality(x) * 100) # Apply ECDF to each X value to get percentiles


#### Select only relevant variables for plotting

d_playstyle_for <- d_for %>%
  select(Competition_Name, Country, Season_End_Year, Squad, Age, deep_buildup, press_resistance_percentile, 
         possession, central_progression_percentile, circulate_percentile, field_tilt_percentile, 
         chance_creation, patient_attack_percentile, shot_quality_percentile)

d_playstyle_against <- d_against %>%
  select(Competition_Name, Country, Season_End_Year, Squad, Age, chance_prevention, intensity, 
         high_line_percentile)

d_playstyle <- cbind(d_playstyle_for, d_playstyle_against$chance_prevention, d_playstyle_against$intensity,
                     d_playstyle_against$high_line_percentile)


# order variables
d_playstyle <- d_playstyle[c("Competition_Name", "Country", "Season_End_Year", "Squad", "Age", 
                             "d_playstyle_against$chance_prevention", "d_playstyle_against$intensity", 
                             "d_playstyle_against$high_line_percentile", "deep_buildup", 
                             "press_resistance_percentile", "possession", "central_progression_percentile",
                             "circulate_percentile", "field_tilt_percentile", "chance_creation",
                             "patient_attack_percentile", "shot_quality_percentile")]

names(d_playstyle) <- c("Competition_Name", "Country", "Season_End_Year", "Squad", "Age", 'Chance_Prevention',
                        'Intensity', 'High_Line', 'Deep_buildup', 'Press_Resistance', 'Possession', 'Central_Progression',
                        'Circulation', 'Field_Tilt', 'Chance_Creation', 'Patient_Attack', 'Shot_Quality')




### radar plot with ggplot2
#change data to long
d_playstale_long <- pivot_longer(
  d_playstyle,
  cols = names(d_playstyle)[6:17],    # Selects all columns that start with 'Var'
  names_to = "Metric",        # New column for variable names
  values_to = "Value"           # New column for variable values
) 
# change matric to factor
d_playstale_long$Metric <- factor(d_playstale_long$Metric)

# add a variable to separate into four categories of different aspects of the game
d_playstale_long <- d_playstale_long %>%
  mutate(Category = factor(case_when(
    Metric %in% c('Chance_Prevention','Intensity', 'High_Line') ~ 'Defensive',
    Metric %in% c('Deep_buildup', 'Press_Resistance', 'Possession') ~ 'Possesion',
    Metric %in% c('Central_Progression','Circulation', 'Field_Tilt') ~ 'Progression',
    Metric %in% c('Chance_Creation', 'Patient_Attack', 'Shot_Quality') ~ 'Attacking',
    TRUE ~ 'None'
  )))





# reorder levels of metrics so that they are separated into four quadrants 
d_playstale_long$Metric <- factor(d_playstale_long$Metric, levels = c('Chance_Prevention','Intensity', 'High_Line',
                                                                          'Deep_buildup', 'Press_Resistance', 'Possession',
                                                                          'Central_Progression','Circulation', 'Field_Tilt',
                                                                          'Chance_Creation', 'Patient_Attack', 'Shot_Quality'))

team_to_plot <- d_playstale_long[d_playstale_long$Squad == 'Juventus',]

plot_playstyle_wheel <- ggplot(team_to_plot) +
  # Make custom panel grid
  geom_col(aes(x = Metric, y = Value, color = Category, fill = Category), position = "dodge2", show.legend = TRUE, alpha = .9) +
  # Make it circular!
  coord_polar() +
  scale_x_discrete(labels = c('Chance Prevention','Intensity', 'High Line', 'Deep buildup', 'Press Resistance', 
                          'Possession', 'Central Progression','Circulation', 'Field Tilt','Chance Creation', 
                          'Patient Attack', 'Shot Quality')) +
  scale_fill_manual(values = c("firebrick4", "lightsteelblue", "yellow2", 'blue'))+
  theme(text = element_text(family = "Source Sans Pro"),
        panel.background = element_rect(fill = "white"),
        axis.ticks = element_blank(),  
        axis.text.y = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank())

plot_playstyle_wheel


