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
  title = "SEGES App test",
  dashboardHeader(
    tags$li(class = "dropdown",
            tags$style(".main-header {max-height: 75px}"),
            tags$style(".main-header .logo {height: 75px;padding-top:10px;padding-right:100px;}"),
            tags$style(".main-sidebar {padding-top: 75px;}"),
            tags$style(".sidebar-toggle {height: 75px; padding-top: 1px !important;}"),
            tags$style(".navbar {min-height:75px !important;line-height:3; font-size:20px;}")
    ),
    title = fluidRow(
      column(3),
      column(9,span(img(height = 55, width = 220, src = "logo-seges.png"))))
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


