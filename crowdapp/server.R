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
        geom_line(aes(x = variable, y = accuracy), colour="blue") + #, by = variable, colour = 'yellow')) +
        labs(x = "% Training Tasks", y = "% Concesus of Workers", title = "Concensus based on the % of training in stage 1") +
        #scale_colour_hue("clarity", l = 70, c = 150) + 
        ggthemes::theme_few()
    #}
    
  })
  
  output$trendPlot <- renderPlotly({
    
    # if (length(input$name) == 0) {
    #   print("Please select at least one country")
    # } else {
    df_trend <- tabla1[tabla1$simulation == input$sim, ]
    ggplot(df_trend) +
      geom_line(aes(x = variable, y = accuracy), colour="red") + #, by = variable, colour = 'green')) +
      labs(x = "Workers per Task", y = "% Concesus of Workers", title = "Concensus based on the Number of Workers doing each Task") +
      #scale_colour_hue("clarity", l = 70, c = 150) + 
      ggthemes::theme_few() 
    #}
    
  })
  
})
