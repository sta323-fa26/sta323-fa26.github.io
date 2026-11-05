# Load package shiny
library(shiny)
library(tidyverse)
# Define UI for application
ui <- fluidPage(
  title = "beta-binomial shiny app",
  titlePanel("beta binomial shiny app"),
  sidebarLayout(
    sidebarPanel = sidebarPanel(
      h4("Data:"),
      # n is the number of coin flips
      sliderInput("n", label = "Number of coin flips",
                  min = 0, max = 100, value = 20),
      # x is the number of heads
      sliderInput("x", label = "Number of heads",
                  min = 0, max = 100, value = 10),
      h4("Prior:"),
      numericInput("a", 
                   label = "Prior number of heads", 
                   value = 1),
      numericInput("b", 
                   label = "Prior number of tails", 
                   value = 1)
    ),
    mainPanel = mainPanel(
      plotOutput("plot")
    )
  )
)
# Define server logic
server <- function(input, output) {
  
  observeEvent(input$n, {
    updateSliderInput(inputId = "x", max = input$n)
  })
  
  output$plot = 
    renderPlot({
      
      # rescaling likelihood because it is not a density function 
      dbinom_rescale = function(x, size, p) {
        c = integrate(dbinom, lower = 0, upper = 1, x = x, size = size)
        dbinom(x = x, size = size, p) / c$value
      }
      
      g = ggplot() +
        xlim(0, 1) +
        stat_function(aes(color = "likelihood"), fun = dbinom_rescale, args = 
                        list(x = input$x, size = input$n)) +
        stat_function(aes(color = "prior"), fun = dbeta, args = list(shape1 = input$a, 
                                               shape2 = input$b)) +
        stat_function(aes(color = "posterior"), fun = dbeta, args = list(input$x + input$a, 
                                                                         input$b + (input$n - input$x)))
        labs(x = "theta")
      g
      
    })
}
# Build and run the application
shinyApp(ui = ui, server = server)