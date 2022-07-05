
library(shiny)

columns <- names(iris)
species_choices <- unique(iris$Species)

create_menu_items <- function(x) {
  
  renderMenu({
    menu_list <- lapply(
      unique(items$dataset),
      function(x) {
        sub_menu_list = lapply(
          items[items$dataset == x,]$experiment,
          function(y) {
            menuSubItem(y, tabName = str_replace_all(paste0("ExpID_", x, "_", y)," ","")
            )
          }
        )
        menuItem(text = x, do.call(tagList, sub_menu_list))
      }
    )
    sidebarMenu(menu_list)
  })
}

create_tab_items <- function(x) {
  
  tab_names <- unlist(items$id)
  tab_headers <- unlist(items$experiment)
  tab_ui <- unlist(items$id)
  
  renderUI({
    tabs <- lapply(1:length(tab_names), function(i) {
      tabItem(tabName = tab_names[i],
              h2(tab_headers[i]),
              tabUI(tab_ui[i]),
      )
      
    })
    do.call(tabItems, tabs)
    # tabItems(
    #     tabItem(tabName = "ExpID_iris_exp1",h2("exp 1"), p("hello1")),
    #     tabItem(tabName = "ExpID_iris_exp2",h2("exp 2"), p("hello2"))
    #     )
  })
}


tabUI <- function(id) {
  ns <- NS(id)
  tabsetPanel(
    upload_data_UI(ns(id)),
    add_rows_UI(ns(id)),
    run_script_UI(ns(id)),
    get_report_UI(ns(id))
  )
}

tabServer <- function(id, values) {
  moduleServer(id, function(input, output, session) {
    
    values$added_rows <- tibble(Sepal.Length = double(),
                                Sepal.Width  = double(),
                                Petal.Length = double(),
                                Petal.Width  = double(),
                                Species      = character()
    )
    
    upload_data_server(id, values)
    add_rows_server(id, values)
    run_script_server(id,values)
    get_report_server(id,values)
  })
}

upload_data_UI <- function(id) {
  
  ns <- NS(id)
  
  tabPanel("UPLOAD DATA",
           box(
             fileInput(ns("dataset"), "Upload CSV File", accept = ".csv"),
             actionButton(ns("data_go"), "Go")
           ),
           box(
             dataTableOutput(ns("table"))
           )
  )
}

upload_data_server <- function(id, values) {
  
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    observeEvent(input$data_go, {
      
      data <- reactive(read_delim(input$dataset$datapath, delim=","))
      output$table <- renderDataTable({data()})
      values$data <- data()
      
    })
  })
}

add_rows_UI <- function(id) {
  
  ns <- NS(id)
  
  tabPanel("ADD ROWS",
           box(
             numericInput(ns("Sepal.Length"),"Sepal.Length", value=0),
             numericInput(ns("Sepal.Width"),"Sepal.Width", value=0),
             numericInput(ns("Petal.Length"),"Petal.Length", value=0),
             numericInput(ns("Petal.Width"),"Petal.Width", value=0),
             selectInput(ns("Species"), "Species", choices = species_choices),
             actionButton(ns("add_row"), "Add row"),
             textOutput(ns("new_rows"))
           ),
           fluidRow(
             uiOutput(ns("new_data_box"))
           ))
}

add_rows_server <- function(id, values) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    msg <- reactiveVal()
    observeEvent(input$add_row, {
      
      msg("New row added")
      
      values$data <- values$data %>%
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
                                          dataTableOutput(ns("new_df"))))
      
      output$new_rows <- renderText({msg()})
      
    })
    
    observeEvent(input$add_row, {
      delay(ms = 1000, msg(NULL))
    })
    
  })
}

run_script_UI <- function(id) {
  
  ns <- NS(id)
  
  tabPanel("RUN SCRIPT",
           box(
             numericInput(ns("nclusters"), "Number of clusters", value = 3),
             varSelectInput(ns("x_var"), "X variable",c()),
             varSelectInput(ns("y_var"), "Y variable",c() ),
             actionButton(ns("kmeansbutton"), "Go"),
             br(),
             plotOutput(ns("kmeansplot"))
           ))
}

run_script_server <- function(id,values) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    choices <- iris %>% select_if(is.numeric) %>% names()
    updateSelectInput(session, "x_var", choices = choices, selected=choices[1])
    updateSelectInput(session, "y_var", choices = choices, selected=choices[2])
    
    observeEvent(input$kmeansbutton, {
      
      kmeans_data <- values$data %>%
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
    
  })
}


get_report_UI <- function(id) {
  
  ns <- NS(id)
  
  tabPanel("GET REPORT",
           box(
             textInput(ns("report_title"),"Report title", value = "Report"),
             textInput(ns("report_author"),"Author name"),
             textAreaInput(ns("description"), "Description"),
             downloadButton(ns("report"), "Generate report")
           ),
           fluidRow(),
           box(
             downloadButton(ns("download_data"), "Download data")
           ))
}

get_report_server <- function(id, values) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
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
    
    output$download_data <- downloadHandler(
      filename = function() {
        paste("dataset.csv", sep = "")
      },
      content = function(file) {
        write_csv(values$data, file)
      }
    )
    
  })
}
