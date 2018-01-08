# require(shiny)
library(shiny)
library(shinydashboard)
library(ggthemes)
library(plotly)
options(shiny.maxRequestSize=1000*1024^2) 


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  #observe(system(". ./vamb.sh"))
  # observeEvent(input$reset_button, {js$reset()})  
  # activeawsc<-eventReactive(input$awsc,{
  #   
  #   system(". ./vamb.sh")
  #   
  # })
  # 
  # observe({ activeawsc() })
    
  # reset<-eventReactive(input$go,{
  # 
  #     system("./tasks/reset_all.sh")
  # 
  #   })
  # 
  # observe({ reset() })
  # 
  # mvzip<-eventReactive(input$file1,{
  # 
  #   system("./tasks/reset_all.sh")
  #   system(paste("mv ",print(input$file1$datapath)," /tmp/todo_googlet.zip",sep=""))
  #   system("./tasks/unzip_mv.sh")
  #   system("python tasks/agrupar_busquedas.py")
  #   system("python tasks/ups/up_todas_ubicaciones.py")
  #   system("python tasks/ups/up_todas_busquedas.py")
  #   system("./tasks/ups/up_archivos_mails.sh")
  # })
  # 
  # observe({ mvzip() })
  # 
  # autoInvalidate <- reactiveTimer(10000)
  # autoInvalidate_querys<-reactiveTimer(10000)
  # autoInvalidate_mails<-reactiveTimer(10000)

  # x1<-0
  # progress1 <- reactive({
  #   print(paste("antes de empezar x1 vale: ",x1,sep=""))
  #   autoInvalidate()
  #   if(x1==0){
  #     
  #     y<-indicador_unzip()
  #     x1<<-y
  #     print(paste("Dentro del if, x1 vale: ",x1,sep=""))
  #     print(x1)
  #     
  #   }else{
  #     print(paste("Sin leer el archivo, x1 vale: ",x1,sep=""))
  #     print(x1)
  #   }
  # })
  # # 
  # x5<-0
  # progress5 <- reactive({
  #   print(paste("antes de empezar x5 vale: ",x5,sep=""))
  #   autoInvalidate()
  #   if(x5==0){
  #     
  #     y<-indicador_uptodosmails(x5)
  #     x5<<-y
  #     print(paste("Dentro del if, x5 vale: ",x5,sep=""))
  #     print(x5)
  #     
  #   }else{
  #     print(paste("Sin leer el archivo, x1 vale: ",x1,sep=""))
  #     print(x1)
  #   }
  # })
  # 
  # x8<-0
  # progress8 <- reactive({
  #   print(paste("antes de empezar x8 vale: ",x8,sep=""))
  #   autoInvalidate()
  #   if(x8==0){
  #     
  #     y<-indicador_preprocmails_fin(x8)
  #     x8<<-y
  #     print(paste("Dentro del if, x8 vale: ",x8,sep=""))
  #     print(x8)
  #     
  #   }else{
  #     print(paste("Sin leer el archivo, x8 vale: ",x8,sep=""))
  #     print(x8)
  #   }
  # })
  # 
  # x11<-0
  # progress11 <- reactive({
  #   print(paste("antes de empezar x11 vale: ",x11,sep=""))
  #   autoInvalidate()
  #   if(x11==0){
  #     
  #     y<-indicador_analisismails_fin(x11)
  #     x11<<-y
  #     print(paste("Dentro del if, x11 vale: ",x11,sep=""))
  #     print(x11)
  #     
  #   }else{
  #     print(paste("Sin leer el archivo, x11 vale: ",x11,sep=""))
  #     print(x11)
  #   }
  # })
  # # 
  # # x12<-0
  # progress12 <- reactive({
  #   print(paste("antes de empezar x12 vale: ",x12,sep=""))
  #   autoInvalidate()
  #   if(x12==0){
  #     
  #     y<-indicador_recomendaciones_fin(x12)
  #     x12<<-y
  #     print(paste("Dentro del if, x12 vale: ",x12,sep=""))
  #     print(x12)
  #     
  #   }else{
  #     print(paste("Sin leer el archivo, x12 vale: ",x12,sep=""))
  #     print(x12)
  #   }
  # })
  
  
  # printmapa<-tags$iframe(
  #     srcdoc = includeHTML("www/wait4it.html"),#paste(readLines(imprimemapa,warn=FALSE), collapse = '\n'), #mapa()
  #     width = "90%",
  #     height = "600px")
  
  # descargado1<-0 
  # mapa<-reactive({
  #     
  #     autoInvalidate()
  #     if(x12==1 & descargado1==0){
  #       
  #       descargado1<<-1
  #       autoInvalidate <<- reactiveTimer(500000)
  #       printmapa<<-getmap()
  #       printmapa
  #       
  #     }else{
  #       printmapa
  #       }
  # 
  #   
  # })
  # 
  # printquerys<-read.csv("data/waiting4_querys.csv",header=FALSE)
  # descargado2<-0
  # date_counts_querys<-reactive({
  #   autoInvalidate_querys()
  #   if(x12==1 & descargado2==0){
  #     
  #     descargado2<<-1
  #     autoInvalidate_querys <<- reactiveTimer(500000)
  #     printquerys<<-get_querys()
  #     printquerys
  #     
  #   }else{
  #     printquerys
  #   }
  # })
  # 
  # printmails<-read.csv("data/waiting4_mails.csv",header=FALSE)
  # descargado3<-0
  # date_counts_mails<-reactive({
  #   autoInvalidate_mails()
  #   if(x12==1 & descargado3==0){
  #     
  #     descargado3<<-1
  #     autoInvalidate_mails <<- reactiveTimer(500000)
  #     printmails<<-get_mails()
  #     printmails
  #     
  #   }else{
  #     printmails
  #   }
  # })
  # 
  # 
  # date_counts<-reactive({
  #   
  #   transform_querys_mails(date_counts_querys(),date_counts_mails())
  #   
  # })
  # 
  # 
  # all<-reactive({progress1()+progress5()+progress8()+
  #     progress11()+progress12()})
  # 
  # # Same as above, but with fill=TRUE
  # # output$progressBox1 <- renderInfoBox({
  # #   infoBox(
  # #     "Progress", paste0((100*progress1()), "%"), icon = icon("list"),
  # #     color = "purple", fill = TRUE
  # #   )
  # # })
  # # 
  # output$progressBox5 <- renderInfoBox({
  #   infoBox(
  #     "Progress", paste0((100*progress5()), "%"), icon = icon("list"),
  #     color = "blue", fill = TRUE
  #   )
  # })
  # 
  # # output$progressBox8 <- renderInfoBox({
  # #   infoBox(
  # #     "Progress", paste0((100*progress8()), "%"), icon = icon("list"),
  # #     color = "red", fill = TRUE
  # #   )
  # # })
  # 
  # output$progressBox11 <- renderInfoBox({
  #   infoBox(
  #     "Progress", paste0((100*progress11()), "%"), icon = icon("list"),
  #     color = "green", fill = TRUE
  #   )
  # })
  # 
  # # output$progressBox12 <- renderInfoBox({
  # #   infoBox(
  # #     "Progress", paste0((100*progress12()), "%"), icon = icon("list"),
  # #     color = "fuchsia", fill = TRUE
  # #   )
  # # })
  # 
  # output$progressBoxtodo <- renderInfoBox({
  #   infoBox(
  #     "Getting Ready...", paste0((100*(all())/5), "%"), icon = icon("grav"),
  #     color = "black", fill = TRUE
  #   )
  # })
  
  # mapa en recomender 
  # output$mymap <- renderUI({
  #   mapa()#getmap()
  #   # tags$iframe(
  #   #   srcdoc = paste(readLines(getmap()), collapse = '\n'), #mapa()
  #   #   width = "100%",
  #   #   height = "600px")
  # })
  
  # output$plot<-renderPlot({
  #   
  #   #date_counts <- date_counts_mails[date_counts$Year>=2014,]
  #   
  #   ggplot(data = date_counts(),
  #          mapping = aes(x = date_counts()$Dia, y = date_counts()$Freq,  shape = Tipo, colour = Tipo)) + 
  #     geom_line() +  xlab("") + ylab("Frecuencia")
  #   
  # })
  
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
