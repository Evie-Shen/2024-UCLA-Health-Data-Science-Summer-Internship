
#Start off every Shiny application with these 6 lines of code:
library(shiny)
ui <- fluidPage(
)
server <- function(input, output, session) {
}
shinyApp(ui, server)
#These six lines can be accomplished by typing in `shinyApp` and then pressing shift + tab

#Ordering:
#1. Write some code.
#2. Launch the app with Cmd/Ctrl + Shift + Enter.
#3. Interactively experiment with the app.
#4. Close the app.
#5. Go to 1.

#Run app in viewer plane OR in a external window

#Three main types of bugs:
#1. Unexpected error
#2. No errors
#3. Unexpected updating 

#to find problem and see call stack:
traceback()

#Example with traceback()
f <- function(x) g(x)
g <- function(x) h(x)
h <- function(x) x * 2

ui <- fluidPage(
  selectInput("n", "N", 1:10),
  plotOutput("plot")
)
server <- function(input, output, session) {
  output$plot <- renderPlot({
    n <- f(input$n)
    plot(head(cars, n))
  }, res = 96)
}
shinyApp(ui, server)

#After finding issue with traceback, use interactive debugger to find out how to fix it
#Use browser()
if (input$value == "a") {
  browser()
}
# Or maybe
if (my_reactive() < 0) {
  browser()
}

#Print debugging: message() after each step to see where your code is going wrong (similar to print(), but for R)
#Can use glue with message so that something wrapped inside {} will also be printed
library(glue)
name <- "Hadley"
message(glue("Hello {name}"))
#Can also use str() to check the structure of the output

