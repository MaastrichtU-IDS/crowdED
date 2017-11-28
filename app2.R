#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


library(reshape2)
library(reshape)

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Crowdsourcing Task Design Guideline"),
   
   sidebarLayout(
    sidebarPanel(
   numericInput(inputId = "workers", label = "No. of workers", 20, min = 10, max = NA, width = '100px'),
   numericInput(inputId = "tasks", label = "No. of tasks", 100, min = 10, max = NA, width = '100px'),
   numericInput(inputId = "tasksperworker", label = "No. of tasks per worker", 7, min = 7, max = NA, width = '100px'),
   numericInput(inputId = "hardtasks", label = "% of hard tasks", 0.2, min = NA, max = NA, width = '100px'),
   numericInput(inputId = "poorworkers", label = "% of poor workers", 0.8, min = NA, max = NA, width = '100px')
   ),   
      mainPanel(
         tableOutput(outputId = "datasets"),
         textOutput(outputId = "accuracies")
      )
   , fluid = TRUE ) 
)
# 
server <- function(input, output) {
 
   output$datasets <- renderTable({
     no.tasks <- input$tasks
     proportiontask <-60/input$tasks*no.tasks
     no.workers <- input$workers
     #k is no. of task done by each worker, k1, k2 odd no. such that k1, k2 are greater than no. of answers/categories
     k1 <- input$tasksperworker
     
     #worker effect
     #User specifies proportion of workers that will be poor - e.g. 10%
     proppoorworkers <- (no.workers*input$poorworkers)/100
     
     #Proprotion of worker getting an answer right has a center of say p around 0.20 of getting the right answer and the others have proportion of say 0.85 of getting it right.
     ppoor <- 0.2
     pgood <- 0.85
     
     #From the 20 workers, identify which workers are poor and which workers are good
     poorworker <- sample(1:no.workers, proppoorworkers)
     goodworker <- setdiff(1:no.workers, poorworker)
     
     #task effect
     #User specifies proportion of tasks that will be hard - e.g. 10%
     phardt <- (no.tasks*input$hardtasks)/100
     
     #Proprotion of worker getting an answer right for the hard tasks
     phard <- 0.2
     peasy <- 0.8
     
     #From the 1000 tasks, identify which tasks are hard and which tasks are easy
     hardtasks <- sample(1:no.tasks, phardt)
     easytasks <- setdiff(1:no.tasks, hardtasks)
     
     #baseline/truth
     answers <- c("liver", "blood", "lung", "brain", "heart")
     truth <- sample(answers, no.tasks, replace = TRUE, prob = c(0.2, 0.2, 0.2, 0.2, 0.2))
     
     #assign tasks to workers
     assignmentMatrix <- replicate(no.workers,sample(proportiontask, k1, replace=TRUE))
     
     #transpose assignmentMatrix
     #library(reshape)
     assignEach <- melt.matrix(assignmentMatrix)
     assignEach1 <- subset(assignEach, select = c(X2, value))
     
     #generate dataset of worker id, task id and truth
     dataSet <- cbind.data.frame("workerID" = assignEach1[,1], "taskID" = assignEach1[,2], "truth" = truth[assignEach1[,2]])
     #For each combination of poor/good workers and hard/easy tasks, assign the probability of the worker getting the answer right
     probs <- 0.02
     temp <- vector("character", length(dataSet$taskID))
     for(i in 1:length(dataSet$taskID)){
       if(dataSet$workerID[i] %in% poorworker[i] && dataSet$taskID[i] %in% hardtasks  && (match(dataSet$truth[i], answers) == TRUE))
       {probs <- ppoor * phard}
       else if(dataSet$workerID[i] %in% goodworker[i] && dataSet$taskID[i] %in% hardtasks  && (match(dataSet$truth[i], answers) == TRUE))
       {probs <- pgood * phard}
       else if(dataSet$workerID[i] %in% poorworker[i] && dataSet$taskID[i] %in% easytasks  && (match(dataSet$truth[i], answers) == TRUE))
       {probs <- ppoor * peasy}
       else if(dataSet$workerID[i] %in% goodworker[i] && dataSet$taskID[i] %in% easytasks  && (match(dataSet$truth[i], answers) == TRUE))
       {probs <- pgood * peasy} 
       probabilityanswers <- c(probs, 1-probs/4, 1-probs/4, 1-probs/4, 1-probs/4)
       temp[i] <- sample(answers, 1, prob = probabilityanswers, no.workers)
     }
     
     #for each answer value in dataSet, set the probability of the worker answer to be high
     #probassign <-  function(x){
     #  probs <- c(0.02, 0.02, 0.02, 0.02, 0.02)      
     #  probs[match(x, answers)] <- 0.9
     
     #  temp <- sample(answers, 1, prob = probs, no.workers)
     #  return(temp)    
     #}  
     
     #df3 <- lapply(dataSet$truth, probassign)
     
     #combine the worker answer in the dataSet
     combinedData <- cbind.data.frame("workerID" = dataSet$workerID, "taskID" = dataSet$taskID, "truth" = dataSet$truth, "workerAnswer" = temp)
     
     
     #pworker - no. of time worker differs / total no. of pairs
     matchesW <- vector("numeric", length = no.workers) 
     PW <- vector("numeric", length = no.workers) 
     for(i in 1:no.workers){
       workerans <- combinedData[combinedData$workerID == i,]$workerAnswer
       truth <- combinedData[combinedData$taskID == i,]$truth
       matchesW <- combn(c(workerans,truth), 2, FUN=function(x) x[1]==x[2], simplify = FALSE)
       PW[i] <- mean(unlist(matchesW))/length(workerans)
     }  
     
     #ptasks - no. of pairs that differ / total no. of pairs
     matchesT <- vector("numeric", length = proportiontask)
     eachtask <- vector("numeric", length = proportiontask)
     PT <- vector("numeric", length = proportiontask)
     for(i in 1:proportiontask){
       workerans1 <- combinedData[combinedData$taskID == i,]$workerAnswer
       truth1 <- combinedData[combinedData$taskID == i,]$truth
       ifelse(length(workerans1)>1, (matchesT <- combn(c(workerans1,truth1), 2, FUN=function(x) x[1]==x[2], simplify = FALSE)), NA)
       PT[i] <- mean(unlist(matchesT))/length(workerans1)
     }  
     #tasks not assigned
     unassignedtasks <- rep(1:no.tasks)[!(rep(1:no.tasks) %in% unique(assignEach1$value))]
     
     #workers with PW < 0.03
     stage2worker <- which(PW < 0.03)
     
     #tasks with PT > 0.8 | PT < 0.5
     hardtasks <- which(PT > 0.2)
     
     #stage2tasks <- unassigned tasks + hard tasks
     stage2tasks <- c(unique(unassignedtasks,hardtasks))
     
     #k2 - stage2workers/untouched tasks
     #if hard tasks, k2 + 1 = (7+8=15)
     #if untouched, k2 = 7
     k2 <- 7
     ifelse(stage2tasks %in% hardtasks, k2a <- k2 + (k2 + 1), k2 <- 7)
     
     #if hard task, assign those workers which have not been assigned that task before
     #Unassigned Tasks assignment
     assignUnassignedTasks <- replicate(length(stage2worker),sample(unassignedtasks, k2, replace=TRUE))
     assignEachUnassignedTask <- melt.matrix(assignUnassignedTasks)
     assignEachUnassignedTask1 <- subset(assignEachUnassignedTask, select = c(X2, value))
     
     #Hard Tasks assignment: hardtasks, k2a
     #for each task, check which good worker has been assigned that task before
     workerassigned <- vector("list", length = length(stage2worker))
     for(i in 1:length(stage2tasks))
     {
       workerassigned[[i]] <- stage2worker[which(stage2worker %in% dataSet[dataSet$taskID == i,]$workerID)]
     }
     
     assignHardTasks <- replicate(length(workerassigned),sample(hardtasks, k2, replace=TRUE))
     assignEachHardTask <- melt.matrix(assignHardTasks)
     assignEachHardTask1 <- subset(assignEachHardTask, select = c(X2, value))
     
     dataSet1 <- cbind.data.frame("workerID" = assignEachUnassignedTask1[,1], "taskID" = assignEachUnassignedTask1[,2], "truth" = dataSet$truth[assignEachUnassignedTask1[,2]])
     dataSet2 <- cbind.data.frame("workerID" = assignEachHardTask1[,1], "taskID" = assignEachHardTask1[,2], "truth" = dataSet$truth[assignEachHardTask1[,2]])
     
     probs1 <- 0.02
     temp1 <- vector("character", length(dataSet1$taskID))
     for(i in 1:length(dataSet1$taskID)){
       if(dataSet1$workerID[i] %in% poorworker[i] && dataSet1$taskID[i] %in% hardtasks  && (match(dataSet1$truth[i], answers) == TRUE))
       {probs1 <- ppoor * phard}
       else if(dataSet1$workerID[i] %in% goodworker[i] && dataSet1$taskID[i] %in% hardtasks  && (match(dataSet1$truth[i], answers) == TRUE))
       {probs1 <- pgood * phard}
       else if(dataSet1$workerID[i] %in% poorworker[i] && dataSet1$taskID[i] %in% easytasks  && (match(dataSet1$truth[i], answers) == TRUE))
       {probs1 <- ppoor * peasy}
       else if(dataSet1$workerID[i] %in% goodworker[i] && dataSet1$taskID[i] %in% easytasks  && (match(dataSet1$truth[i], answers) == TRUE))
       {probs1 <- pgood * peasy} 
       probabilityanswers1 <- c(probs1, 1-probs1/4, 1-probs1/4, 1-probs1/4, 1-probs1/4)
       temp1[i] <- sample(answers, 1, prob = probabilityanswers1, no.workers)
     }
     
     probs2 <- 0.02
     temp2 <- vector("character", length(dataSet2$taskID))
     for(i in 1:length(dataSet2$taskID)){
       if(dataSet2$workerID[i] %in% poorworker[i] && dataSet2$taskID[i] %in% hardtasks && (match(dataSet2$truth[i], answers) == TRUE))
       {probs2 <- ppoor * phard}
       else if(dataSet2$workerID[i] %in% goodworker[i] && dataSet2$taskID[i] %in% hardtasks && (match(dataSet2$truth[i], answers) == TRUE))
       {probs2 <- pgood * phard}
       else if(dataSet2$workerID[i] %in% poorworker[i] && dataSet2$taskID[i] %in% easytasks && (match(dataSet2$truth[i], answers) == TRUE))
       {probs2 <- ppoor * peasy}
       else if(dataSet2$workerID[i] %in% goodworker[i] && dataSet2$taskID[i] %in% easytasks && (match(dataSet2$truth[i], answers) == TRUE))
       {probs2 <- pgood * peasy} 
       probabilityanswers2 <- c(probs2, 1-probs2/4, 1-probs2/4, 1-probs2/4, 1-probs2/4)
       temp2[i] <- sample(answers, 1, prob = probabilityanswers2, no.workers)
     }
     
     #combine datasets to get truth and answer for *all* tasks
     #combinedData1 <- cbind.data.frame("workerID" = assignEachUnassignedTask1[,1], "taskID" = assignEachUnassignedTask1[,2], "truth" = dataSet1$truth, "workerAnswer" = as.character(df4))
     combinedData1 <- cbind.data.frame("workerID" = assignEachUnassignedTask1[,1], "taskID" = assignEachUnassignedTask1[,2], "truth" = dataSet1$truth, "workerAnswer" = temp1)
     combinedData2 <- cbind.data.frame("workerID" = assignEachHardTask1[,1], "taskID" = assignEachHardTask1[,2], "truth" = dataSet2$truth, "workerAnswer" = temp2)
     
     combinedData3 <- rbind.data.frame(combinedData, combinedData1, combinedData2)
     
   }) 
}
  
# Run the application 
shinyApp(ui = ui, server = server)