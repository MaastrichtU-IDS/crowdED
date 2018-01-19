library(shiny)
library(shinydashboard)
library(ggthemes)
library(plotly)

dashboardPage(title = "CrowdED",
              skin = ("blue"),
              dashboardHeader(title = "CrowdED",
                              
                              tags$li(class = "dropdown",
                                      tags$a(href = "http://twitter.com/share?text=Crowdsourcing&Body=You can try yourself", 
                                             target = "_blank", 
                                             tags$img(height = "18px", 
                                                      src = "images/twitter.png")
                                      )
                              )#,
                              
              ),
              
              dashboardSidebar(
                sidebarMenu(
                  #menuItem("Introduction", tabName = "intro", icon = icon("home")),
                  menuItem("Data", tabName = "datafile", icon = icon("table")),
                  menuItem("Analysis", tabName = "analysis", icon = icon("binoculars")),
                  #menuItem("Pipeline", tabName = "pip", icon = icon("file-pdf-o")),
                  #menuItem("Recommender", tabName = "recom", icon = icon("microphone")),
                  menuItem("About", tabName = "about", icon = icon("info")),
                  hr(),
                  sidebarUserPanel(name = a("Amrapali Z", target = "_blank_",
                                            href = "https://www.maastrichtuniversity.nl/amrapali.zaveri"), 
                                   subtitle = "Postdoc Researcher",
                                   image = "images/amrapali.png"),
                  sidebarUserPanel(name = a("Pedro H", target = "_blank_",
                                            href = "https://github.com/pedrohserrano"), 
                                   subtitle = "Data Scientist",
                                   image = "images/pit.png"),
                  sidebarUserPanel(name = a("Michel D", target = "_blank_",
                                            href = "https://github.com/micheldumontier"), 
                                   subtitle = "Distinguished Professor",
                                   image = "images/michel.png"),
                  hr(),
                  menuItem("Source code", icon = icon("file-code-o"), 
                           href = "https://github.com/pedrohserrano/crowdsourcing-task-optimization"),
                  menuItem("Bug Reports", icon = icon("bug"),
                           href = "https://github.com/pedrohserrano/crowdsourcing-task-optimization/issues")
                  
                )
              ),
              
              dashboardBody(
                tags$head(includeScript("www/js/google-analytics.js"),
                          HTML('<link rel="apple-touch-icon" sizes="57x57" href="icons/apple-icon-57x57.png">
                               <link rel="apple-touch-icon" sizes="60x60" href="icons/apple-icon-60x60.png">
                               <link rel="apple-touch-icon" sizes="72x72" href="icons/apple-icon-72x72.png">
                               <link rel="apple-touch-icon" sizes="76x76" href="icons/apple-icon-76x76.png">
                               <link rel="apple-touch-icon" sizes="114x114" href="icons/apple-icon-114x114.png">
                               <link rel="apple-touch-icon" sizes="120x120" href="icons/apple-icon-120x120.png">
                               <link rel="apple-touch-icon" sizes="144x144" href="icons/apple-icon-144x144.png">
                               <link rel="apple-touch-icon" sizes="152x152" href="icons/apple-icon-152x152.png">
                               <link rel="apple-touch-icon" sizes="180x180" href="icons/apple-icon-180x180.png">
                               <link rel="icon" type="image/png" sizes="192x192"  href="icons/android-icon-192x192.png">
                               <link rel="icon" type="image/png" sizes="32x32" href="icons/favicon-32x32.png">
                               <link rel="icon" type="image/png" sizes="96x96" href="icons/favicon-96x96.png">
                               <link rel="icon" type="image/png" sizes="16x16" href="icons/favicon-16x16.png">
                               <link rel="manifest" href="icons/manifest.json">
                               <meta name="msapplication-TileColor" content="#ffffff">
                               <meta name="msapplication-TileImage" content="icons/ms-icon-144x144.png">
                               <meta name="theme-color" content="#ffffff">')),
                tabItems(
                  # Introduction Tab
                  # tabItem(tabName = "intro", 
                  #         div(style = "height:2800px; width:100%", includeHTML("intro.html"))),
                  # 
                  
                  tabItem(tabName = "datafile",
                          style = "overflow-y:scroll;",

                          box(width = 12, height = "150px",
                              valueBoxOutput("progressBoxtodo",width = 12)),
                          #box(width = 6, height = "150px", title = "Unzip",
                          #    infoBoxOutput("progressBox1",width = 6)),
                          box(width = 6, height = "150px", title = "All Up",#mails up",
                              valueBoxOutput("progressBox5",width = 6)),
                          #box(width = 6, height = "150px", title = "Preproc's done",#mails",
                          #    valueBoxOutput("progressBox8",width = 6)),
                          box(width = 6, height = "150px", title = "Analysis done",#mails",
                              valueBoxOutput("progressBox11",width = 6)),
                          #box(width = 6, height = "150px", title = "Recommender",
                          #    valueBoxOutput("progressBox12",width = 6)),
                          box(width = 6, height = "150px", title = "Have fun one more time",
                              actionButton("go", "Reset All"))),
                          # box( width = 6, height = "150px", title = "Shutdown",
                          #      useShinyjs(),                                           # Include shinyjs in the UI
                          #      extendShinyjs(text = jsResetCode),                      # Add the js code to the page
                          #      actionButton("reset_button", "Reset Page"))),
                  
                  tabItem(tabName = "analysis",
                          style = "overflow-y:scroll;",
                          
                          box(width = 15, height = "100px", 
                              sliderInput('sim','Num Simulations', min = 0,max = 9, value = 1)),
                          box(width = 15, height = "500px",
                              plotlyOutput("trendPlot")),#plotOutput("plot"))),
                          box(width = 15, height = "500px",
                            plotlyOutput("trendPlot1"))
                  )
                  
                    

                  )
                  )
                  )

