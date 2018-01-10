library(shiny)
library(shinydashboard)
library(ggthemes)
library(plotly)

# path<-"https://s3-us-west-2.amazonaws.com/dpaequipo10/indicadores/"
# 
# #system(". ./vamb.sh")
# 
# getmap<-function(){
#   print("calculando nombre de mapa")
#   temp<-tempfile()
#   download.file("https://s3-us-west-2.amazonaws.com/dpaequipo10/resultado/mapa.html",temp)
#   system(paste("mv ",temp," mapa.html",sep=""))
#   descargado1<<-1
#   imprimemapa<-includeHTML("mapa.html")
#   
#   return(tags$iframe(
#     srcdoc = imprimemapa,#paste(readLines(imprimemapa,warn=FALSE), collapse = '\n'), #mapa()
#     width = "100%",
#     height = "600px"))
# }
# 
# get_querys<-function(){
#   descargado2<<-1
#   read.csv(textConnection(getURL("https://s3-us-west-2.amazonaws.com/dpaequipo10/descriptivos/date_counts_query.csv")),
#   header=F)
# }
# 
# get_mails<-function(){
#   descargado3<<-1
#   read.csv(textConnection(getURL(
#   "https://s3-us-west-2.amazonaws.com/dpaequipo10/descriptivos/date_counts_mails.csv")),
#   header=F)
# }

# transform_querys_mails<-function(date_counts_querys,date_counts_mails){
#   
#   
#   colnames(date_counts_querys) <- c("Dia","Freq")
#   date_counts_querys$Tipo <- 'Queries'
#   
#   colnames(date_counts_mails) <- c("Dia","Freq")
#   date_counts_mails$Tipo <- 'Mails'
#   
#   date_counts <- rbind(date_counts_querys, date_counts_mails)
#   
#   date_counts$Dia <- as.Date(date_counts$Dia)
#   date_counts$Year <- format(date_counts$Dia, "%Y")
#   date_counts$Month <- format(date_counts$Dia, "%b")
#   date_counts$Day <- format(date_counts$Dia, "%d")
#   date_counts$MonthDay <- format(date_counts$Dia, "%d-%b")
#   
#   return(date_counts)
#   
# }

#ideal <- read.csv("data/UN_IdealPoints.csv", stringsAsFactors = F)
tabla <- read.csv("data/df_simulationsp_train_tasks1.csv", stringsAsFactors = F)
tabla1 <- read.csv("data/df_simulationsworkers_per_task21.csv", stringsAsFactors = F)

# indicador_unzip<-function(){
#   if(file.exists("/tmp/todo_googlet.zip")){
#     return(1)
#   }else{
#     return(0)}
# }
# 
# indicador_agruparbusquedas<-function(){
#   if(file.exists("/tmp/todas_busquedas.json")){
#     return(1)
#   }else{
#     return(0)}
# }
# 
# indicador_uptodasbusquedas<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv(textConnection(getURL(
#       paste(path,"indicador_uptodasbusquedas.csv",sep=""))),
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# indicador_uptodasubicaciones<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv(textConnection(getURL(
#       paste(path,"indicador_uptodasubicaciones.csv",sep=""))),
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# indicador_uptodosmails<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv(textConnection(getURL(
#       paste(path,"indicador_uptodosmails.csv",sep=""))),
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# indicador_preprocbusquedas_fin<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv(textConnection(getURL(
#       paste(path,"indicador_preprocbusquedas_fin.csv",sep=""))),
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# indicador_preprocubicaciones_fin<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv(textConnection(getURL(
#       paste(path,"indicador_preprocubicaciones_fin.csv",sep=""))),
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# indicador_preprocmails_fin<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv(textConnection(getURL(
#       paste(path,"indicador_preprocmails_fin.csv",sep=""))),
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# indicador_analisisbusquedas_fin<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv(textConnection(getURL(
#       paste(path,"indicador_analisisbusquedas_fin.csv",sep=""))),
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# indicador_analisisubicaciones_fin<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv(textConnection(getURL(
#       paste(path,"indicador_analisisubicaciones_fin.csv",sep=""))),
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# indicador_analisismails_fin<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv(textConnection(getURL(
#       paste(path,"indicador_analisismails_fin.csv",sep=""))),
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# indicador_recomendaciones_fin<-function(indicador){
#   if(indicador==0){
#     print("generando consulta a S3")
#     res<-read.csv("indicadores/indicador_recomendaciones_fin.csv",# #textConnection(getURL(
#                   # paste(path,"indicador_recomendaciones_fin.csv",sep="")))
#       header=T)$indicador
#   }else{
#     print("consultas a S3 concluidas")
#     res<-indicador
#   }
#   return(res)
# }
# 
# dibujandomapa<-function(indicador){
#   
#   # if(indicador==0){
#   #   print("generando otra vez la carga del archivo")
#   #   res<-'cosa.html'
#   # }else{
#   print("ya se descarga de s3")
#   res<-'mapa.html'
#   # }
#   return(res)
# 
#   }