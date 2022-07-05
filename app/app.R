library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(tidyverse)
library(glue)
library(tidymodels)
library(shinyjs)
library(fresh)

light <- "white"
medium <- "#F0F0E9"
dark <- "#E0E0D4"
green <- "#00511D" 
text <- "#555555"

columns <- names(iris)
species_choices <- unique(iris$Species)

instructions1 <- "Some instructions on how to use the app should go here"

ui <- dashboardPage(
  title = "SEGES App",
    dashboardHeader(
      title = fluidRow(column(3),column(9,
        span(img(height = 40, width = 180, src = "logo-seges.png"))))
      )
    ,
  dashboardSidebar(collapsed = F,
                   sidebarMenu(
                     menuItem("HOME", tabName = "home", icon = icon("home"), selected = T),
                     menuItem("IRIS", tabName = "iris", icon = icon("leaf"),
                              menuSubItem('EXPERIMENT 1', tabName = 'iris1'),
                              menuSubItem('EXPERIMENT 2', tabName = 'iris2'),
                              menuItemOutput("new_exp_iris")
                              ),
                     menuItem("TITANIC", tabName = "titanic", icon = icon("ship")),
                     menuItem("ADD NEW", tabName = "add_new_exp", icon = icon("folder-plus"))                     )
                   ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "mytheme.css"),
      tags$style("h2 {color:#555555;}; h4 {color:#555555;}; p {color:#555555;}"),
      tags$style(type = "text/css", "a{color: #00511D;}")
    ),
    #use_theme(mytheme),
    useShinyjs(),
    tabItems(
    tabItem(tabName = "home",
            h2("HOME"),
            fluidRow(),
            box(
              h4("INSTRUCTIONS"),
              p(instructions1)
              )
            ),
    tabItem(tabName = "iris1",
            box(h2("EXPERIMENT 1"),
              p("description here")
              ),
            fluidRow(),
              box(
                tabsetPanel(
                  tabPanel("UPLOAD DATA",
                           h2("UPLOAD DATA"),
                           box(
                               fileInput("iris1_data_input", "Upload CSV File", accept = ".csv"),
                               tags$style(".progress-bar {background-color: #00511D;}"),
                               radioButtons("iris1_sep", "Separator",
                                            choices = c(Comma = ",",
                                                        Semicolon = ";"),
                                            selected = ","),
                               actionButton("iris1_data_go", "Go")
                             ),
                           fluidRow(),
                           fluidRow(
                             uiOutput("validation_box")
                           ),
                           fluidRow(),
                           fluidRow(
                             uiOutput("data_box")
                           )
                           ),
                  tabPanel("ADD ROWS",
                           h2("ADD DATA ROWS"),
                           box(
                             numericInput("Sepal.Length","Sepal.Length", value=0),
                             numericInput("Sepal.Width","Sepal.Width", value=0),
                             numericInput("Petal.Length","Petal.Length", value=0),
                             numericInput("Petal.Width","Petal.Width", value=0),
                             selectInput("Species", "Species",choices = species_choices),
                             actionButton("add_row", "Add row"),
                             textOutput("new_rows")
                           ),
                           fluidRow(),
                           fluidRow(
                             uiOutput("new_data_box")
                           )),
                  tabPanel("RUN SCRIPT",
                           h2("K-MEANS CLUSTERING"),
                           box(
                             numericInput("nclusters", "Number of clusters", value = 3),
                             varSelectInput("x_var", "X variable",c()),
                             varSelectInput("y_var", "Y variable",c() ),
                             actionButton("kmeansbutton", "Go"),
                             br()
                           ),
                           box(width=10,
                             plotOutput("kmeansplot")
                           )
                  ),
                  tabPanel("GET REPORT",
                           h2("DOWNLOAD REPORT AND DATA"),
                           box(
                             textInput("report_title","Report title", value = "Report"),
                             textInput("report_author","Author name"),
                             textAreaInput("description", "Description"),
                             downloadButton("report", "Generate report")
                           ),
                           fluidRow(),
                           box(
                             downloadButton("download_data", "Download data")
                           ))
                  )
                )
            ),
    tabItem(tabName = "iris2",
            box(h2("EXPERIMENT 2"),
                p("description here")
            ),
            fluidRow(),
            box(
              tabsetPanel(
                tabPanel("UPLOAD DATA",
                         h2("UPLOAD DATA"),
                         box(
                           fileInput("iris2_data_input", "Upload CSV File", accept = ".csv"),
                           tags$style(".progress-bar {background-color: #00511D;}"),
                           radioButtons("iris2_sep", "Separator",
                                        choices = c(Comma = ",",
                                                    Semicolon = ";"),
                                        selected = ","),
                           actionButton("iris2_data_go", "Go")
                         ),
                ),
                tabPanel("ADD ROWS"),
                tabPanel("RUN SCRIPT"),
                tabPanel("GET REPORT")
              )
            )
    ),
    tabItem(tabName = "titanic",
            h2("TITANIC"),
            p("description here"),
            fluidRow(
              box(
                h2("NEW EXPERIMENT"),
                textInput("new_exp_titanic_name", "Experiment name"),
                actionButton("new_exp_titanic", "Create new experiment")
                )
              )
    ),
    tabItem(tabName = "add_new_exp",
            h2("ADD NEW EXPERIMENT"),
            p("Some instructions here"),
            fluidRow(
              box(
                h2("NEW EXPERIMENT"),
                textInput("new_exp_iris_name", "Experiment name"),
                actionButton("new_exp_iris", "Create new experiment")
              )
            )
    )
    )
    )
)


server <- function(input, output, session) { 
  
  values <- reactiveValues(iris_df = NULL, km=NULL, added=NULL)
  
  values$added_rows <- tibble(Sepal.Length = double(),
                              Sepal.Width  = double(),
                              Petal.Length = double(),
                              Petal.Width  = double(),
                              Species      = character()
  )
  
  observeEvent(input$iris1_data_go, {
    
    values$iris_df <- NULL
    
    #iris1_df <-  reactive(read_delim(input$iris1_data_input$datapath, delim=input$iris1_sep))
    values$iris_df <- read_delim(input$iris1_data_input$datapath, delim=input$iris1_sep)

    # column match
    output$col_match <- renderText(
      {
        if (identical( names(values$iris_df), columns) ) {"Column names match"}
        else if (!identical( names(values$iris_df), columns) )  {"Column names do not match"}
      })
    
    # missing values
    output$missing <- renderText(
      {glue("N rows containing missing values: {sum(!complete.cases(values$iris_df))}") })
    
    output$validation_box <- renderUI(box(h4("VALIDATION"),
                                          textOutput("col_match"),
                                          textOutput("missing")))
    
    # show data
    output$data_box <- renderUI(box(dataTableOutput("data_contents")))
    
    output$data_contents <- renderDataTable(
      values$iris_df, options = list(pageLength = 5,lengthMenu = c(5, 10, 50, 100)))
    
    #------------- k-means ----------------------------------------------------
    
    choices <- values$iris_df %>% select_if(is.numeric) %>% names()
    updateSelectInput(session, "x_var",choices = choices, selected=choices[1])
    updateSelectInput(session, "y_var",choices = choices, selected=choices[2])
    
  }) # when data is uploaded
  
  observeEvent(input$kmeansbutton, {
    
    kmeans_data <- values$iris_df %>%
      select_if(is.numeric)
    
    kmeans_result <- kmeans_data %>% 
      kmeans(centers = input$nclusters) %>%
      augment(kmeans_data)
    
    values$km <- kmeans_result
    
    output$kmeansplot <- renderPlot(
      
      kmeans_result %>%
        ggplot(aes(!!input$x_var, !!input$y_var, colour = .cluster)) +
        geom_point(size = 2, alpha = .75) +
        theme_minimal()
    )
  })

  #------------- Enter/download data ----------------------------------------------------
  
  msg <- reactiveVal()
  observeEvent(input$add_row, {
    
    msg("New row added")
    
    values$iris_df <- values$iris_df %>%
      add_row(Sepal.Length = input$Sepal.Length,
              Sepal.Width  = input$Sepal.Width,
              Petal.Length = input$Petal.Length,
              Petal.Width  = input$Petal.Width,
              Species      = input$Species)
    
    values$added_rows <- values$added_rows  %>%
      add_row(Sepal.Length = input$Sepal.Length,
              Sepal.Width  = input$Sepal.Width,
              Petal.Length = input$Petal.Length,
              Petal.Width  = input$Petal.Width,
              Species      = input$Species)
    
    output$new_df <- renderDataTable({values$added_rows})
    
    output$new_data_box <- renderUI(box(h4("NEW DATA ENTRIES"),
                                        dataTableOutput("new_df")))
    
    output$new_rows <- renderText({msg()})
    
  })
  
  observeEvent(input$add_row, {
    delay(ms = 1000, msg(NULL))
  })
  
  output$download_data <- downloadHandler(
    filename = function() {
      paste("dataset.csv", sep = "")
    },
    content = function(file) {
      write_csv(values$iris_df, file)
    }
  )
  
  #-------------  Report ----------------------------------------------------
  
  output$report <- downloadHandler(
    
    filename = function(){
      paste0(input$report_title,".html")
    },
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      params <- list(title = input$report_title,
                     author = input$report_author,
                     description = input$description,
                     kmeans_result = values$km,
                     x = input$x_var,
                     y = input$y_var)
      
      render_markdown <- function(){
        rmarkdown::render(tempReport,
                          output_file = file,
                          params = params,
                          #envir = new.env(parent = globalenv())
        )}
      
      render_markdown()
    }
  )
  

   observeEvent(input$new_exp_iris, {
     
     output$new_exp_iris <- renderMenu({
       menuSubItem(input$new_exp_iris_name, tabName = "iris")
     })
   })
  
}

shinyApp(ui, server)


