library(shiny)
library(shinydashboard)
library(ggthemes)
library(plotly)
#options(shiny.maxRequestSize=1000*1024^2) 

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  

  output$trendPlot1 <- renderPlotly({
    
    # if (length(input$name) == 0) {
    #   print("Number of Simulations")
    # } else {
      df_trend <- tabla[tabla$simulation == input$sim, ]
      ggplot(df_trend) +
        geom_line(aes(x = variable, y = accuracy), colour="#0066CC") + #, by = variable, colour = 'yellow')) +
        labs(x = "% Training Tasks", y = "% Accuracy", title = "Consensus based on the % of Training in Stage 1") +
        #scale_colour_hue("clarity", l = 70, c = 150) + 
        ggthemes::theme_few()
    #}
    
  })
  
  output$trendPlot <- renderPlotly({
    
    # if (length(input$name) == 0) {
    #   print("Please select at least one country")
    # } else {
    df_trend <- tabla1[tabla1$simulation == input$sim, ]
    ggplot(df_trend, aes(x = variable, y = accuracy)) +
      geom_bar(stat="identity") + #, by = variable, colour = 'green')) +
      labs(x = "Workers per Task", y = "% Accuracy", title = "Consensus based on the Number of Workers doing each Task") +
      #scale_colour_hue("clarity", l = 70, c = 150) + 
      ggthemes::theme_few() 
    #}
    
  })
  
})
