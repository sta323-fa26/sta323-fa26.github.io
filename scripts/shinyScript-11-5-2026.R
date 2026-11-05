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
                   value = 1),
      h4("ABC:"),
      numericInput("n_sim", "Number of simulations:", 
                   min = 0, value = 10000),
      numericInput("n_min", "Minimum number of posterior samples", min = 0,
                   value = 1000),
      actionButton("run", "Run simulations")
    ),
    mainPanel = mainPanel(
      plotOutput("plot"),
      textOutput("abc_summary"),
      downloadButton(outputId = "downloadPlot", label = "Download plot", class = NULL)
    )
  )
)
# Define server logic
server <- function(input, output) {
  
  observeEvent(input$n, updateSliderInput(inputId = "x", max = input$n))
  
  abc_post <- reactive({
    validate(need(input$n_min, "Need a value for minimum number of posterior samples."))
    # generate coins
    abc_prior <- rbeta(n = input$n_sim, input$a, input$b)
    # use each generated coin to simulate data
    abc_data_gen <- rbinom(n = input$n_sim, size = input$n, prob = abc_prior)
    # keep the coins that generate simulated data which matches actual data
    abc_prior[abc_data_gen == input$x]
    
  }) |>
    bindEvent(input$run)
  
  abc_post_dens <- reactive({
    validate(
      need(length(abc_post()) >= input$n_min, 
           "Insufficient number of posterior samples. Increase the # of simulations.")
    )
    abc_dens <- density(abc_post())
    tibble(
      theta = abc_dens$x,
      dens = abc_dens$y
    )
  })

  output$abc_summary = renderText({
    glue::glue(
      "Ran {input$n_sim} number generative simulations and obtained {length(abc_post())} ",
      "posterior samples.\nEfficiency of {100 * length(abc_post()) / input$n_sim}")
  })
  
  output$plot = 
    renderPlot({
      
      # rescaling likelihood because it is not a density function 
      dbinom_rescale = function(x, size, p) {
        c = integrate(dbinom, lower = 0, upper = 1, x = x, size = size)
        dbinom(x = x, size = size, p) / c$value
      }
      
      g <- ggplot() +
        xlim(0, 1) +
        stat_function(aes(color = "likelihood"), fun = dbinom_rescale, args = 
                        list(x = input$x, size = input$n)) +
        stat_function(aes(color = "prior"), fun = dbeta, args = list(shape1 = input$a, 
                                                                     shape2 = input$b)) +
        stat_function(aes(color = "posterior"), fun = dbeta, args = list(input$x + input$a, 
                                                                         input$b + (input$n - input$x))) +
        geom_line(data = abc_post_dens(), 
                  aes(x = theta, y = dens, color = "ABC posterior"))  +
      labs(x = "theta")
      
      output$downloadPlot <- downloadHandler(
        filename = function() {
          paste0("my_plot_", Sys.Date(), ".png")
        },
        content = function(file) {
          ggsave(file, plot = g, device = "png", width = 7, height = 5, dpi = 300)
        }
      )
      
      g
      
    })

}
# Build and run the application
shinyApp(ui = ui, server = server)