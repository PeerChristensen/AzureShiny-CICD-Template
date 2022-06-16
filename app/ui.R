# k-means only works with numerical variables,
# so don't give the user the option to select
# a categorical variable
vars <- setdiff(names(iris), "Species")

pageWithSidebar(
  headerPanel('Iris k-means clustering'),
  sidebarPanel(
    selectInput('xcol', 'X Variable', vars),
    selectInput('ycol', 'Y Variable', vars, selected = vars[[2]]),
    numericInput('clusters', 'Cluster count', 3, min = 1, max = 9),
    fileInput("file1", "Choose CSV File",
      multiple = TRUE,
      accept = c("text/csv",
                "text/comma-separated-values,text/plain",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                "application/vnd.ms-excel",
                ".csv")),
  ),
  mainPanel(
    plotOutput('plot1'),
    tableOutput("table1")
  )
)