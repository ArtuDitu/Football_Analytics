# Football Analytics

In this repo I learn and showcase data analyst skills.

The projects are listed in the chronological order (the current one at the top)

# Playstyle wheels

The Athletic published their updated playstyle wheels (<https://theathletic.com/5263617/2024/02/13/playstyle-wheels-europe-team-style/>). They summarize a team playing style and the data is from the <https://fbref.com/en/>. Here, I replicate building these wheels. That requires:

1.  Getting data. I use library [worldfootballR](https://github.com/JaseZiv/worldfootballR) that allows to scrape data from <https://fbref.com/en/>.

2.  Preprocess the data It has to be organized in the shape that will allow plotting. New variables have to calculated and summarized.

3.  Plot the data

4.  Gather more data for many leagues, teams, seasons.

5.  Build a Shiny App that will allow comparing playing style between seasons, teams, leagues, managers.
