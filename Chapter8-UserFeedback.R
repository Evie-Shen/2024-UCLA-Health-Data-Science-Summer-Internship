
library(shiny)

#4 Types of User Feedback:
# 1. Validation
# 2. Notifications
# 3. Progress Bars
# 4. Confirmation / Undo

#Validation: telling the user they gave bad feedback
ui <- fluidPage(
  shinyFeedback::useShinyFeedback(),
  numericInput("n", "n", value = 10),
  textOutput("half")
)
#Then in your server() function, you call one of the feedback functions: 
#feedback(), feedbackWarning(), feedbackDanger(), and feedbackSuccess()
#Each of these feedback functions will have three arguments:
# 1. inputId, the id of the input where the feedback should be placed.
# 2. show, a logical determining whether or not to show the feedback.
# 3. text, the text to display.
#They also have color and icon arguments that you can use to further customise the appearance

#Example server() of the above rules: (we only want even)
server <- function(input, output, session) {
  half <- reactive({
    even <- input$n %% 2 == 0
    shinyFeedback::feedbackWarning("n", !even, "Please select an even number")
    input$n / 2    
  })
  
  output$half <- renderText(half())
}
#In the same example, to get an odd number to NOT run, we can use the req() function:
server <- function(input, output, session) {
  half <- reactive({
    even <- input$n %% 2 == 0
    shinyFeedback::feedbackWarning("n", !even, "Please select an even number")
    req(even)
    input$n / 2    
  })
  
  output$half <- renderText(half())
}

#If you want nothing to run before the user does something, you can use:
# 1. value = "" for textInput()
# 2. "" as an empty choice for selectInput()

#Example: 
ui <- fluidPage(
  selectInput("language", "Language", choices = c("", "English", "Maori")),
  textInput("name", "Name"),
  textOutput("greeting")
)
server <- function(input, output, session) {
  greetings <- c(
    English = "Hello", 
    Maori = "Kia ora"
  )
  output$greeting <- renderText({
    req(input$language, input$name)
    paste0(greetings[[input$language]], " ", input$name, "!")
  })
}

#Notifications: no problem, but you want to let the user know what is happening

#3 ways to use showNotification():
# 1. notification that appears for a fixed amount of time
# 2. show a notification when a process starts and remove it when the process ends
# 3. update a single notification with progressive updates

#Fixed amount of time example:
ui <- fluidPage(
  actionButton("goodnight", "Good night")
)
server <- function(input, output, session) {
  observeEvent(input$goodnight, {
    showNotification("So long")
    Sys.sleep(1)
    showNotification("Farewell")
    Sys.sleep(1)
    showNotification("Auf Wiedersehen")
    Sys.sleep(1)
    showNotification("Adieu")
  })
}
#Change message type to make it more prominent:
server <- function(input, output, session) {
  observeEvent(input$goodnight, {
    showNotification("So long")
    Sys.sleep(1)
    showNotification("Farewell", type = "message")
    Sys.sleep(1)
    showNotification("Auf Wiedersehen", type = "warning")
    Sys.sleep(1)
    showNotification("Adieu", type = "error")
  })
}

#To remove a notification upon completion:
# 1. Set duration = NULL and closeButton = FALSE so that the notification stays visible until the task is complete
# 2. Store the id returned by showNotification(), and then pass this value to removeNotification() using on.exit()
#Example:
server <- function(input, output, session) {
  data <- reactive({
    id <- showNotification("Reading data...", duration = NULL, closeButton = FALSE)
    on.exit(removeNotification(id), add = TRUE)
    
    read.csv(input$file$datapath)
  })
}

#Progressive updates:
ui <- fluidPage(
  tableOutput("data")
)
server <- function(input, output, session) {
  notify <- function(msg, id = NULL) {
    showNotification(msg, id = id, duration = NULL, closeButton = FALSE)
  }
  
  data <- reactive({ 
    id <- notify("Reading data...")
    on.exit(removeNotification(id), add = TRUE)
    Sys.sleep(1)
    
    notify("Reticulating splines...", id = id)
    Sys.sleep(1)
    
    notify("Herding llamas...", id = id)
    Sys.sleep(1)
    
    notify("Orthogonalizing matrices...", id = id)
    Sys.sleep(1)
    
    mtcars
  })
  
  output$data <- renderTable(head(data()))
}

#Progress bars: so that the user knows something is happening
#Either use shiny of the waiter package
library(waiter)

#Example starting code:
for (i in seq_len(step)) {
  x <- function_that_takes_a_long_time(x)     
}
#Use withProgress() to show the progress bar when the code starts and removes it when it ends
withProgress({
  for (i in seq_len(step)) {
    x <- function_that_takes_a_long_time(x)     
  }
})
#Use incProgress() to increase the progress bar by an increment after every step
withProgress({
  for (i in seq_len(step)) {
    x <- function_that_takes_a_long_time(x)
    incProgress(1 / length(step))
  }
})

#Example of this in a final shiny app:
ui <- fluidPage(
  numericInput("steps", "How many steps?", 10),
  actionButton("go", "go"),
  textOutput("result")
)
server <- function(input, output, session) {
  data <- eventReactive(input$go, {
    withProgress(message = "Computing random number", {
      for (i in seq_len(input$steps)) {
        Sys.sleep(0.5)
        incProgress(1 / input$steps)
      }
      runif(1)
    })
  })
  
  output$result <- renderText(round(data(), 2))
}
# message for explanatory text
# Sys.sleep() to simulate a long running function (just a slow function)
# eventReactive(): allows user to control when event starts

#waiter: provides more visual options
ui <- fluidPage(
  waiter::use_waitress(),
  numericInput("steps", "How many steps?", 10),
  actionButton("go", "go"),
  textOutput("result")
)
# Create a new progress bar
waitress <- waiter::Waitress$new(max = input$steps)
# Automatically close it when done
on.exit(waitress$close())
for (i in seq_len(input$steps)) {
  Sys.sleep(0.5)
  # increment one step
  waitress$inc(1)
}
server <- function(input, output, session) {
  data <- eventReactive(input$go, {
    waitress <- waiter::Waitress$new(max = input$steps)
    on.exit(waitress$close())
    
    for (i in seq_len(input$steps)) {
      Sys.sleep(0.5)
      waitress$inc(1)
    }
    
    runif(1)
  })
  
  output$result <- renderText(round(data(), 2))
}
#you can change the theme for different progress bars

#Spinners: animated spinner for when yo udon't know how long the process will take
#example:
ui <- fluidPage(
  waiter::use_waiter(),
  actionButton("go", "go"),
  textOutput("result")
)
server <- function(input, output, session) {
  data <- eventReactive(input$go, {
    waiter <- waiter::Waiter$new()
    waiter$show()
    on.exit(waiter$hide())
    
    Sys.sleep(sample(5, 1))
    runif(1)
  })
  output$result <- renderText(round(data(), 2))
}

#Confirmation / Undo

#Explicit confirmation: dialogue box pop up asking user if they are sure, uses modalDialog()
modal_confirm <- modalDialog(
  "Are you sure you want to continue?",
  title = "Deleting files",
  footer = tagList(
    actionButton("cancel", "Cancel"),
    actionButton("ok", "Delete", class = "btn btn-danger")
  )
)
#3 things to keep in mind:
# 1. be descriptive with buttons
# 2. how to order buttons (different with Mac and Windows)
# 3. make dangerous button more prominent

#Example: we use showModal() and removeModal() to show or remove the dialogue
ui <- fluidPage(
  actionButton("delete", "Delete all files?")
)
server <- function(input, output, session) {
  observeEvent(input$delete, {
    showModal(modal_confirm)
  })
  
  observeEvent(input$ok, {
    showNotification("Files deleted")
    removeModal()
  })
  observeEvent(input$cancel, {
    removeModal()
  })
}

#Undo
ui <- fluidPage(
  textAreaInput("message", 
                label = NULL, 
                placeholder = "What's happening?",
                rows = 3
  ),
  actionButton("tweet", "Tweet")
)
runLater <- function(action, seconds = 3) {
  observeEvent(
    invalidateLater(seconds * 1000), action, 
    ignoreInit = TRUE, 
    once = TRUE, 
    ignoreNULL = FALSE,
    autoDestroy = FALSE
  )
}

server <- function(input, output, session) {
  waiting <- NULL
  last_message <- NULL
  
  observeEvent(input$tweet, {
    notification <- glue::glue("Tweeted '{input$message}'")
    last_message <<- input$message
    updateTextAreaInput(session, "message", value = "")
    
    showNotification(
      notification,
      action = actionButton("undo", "Undo?"),
      duration = NULL,
      closeButton = FALSE,
      id = "tweeted",
      type = "warning"
    )
    
    waiting <<- runLater({
      cat("Actually sending tweet...\n")
      removeNotification("tweeted")
    })
  })
  
  observeEvent(input$undo, {
    waiting$destroy()
    showNotification("Tweet retracted", id = "tweeted")
    updateTextAreaInput(session, "message", value = last_message)
  })
}


# Run the application 
shinyApp(ui, server)
