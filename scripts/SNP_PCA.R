# library(BEDMatrix)
library(ggplot2)

## git clone 

# X <- BEDMatrix("/home/athos/Desktop/teaching/sta323_fa26/examples/HGDP_PopStruct_Exercise/data/H938_Euro.LDprune.bed")
# X <- as.matrix(X)
# 
# dim(X)

# saveRDS(X, "data/snp_pca.rds")

X <- readRDS("data/snp_pca.rds")
dim(X)

missing <- which(is.na(X), arr.ind = TRUE)

X[missing] <- colMeans(X, na.rm = TRUE)[missing[, 2]]

s <- apply(X, 2, sd)

X <- X[, s > 0]

dim(X)

pca <- prcomp(
  X,
  center = TRUE,
  scale. = TRUE
)

head(pca$x[, 1:2])

plot(
  pca$x[, 1],
  pca$x[, 2],
  pch = 19,
  xlab = "PC1",
  ylab = "PC2"
)

pop <- read.table(
  "/home/athos/Desktop/teaching/sta323_fa26/examples/HGDP_PopStruct_Exercise/data/Euro.clst.txt",
  col.names = c("FID", "IID", "population")
)

fam <- read.table("/home/athos/Desktop/teaching/sta323_fa26/examples/HGDP_PopStruct_Exercise/data/H938_Euro.LDprune.fam")

scores <- data.frame(
  IID = fam$V2,
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2]
)

scores$population <-
  pop$population[match(scores$IID, pop$IID)]


ggplot(
  scores,
  aes(PC1, PC2, color = population)
) +
  geom_point(size = 2.5, alpha = 0.8) +
  coord_equal() +
  theme_minimal() +
  labs(
    title = "PCA of European genetic variation",
    subtitle = "Population labels were not used to construct the PCs",
    color = NULL
  )


###

centers <- aggregate(
  cbind(PC1, PC2) ~ population,
  data = scores,
  FUN = median
)

ggplot(
  scores,
  aes(PC1, PC2, color = population)
) +
  geom_point(size = 2.5, alpha = 0.7) +
  geom_text(
    data = centers,
    aes(PC1, PC2, label = population),
    inherit.aes = FALSE,
    fontface = "bold",
    check_overlap = TRUE
  ) +
  coord_equal() +
  theme_minimal() +
  labs(
    title = "PCA of European genetic variation",
    subtitle = "66,147 SNPs compressed to two dimensions",
    color = NULL
  )

####
library(shiny)
library(plotly)

ui <- fluidPage(
  sliderInput(
    "angle",
    "Rotation:",
    min = -180,
    max = 180,
    value = 0,
    step = 1,
    post = "°"
  ),
  plotlyOutput("pca")
)

server <- function(input, output) {
  
  rotated <- reactive({
    theta <- input$angle * pi / 180
    
    transform(
      scores,
      PC1_rot =  cos(theta) * PC1 - sin(theta) * PC2,
      PC2_rot =  sin(theta) * PC1 + cos(theta) * PC2
    )
  })
  
  output$pca <- renderPlotly({
    
    d <- rotated()
    
    plot_ly(
      d,
      x = ~PC1_rot,
      y = ~PC2_rot,
      color = ~population,
      type = "scatter",
      mode = "markers",
      text = ~population,
      hoverinfo = "text"
    ) |>
      layout(
        xaxis = list(title = "PC1"),
        yaxis = list(
          title = "PC2",
          scaleanchor = "x"
        )
      )
  })
}

shinyApp(ui, server)