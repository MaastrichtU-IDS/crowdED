#!/usr/bin/Rscript

#Check R version
#R.version$version.string

#Install requirements
install.packages("shinydashboard")
install.packages("ggthemes")
install.packages("plotly")
install.packages("rsconnect")
install.packages("BH")
install.packages("plogr")

library(rsconnect)
library(BH)
library(plogr)

if(!require("devtools"))
    install.packages("devtools")
devtools::install_github("rstudio/rsconnect")

# Conect to your Shinyapps account
rsconnect::setAccountInfo(name='SHINYAPPSACCOUNTNAME', token='TOKEN', secret='SECRETKEY')

# Deploy App
deployApp()