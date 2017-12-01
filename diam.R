library(shiny)
library(plotly)

data(diamonds, package = "ggplot2")
nms <- names(diamonds)

setwd("~/crowdsourcing-task-optimization")
df.simulations <- read.csv('df_simulations.csv', sep=',', encoding="utf-8")

#names <- names(df.simulations)
#max(df.simulations$simulation)

ui <- fluidPage(
  
  headerPanel("Crowdsourcing"),
  sidebarPanel(
    sliderInput('iterations', 'Iterations', min = 1, max = max(df.simulations$simulation),
                value = 2, step = 1, round = 0),
    selectInput('x', 'Workers', choices = names, selected = "workers"),
    selectInput('y', '% Consensus', choices = names, selected = "accuracy"),
    #selectInput('color', 'Color', choices = nms, selected = "clarity"),
    
    #selectInput('facet_row', 'Facet Row', c(None = '.', nms), selected = "clarity"),
    #selectInput('facet_col', 'Facet Column', c(None = '.', nms)),
    sliderInput('plotHeight', 'Height of plot (in pixels)', 
                min = 100, max = 2000, value = 1000)
  ),
  mainPanel(
    plotlyOutput('trendPlot', height = "900px")
  )
)

server <- function(input, output) {
  
  #add reactive data information. Dataset = built in diamonds data
  dataset <- reactive({
    with(df.simulations, df.simulations[simulation == input$iterations, ])
  })
  
  output$trendPlot <- renderPlotly({
    
    # build graph with ggplot syntax
    p <- ggplot(dataset(), aes_string(x = input$x, y = input$y)) +#, color = input$color)) + 
      geom_point() +  geom_line()
    
    # if at least one facet column/row is specified, add it
    #facets <- paste(input$facet_row, '~', input$facet_col)
    #if (facets != '. ~ .') p <- p + facet_grid(facets)
    
    ggplotly(p) %>% 
      layout(height = input$plotHeight, autosize=TRUE)
    
  })
  
}

shinyApp(ui, server)
