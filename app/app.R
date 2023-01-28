library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(tidyverse)
library(shinyjs)
library(fresh)


ui <- dashboardPage(
  title = "SEGES App",
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
  dashboardSidebar(collapsed = F
  
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "mytheme.css"),
      tags$style("h2 {color:#555555;}; h4 {color:#555555;}; p {color:#555555;}"),
      tags$style(type = "text/css", "a{color: #00511D;}")
    ),
    
    useShinyjs()
  )
)


server <- function(input, output, session) { 
  
  
}

shinyApp(ui, server)


