
library(shiny)

#Layout code:
fluidPage(
  titlePanel("Hello Shiny!"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("obs", "Observations:", min = 0, max = 1000, value = 500)
    ),
    mainPanel(
      plotOutput("distPlot")
    )
  )
)
#Hierarchy of function calls:
fluidPage(
  titlePanel(),
  sidebarLayout(
    sidebarPanel(),
    mainPanel()
  )
)

#Most important layout funciton is fluidPage() (it is in almost every code)
#fluidPage() sets up all the HTML, CSS, and JavaScript that Shiny needs
#To make more complex layouts, you’ll need call layout functions inside of fluidPage()

#Ex: two-column layout with inputs on the left and outputs on the right
#along with titlePanel(), sidebarPanel(), and mainPanel()
fluidPage(
  titlePanel(
    # app title/description
  ),
  sidebarLayout(
    sidebarPanel(
      # inputs
    ),
    mainPanel(
      # outputs
    )
  )
)

#The above example with Central limit Theorem
ui <- fluidPage(
  titlePanel("Central limit theorem"),
  sidebarLayout(
    sidebarPanel(
      numericInput("m", "Number of samples:", 2, min = 1, max = 100)
    ),
    mainPanel(
      plotOutput("hist")
    )
  )
)
server <- function(input, output, session) {
  output$hist <- renderPlot({
    means <- replicate(1e4, mean(runif(input$m)))
    hist(means, breaks = 20)
  }, res = 96)
}

#Use fluidRow() and column() to use multirow layout
fluidPage(
  fluidRow(
    column(4, 
           ...
    ),
    column(8, 
           ...
    )
  ),
  fluidRow(
    column(6, 
           ...
    ),
    column(6, 
           ...
    )
  )
)

#tabsetPanel() and tabPanel() for multi page layouts
#tabsetPanel is like a container to hold multiple tabs that you can toggle back and forth between
ui <- fluidPage(
  tabsetPanel(
    tabPanel("Import data", 
             fileInput("file", "Data", buttonLabel = "Upload..."),
             textInput("delim", "Delimiter (leave blank to guess)", ""),
             numericInput("skip", "Rows to skip", 0, min = 0),
             numericInput("rows", "Rows to preview", 10, min = 1)
    ),
    tabPanel("Set parameters"),
    tabPanel("Visualise results")
  )
)

#Use id argument to figure out which tab the user has selected
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      textOutput("panel")
    ),
    mainPanel(
      tabsetPanel(
        id = "tabset",
        tabPanel("panel 1", "one"),
        tabPanel("panel 2", "two"),
        tabPanel("panel 3", "three")
      )
    )
  )
)
server <- function(input, output, session) {
  output$panel <- renderText({
    paste("Current panel: ", input$tabset)
  })
}

#navlistPanel() is similar to tabsetPanel() but instead of running the tab titles horizontally, it shows them vertically in a sidebar and you can add headings
#example:
ui <- fluidPage(
  navlistPanel(
    id = "tabset",
    "Heading 1",
    tabPanel("panel 1", "Panel one contents"),
    "Heading 2",
    tabPanel("panel 2", "Panel two contents"),
    tabPanel("panel 3", "Panel three contents")
  )
)

#navbarPage() and navbarMenu()
ui <- navbarPage(
  "Page title",   
  tabPanel("panel 1", "one"),
  tabPanel("panel 2", "two"),
  tabPanel("panel 3", "three"),
  navbarMenu("subpanels", 
             tabPanel("panel 4a", "four-a"),
             tabPanel("panel 4b", "four-b"),
             tabPanel("panel 4c", "four-c")
  )
)
#navbarMenu instead allows a tab to be a dropdown menu of other tabs for more room

#Themes for styling


shinyApp(ui, server)
