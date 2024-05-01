# load libraries
library(tidyverse)
library(extrafont)
library(shiny)
library(geomtextpath)

# load data
d_full <- read_csv('data/data_playstyle_wheel.csv')
# order factors for the plots
d_full$Metric <- factor(d_full$Metric, levels = c('Chance_Prevention','Intensity', 'High_Line',
                                                  'Deep_buildup', 'Press_Resistance', 'Possession',
                                                  'Central_Progression','Circulation', 'Field_Tilt',
                                                  'Chance_Creation', 'Patient_Attack', 'Shot_Quality'))

# change year to string and expand it to season instead of year
d_full$Season_End_Year <- paste(d_full$Season_End_Year - 1, d_full$Season_End_Year, sep="/")

### R shiny app

ui <- fluidPage(
  titlePanel("Playstyle wheel"),
  sidebarLayout(
    sidebarPanel(
      tags$h3("Team 1"),
      # Input: Selector for different aspects of data
      selectInput("Year", "Choose a season:",
                  choices = d_full$Season_End_Year),
      # You can add more input controls here like sliders, checkboxes, etc.
      selectInput("Competition", "Choose a competition:",
                  choices = NULL),
      selectInput("Team", "Choose a team:",
                  choices = NULL),
    # Input: Selector for different aspects of data
    tags$h3("Team 2"),
    selectInput("Year2", "Choose a season:",
                choices = d_full$Season_End_Year),
    # You can add more input controls here like sliders, checkboxes, etc.
    selectInput("Competition2", "Choose a competition:",
                choices = NULL),
    selectInput("Team2", "Choose a team:",
                choices = NULL), 
    width = 2
    ),
    mainPanel(
      plotOutput("myPlot", height = "75vh"),
    div(style = "margin-top: 20px;"),
    plotOutput("myPlot2", height = "75vh")# Output: Display interactive plot
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
  
  observeEvent(input$Year2, {
    competitions <- unique(d_full$Competition_Name[d_full$Season_End_Year == input$Year2])
    updateSelectInput(session, "Competition2",
                      choices = competitions,
                      selected = NULL)
  })
  
  # Update teams based on selected year and competition
  observeEvent(list(input$Year2, input$Competition2), {
    valid_teams <- unique(d_full$Squad[d_full$Season_End_Year == input$Year2 & d_full$Competition_Name == input$Competition2])
    updateSelectInput(session, "Team2",
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
      ggtitle(paste(input$Team, ' in ', input$Year)) +
      geom_text(aes(x = Metric, y = Value + 5, label = round(Value)), color = "black", fontface = 'bold') +
      scale_x_discrete(labels = c('Chance Prevention','Intensity', 'High Line', 'Deep buildup', 'Press Resistance', 
                                  'Possession', 'Central Progression','Circulation', 'Field Tilt','Chance Creation', 
                                  'Patient Attack', 'Shot Quality')) +
      scale_fill_manual(values = c("#007D8C", "#FF6F61", "#FFD662", "#708090")) +
      theme(text = element_text(family = "Source Sans Pro", face = 'bold', size = 15),
            panel.background = element_blank(),
            axis.ticks = element_blank(),  
            axis.text.y = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            plot.title = element_text(hjust = 0.5),
            legend.position = "bottom",
            legend.text=element_text(size=12),
            legend.title=element_blank())
  },width = "auto", height = "auto")
  
  output$myPlot2 <- renderPlot({
    req(input$Year2, input$Competition2, input$Team2)
    team_to_plot <- d_full[d_full$Squad == input$Team2 & d_full$Season_End_Year == input$Year2,]
    # Assuming you're using ggplot for plotting
    ggplot(team_to_plot) +
      # Make custom panel grid
      geom_col(aes(x = Metric, y = Value, fill = Category), position = "dodge2", show.legend = TRUE, alpha = .9) +
      geom_vline(xintercept = 1:13 - 0.5, color = "gray90", alpha = 0.5) +
      geom_hline(yintercept =c(0,25,50,75,100) , color = "gray90", alpha = 0.5) +
      # Make it circular!
      coord_curvedpolar() +
      ggtitle(paste(input$Team2, ' in ', input$Year2)) +
      geom_text(aes(x = Metric, y = Value + 5, label = round(Value)), color = "black", fontface = 'bold') +
      scale_x_discrete(labels = c('Chance Prevention','Intensity', 'High Line', 'Deep buildup', 'Press Resistance', 
                                  'Possession', 'Central Progression','Circulation', 'Field Tilt','Chance Creation', 
                                  'Patient Attack', 'Shot Quality')) +
      scale_fill_manual(values = c("#007D8C", "#FF6F61", "#FFD662", "#708090")) +
      theme(text = element_text(family = "Source Sans Pro", face = 'bold', size = 15),
            panel.background = element_blank(),
            axis.ticks = element_blank(),  
            axis.text.y = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            plot.title = element_text(hjust = 0.5),
            legend.position = "none")
  },width = "auto", height = "auto")
}


shinyApp(ui = ui, server = server)

rsconnect::deployApp()

