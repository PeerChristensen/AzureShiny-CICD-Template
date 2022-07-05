# App using modules to handle new experiments

library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(tidyverse)
library(glue)
library(tidymodels)
library(shinyjs)
library(fresh)


ui <- dashboardPage(
  title = "SEGES App",
  dashboardHeader(
    title = fluidRow(column(3),column(9,
                                      span(img(height = 40, width = 180, src = "logo-seges.png"))))
  ),
  dashboardSidebar(collapsed = F,
                   uiOutput("menu")
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "mytheme.css"),
      tags$style("h2 {color:#555555;}; h4 {color:#555555;}; p {color:#555555;}"),
      tags$style(type = "text/css", "a{color: #00511D;}")
    ),
    useShinyjs(),
    tabItems(
      uiOutput("tabs")
    )
  )
)


server <- function(input, output, session) { 
  
  source("modules.R") # loads data and modules

  values <- reactiveValues(data = NULL, km = NULL, added_rows = NULL, items=NULL)
  values$items <- items
  
  output$menu <- create_menu_items()
  
  output$tabs <- create_tab_items()
  
  tab_ui <- unlist(items$id)
  
  map(tab_ui,tabServer,values=values)
  
  tabServer_new("new",values=values)
  
}

shinyApp(ui, server)


