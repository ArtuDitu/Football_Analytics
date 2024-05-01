# load libraries
library(tidyverse)
library(extrafont)
library(shiny)

# load data
d_full <- read_csv('data_playstyle_wheel.csv')

### R shiny app

ui <- fluidPage(
  titlePanel("Playstyle wheel"),
  sidebarLayout(
    sidebarPanel(
      # Input: Selector for different aspects of data
      selectInput("Year", "Choose a season:",
                  choices = d_full$Season_End_Year),
      # You can add more input controls here like sliders, checkboxes, etc.
      selectInput("Competition", "Choose a competition:",
                  choices = NULL),
      selectInput("Team", "Choose a team:",
                  choices = NULL),
    ),
    mainPanel(
      plotOutput("myPlot"),  # Output: Display interactive plot
    )
  )
)


server <- function(input, output, session) {
  # Update competitions based on selected year
  observeEvent(input$Year, {
    competitions <- unique(d_full$Competition_Name[d_full$Season_End_Year == input$Year])
    updateSelectInput(session, "Competition",
                      choices = competitions,
                      selected = NULL)
  })
  
  # Update teams based on selected year and competition
  observeEvent(list(input$Year, input$Competition), {
    valid_teams <- unique(d_full$Squad[d_full$Season_End_Year == input$Year & d_full$Competition_Name == input$Competition])
    updateSelectInput(session, "Team",
                      choices = valid_teams,
                      selected = NULL)
  })
  output$myPlot <- renderPlot({
    req(input$Year, input$Competition, input$Team)
    team_to_plot <- d_full[d_full$Squad == input$Team & d_full$Season_End_Year == input$Year,]
    # Assuming you're using ggplot for plotting
    ggplot(team_to_plot) +
      # Make custom panel grid
      geom_col(aes(x = Metric, y = Value, fill = Category), position = "dodge2", show.legend = TRUE, alpha = .9) +
      geom_vline(xintercept = 1:13 - 0.5, color = "gray90", alpha = 0.5) +
      geom_hline(yintercept =c(0,25,50,75,100) , color = "gray90", alpha = 0.5) +
      # Make it circular!
      coord_curvedpolar() +
      geom_text(aes(x = Metric, y = Value + 5, label = round(Value)), color = "black", fontface = 'bold') +
      scale_x_discrete(labels = c('Chance Prevention','Intensity', 'High Line', 'Deep buildup', 'Press Resistance', 
                                  'Possession', 'Central Progression','Circulation', 'Field Tilt','Chance Creation', 
                                  'Patient Attack', 'Shot Quality')) +
      scale_fill_manual(values = c("#007D8C", "#FF6F61", "#FFD662", "#708090")) +
      theme(text = element_text(family = "Source Sans Pro", face = 'bold', size = 14),
            panel.background = element_blank(),
            axis.ticks = element_blank(),  
            axis.text.y = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank())
  })
}


shinyApp(ui = ui, server = server)

