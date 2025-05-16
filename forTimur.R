library(tidyverse)
library(devtools)
library(writexl)
devtools::install_github("statsbomb/StatsBombR")
devtools::install_github("FCrSTAT/SBpitch")

library(StatsBombR)

Comps <- FreeCompetitions()

Comps <- Comps %>%
  filter(competition_name == "1. Bundesliga" & season_name == "2023/2024")

Matches <- FreeMatches(Comps)

StatsBombData <- free_allevents(MatchesDF = Matches, Parallel = T)
StatsBombData <- allclean(StatsBombData)

one_game <- StatsBombData %>%
  filter(match_id == 3895052)

write_xlsx(one_game, "one_game.xlsx")



#####



openda <- one_game %>%
  filter(player.id == 16275)


### possessions
# Define starting events


# Step 1: Define individual player possessions
starter_events <- c("Ball Receipt*", "Ball Recovery", "Interception", "Miscontrol")

IndividualPossessions <- openda %>%
  filter(type.name %in% starter_events, !is.na(player.name)) %>%
  filter(type.name != "Ball Receipt" | is.na(ball_receipt.outcome.name)) %>%
  mutate(indiv_possession_id = row_number()) %>%  # create unique ID
  select(indiv_possession_id, player.name, possession, start_time = timestamp)

end_events <- c("Pass", "Shot", "Dribble", "Dispossessed", "Miscontrol", 
                "Clearance", "Foul Committed", "Duel", "Error", "Foul Won")

PossessionEndEvents <- openda %>%
  filter(type.name %in% end_events, !is.na(player.name)) %>%
  select(player.name, possession, end_time = timestamp, type.name,
         pass.outcome.name, dribble.outcome.name)

PossessionLabeled <- IndividualPossessions %>%
  left_join(PossessionEndEvents, by = c("player.name", "possession")) %>%
  filter(is.na(end_time) | end_time > start_time) %>%  # only future events
  group_by(indiv_possession_id, player.name) %>%
  slice_min(order_by = end_time, with_ties = FALSE) %>%  # keep first ending event
  ungroup()

PossessionLabeled <- PossessionLabeled %>%
  mutate(successful = case_when(
    type.name == "Pass" & is.na(pass.outcome.name) ~ TRUE,
    type.name == "Dribble" & dribble.outcome.name == "Complete" ~ TRUE,
    type.name == "Shot" ~ TRUE,
    TRUE ~ FALSE
  ))

FinalStats <- PossessionLabeled %>%
  group_by(player.name) %>%
  summarise(
    individual_possessions = n(),
    successful_possessions = sum(successful),
    .groups = "drop"
  ) %>%
  arrange(desc(individual_possessions))

print(FinalStats)




#### 
# Step 1: Define starter events (first touch of possession)


starter_events <- c("Ball Receipt*", "Ball Recovery", "Interception", "Miscontrol")

IndividualPossessions <- openda %>%
  filter(type.name %in% starter_events, !is.na(player.name)) %>%
  filter(type.name != "Ball Receipt*" | is.na(ball_receipt.outcome.name)) %>%
  mutate(indiv_possession_id = row_number()) %>%
  select(indiv_possession_id, player.name, possession, type.name, start_time = timestamp)

PlayerActions <- openda %>%
  filter(!is.na(player.name)) %>%
  select(player.name, possession, timestamp, type.name,
         pass.outcome.name, dribble.outcome.name)

FirstFollowups <- IndividualPossessions %>%
  left_join(PlayerActions, by = c("player.name", "possession")) %>%
  filter(timestamp > start_time) %>%
  group_by(indiv_possession_id) %>%
  slice_min(timestamp, with_ties = FALSE) %>%
  ungroup()

PossessionLabeled <- FirstFollowups %>%
  mutate(
    successful = case_when(
      type.name == "Pass" & is.na(pass.outcome.name) ~ TRUE,
      type.name == "Dribble" & dribble.outcome.name == "Complete" ~ TRUE,
      type.name == "Shot" ~ TRUE,
      TRUE ~ FALSE
    ),
    possession_type = case_when(
      type.name == "Pass" & is.na(pass.outcome.name) ~ "Successful Pass",
      type.name == "Pass" & !is.na(pass.outcome.name) ~ paste("Unsuccessful Pass:", pass.outcome.name),
      type.name == "Dribble" & dribble.outcome.name == "Complete" ~ "Successful Dribble",
      type.name == "Dribble" & !is.na(dribble.outcome.name) ~ paste("Unsuccessful Dribble:", dribble.outcome.name),
      type.name == "Shot" ~ "Shot",
      TRUE ~ paste("Other:", type.name)
    )
  )

FinalStats <- PossessionLabeled %>%
  group_by(player.name) %>%
  summarise(
    individual_possessions = n(),
    successful_possessions = sum(successful),
    .groups = "drop"
  ) %>%
  arrange(desc(individual_possessions))

print(FinalStats)