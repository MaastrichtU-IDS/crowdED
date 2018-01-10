library(shiny)
library(shinydashboard)
library(ggthemes)
library(plotly)


#ideal <- read.csv("data/UN_IdealPoints.csv", stringsAsFactors = F)
tabla <- read.csv("data/df_simulationsp_train_tasks1.csv", stringsAsFactors = F)
tabla1 <- read.csv("data/df_simulationsworkers_per_task21.csv", stringsAsFactors = F)
