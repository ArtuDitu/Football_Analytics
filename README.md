# Football Analytics

In this repo I learn and showcase football data analyst skills.

The projects are listed in the chronological order (the current one at the top)

# Playstyle wheels

**The app is available now: <https://arturczeszumski.shinyapps.io/playstyleapp/>**\
\
The Athletic published their updated playstyle wheels (<https://theathletic.com/5263617/2024/02/13/playstyle-wheels-europe-team-style/>). They summarize a team playing style and the data is from the <https://fbref.com/en/>. Here, I replicate building these wheels. That requires:

1.  Getting data. I use library [worldfootballR](https://github.com/JaseZiv/worldfootballR) that allows to scrape data from <https://fbref.com/en/>.

    library(wordlfootballR)\
    library(tidyverse)\
    library(readr)

2.  Preprocess the data It has to be organized in the shape that will allow plotting. New variables have to calculated and summarized.

    library(tidyverse)\
    library(readr)

3.  Plot the data

    library(ggplot)

4.  Gather more data for many leagues, teams, seasons.

    library(wordlfootballR)\
    library(tidyverse)

5.  Build a Shiny App that will allow comparing playing style between seasons, leagues, and teams.

    library(rshiny)\
    library(ggplot)

6.  Extend the app by displaying metrics over seasons

    library(rshiny)\
    library(ggplot)\
    library(tidyverse)

Steps 1-4 are in the script playstyle_wheels.R and steps 5 and 6 are in the folder PlayStyleApp.\
