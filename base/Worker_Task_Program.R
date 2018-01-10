# THE FUNCTION
SimulateStages <- function(answers, no.tasks, prop_hardtasks, phard, peasy, no.workers,  prop_poorworkers, ppoor, pgood, trainingsize, s1tasksperworker = NULL, PWlessthan, PTgreaterthan, s2tasksperworker = NULL){
  out <- list()
  #############
  # Stage 0 - Data Creation
  #############
    stopifnot(phard + peasy == 1) 
    # OUTPUTS 
    stage0 <- list()   
    # CREATING TASK INFO
    task_ID <- 1:no.tasks
    hardtasks <- sample(task_ID, prop_hardtasks * no.tasks)
    task_Difficulty <- ifelse(task_ID %in% hardtasks, phard, peasy)
    task_Difficulty_fctr <- factor(task_Difficulty, labels = c("hard","easy"))
    task_True_Answer <- sample(answers, no.tasks, replace = TRUE) # truth
    stage0$tasks <- data.frame(task_ID, task_Difficulty, task_Difficulty_fctr, task_True_Answer)
    
    # CREATING ALL WORKERS
    worker_ID <- 1:no.workers
    poorworkers <- sample(worker_ID, prop_poorworkers * no.workers)
    worker_Ability <- ifelse(worker_ID %in% poorworkers, ppoor, pgood)
    worker_Ability_fctr <- factor(worker_Ability, labels = c("poor","good"))
    stage0$workers <- data.frame(worker_ID, worker_Ability, worker_Ability_fctr)
    out$stage0 <- stage0
  ###########
  # stage1
  # Purpose: to run a portion of the dataset and determine good workers and hard tasks 
  ###########
    stage1 <- list() # initialize list to save things
    trainingset <- sample(task_ID, no.tasks * trainingsize, replace = F) # sample 60% of all tasks
    stage1$tasks <- stage0$tasks[trainingset,] # subset those tasks
    stage1$workers <- stage0$workers # workers are the same (preset performance though?)
    # each worker gets random tasks from the group of all tasks
    # function for rounding up to the nearest odd number
    ceiling.odd <- function(x) ifelse(ceiling(x) %% 2 != 0, ceiling(x)+2, ceiling(x)+1)
    
    if(is.null(s1tasksperworker)){
      tasksperworker <- ceiling.odd(nrow(stage1$tasks)/nrow(stage1$workers)) # takes 3 and makes it 5
    } else {
      tasksperworker <- s1tasksperworker
    }
    
    # 20 workers, 5 tasks each = 100 task IDs being sampled from the 60 tasks
    # Because the sample function (with replicate = T) has a small probability of not using some of the trianing rows
    # We need a sampling function that includes all rows before adding duplicates
    # A sampling function that makes sure every value is accounted for before
    # This way every value is included at least once
    samplePLUS <- function(x, size){
      v <- c(sample(x, length(x), replace = FALSE, prob = NULL), # the full data 
             sample(x, size - length(x), replace = TRUE, prob = NULL)) # the remaining tasksperworker to fill
      sample(v, length(v), replace = FALSE) # and one final random sorting
    }
    # now every value will appear + enough values to fill remaining tasks
    
    taskrows <- samplePLUS(x = stage1$tasks$task_ID, size = no.workers * tasksperworker)
    
    # because nrow(stage1$tasks) is 60, if we try subsetting stage1$tasks[taskrows,] where taskrows can be 1:100, we will get NAs. Thus we use the original dataframe that has all tasks and their true answers to subset and get our desired results
    stage1$df <- data.frame(stage1$workers[rep(stage1$workers$worker_ID, each = tasksperworker),], 
                            stage0$tasks[taskrows,])
    stage1$df$prob_Correct <- with(stage1$df, worker_Ability * task_Difficulty)
    # SIMULATE WORKER'S ANSWER # using sample()'s probability argument
    answersim <- function(answers, no.tasks, TrueAnswer, probCorrect){
      # initialize a matrix where each row contians the probability vector we will use to sample
      truthProb <- matrix(NA, nrow = no.tasks, ncol = length(answers), dimnames = list(1:no.tasks, answers))
      TrueAnswerCols <- NA
      for(i in 1:no.tasks){
        # put the prob correct in the correct column for each worker's row's task.
        TrueAnswerCols <- which(answers %in% TrueAnswer[i])
        truthProb[i, TrueAnswerCols] <- probCorrect[i]
        # fill in all other columns with the evenly split remaining probability
        truthProb[i, -TrueAnswerCols] <- (1 - probCorrect[i]) / (length(answers) - 1)
      }
      as.factor(apply(truthProb, 1, function(x) sample(answers, 1, replace = F, prob = x)))
    }
    
    stage1$df$worker_Answer <- answersim(answers = answers, 
                                         no.tasks = nrow(stage0$task[taskrows,]), 
                                         TrueAnswer = stage1$df$task_True_Answer,
                                         probCorrect = stage1$df$prob_Correct)
    
    # now calculate performance metrics... A measure of bad performance
    # number of times differs from truth/ total
    PW <- sapply(split(stage1$df, stage1$df$worker_ID),
                 function(x) sum(1*(x$worker_Answer != x$task_True_Answer))/nrow(x)) 
    PT <- sapply(split(stage1$df, stage1$df$task_ID), 
                 function(x) sum(1*(x$worker_Answer != x$task_True_Answer))/nrow(x))
    out$stage1 <- stage1
    out$PW <- PW
    out$PT <- PT
  ##############
  # Stage 2
  # Use the performance metrics to assign tasks
  ##############
  stage2 <- list()
  # with the performance metrics, 0 is good, 1 is bad
  # Choose only good workers
  #** there is a  high potential for very few good workers who get many many tasks... 
  chosen_good <- as.numeric(names(which(PW < PWlessthan)))
  stage2$workers <- stage0$workers[chosen_good,]
  # Get the Hard tasts + unassigned tasks from initial assignment.
  chosen_hard <- as.numeric(names(which(PT > PTgreaterthan)))
  stage2$tasks <- stage0$tasks[c(chosen_hard, # hard rows from stage1
                                 setdiff(task_ID, trainingset)),] # 40 not used from stage0
  
  #Now assign the good workers to the unassigned tasks as before
  unassigned_tasks <- stage0$tasks[-trainingset,]
  if(is.null(s2tasksperworker)){
    tasksperworker2 <- ceiling.odd(nrow(unassigned_tasks)/length(chosen_good))
  } else {
    tasksperworker2 <- s2tasksperworker
  }
  taskrows2 <- samplePLUS(unassigned_tasks$task_ID, 
                          length(chosen_good) * tasksperworker2)
  stage2$df <- cbind(stage0$workers[rep(chosen_good, each = tasksperworker2),], 
                                stage0$tasks[taskrows2,])
  stage2$df$prob_Correct <- with(stage2$df, worker_Ability * task_Difficulty)
  stage2$df$worker_Answer <- answersim(answers = answers, 
                                       no.tasks = nrow(stage2$df), 
                                       TrueAnswer = stage2$df$task_True_Answer, 
                                       probCorrect = stage2$df$prob_Correct)
  PW2 <- sapply(split(stage2$df, 
                     stage2$df$worker_ID),
               function(x) sum(1*(x$worker_Answer != x$task_True_Answer))/nrow(x)) 
  PT2 <- sapply(split(stage2$df, 
                     stage2$df$task_ID), 
               function(x) sum(1*(x$worker_Answer != x$task_True_Answer))/nrow(x))
  out$stage2 <- stage2
  out$PW2 <- PW2
  out$PT2 <- PT2
  ### Putting them together
  final <- list()
  final$df <- rbind(stage1$df,stage2$df)
  final$task_accuracy <- sapply(split(final$df, final$df$task_ID), 
               function(x) sum(1*(x$worker_Answer == x$task_True_Answer))/nrow(x))
  out$final <- final
  # some extra saving so we can use the print custom method below :D
  out$answers <- answers
  out$tasksperworker <- tasksperworker
  out$tasksperworker2 <- tasksperworker2
  out$chosen_hard <- chosen_hard
  out$PWlessthan <- PWlessthan
  out$PTgreaterthan <- PTgreaterthan
  out$trainingsize <- trainingsize
  class(out) <- c("custom","list")
  return(out)
}

# This is a new method for the print function that helps make the output of your function something you can understand (maybe). Ignore the code and just go the bottom! 
print.custom <- function(out){
  with(out,{
    cat("$stage0 __________________________________________",
        "\n\tWorkers:   \t", nrow(stage0$workers),
        "\n\tTasks:   \t", nrow(stage0$tasks),
        "\n\tAnswers:   \t", length(answers), "\t(",answers,")\n\n")
    WW <- nrow(stage1$workers); TT <- nrow(stage1$tasks)
    cat("$stage1 __________________________________________",
        "\n\tWorkers:   \t", WW,
        "\n\tTasks:   \t", TT,
        "\n\tTasks per Wrkr:\t", tasksperworker, "\t( Tasks / Workers =",TT/WW,"rounded up to nearest odd )",
        "\n\tDateframe Rows:\t", nrow(stage1$df), "\t( Tasks +",WW*(tasksperworker)-TT," random overlap )",
        "\n\tCounts of Worker Performance ( 0 = no error, 1 = no completed tasks )")
    print(table(round(PW,2)))
    cat("\tCounts of Task Performance ( 0 = no error, 1 = no completed tasks )")
    print(table(round(PT,2)))
    cat("\n")
    WW2 <- nrow(stage2$workers) ; TT2 <- nrow(stage2$tasks)
    cat("$stage2 __________________________________________",
        "\n\tWorkers:   \t", WW2,"\t ( Varies based on Stage 1 PW <",PWlessthan,")",
        "\n\tTasks:   \t", TT2,
        "\n\t\tChosen Hard Tasks:   \t",length(chosen_hard),"\t ( Varies based on stage 1 PT >",PTgreaterthan,")",
        "\n\t\tExcluded from Stage 1:\t",(1-trainingsize)*nrow(stage0$tasks),
        "\n\tTasks per Wrkr:\t", tasksperworker2, "\t( Tasks / Workers =",TT2/WW2,"rounded up to nearest odd )",
        "\n\tDateframe Rows:\t", nrow(stage2$df), "\t( Tasks +",WW2*(tasksperworker2)-TT2," random overlap )",
        "\n\tCounts of Worker Performance ( 0 = no error, 1 = no completed tasks )")
    print(table(round(PW2,2)))
    cat("\tCounts of Task Performance ( 0 = no error, 1 = no completed tasks )")
    print(table(round(PT2,2)))
    cat("\n")
    cat("$final __________________________________________",
        "\n\tWorkers:   \tAll", WW,
        "\n\tTasks:   \tAll", TT,
        "\n\tTasks per Wrkr:")
    print(table(final$df$worker_ID))
    cat("\tDateframe Rows:\t", nrow(final$df), "\t( Stage 1 + Stage 2)",
        "\n\t\tFrom df Stage 1:\t",nrow(stage1$df),
        "\n\t\tFrom df Stage 2:\t",nrow(stage2$df),
        "\n\tTotal Task Accuracy (0 = Incomplete, 1 = complete )")
    print(table(round(final$task_accuracy,2)))  
  })
}

object.size(SimulateStages)

answers <-  c("liver", "blood", "lung", "brain", "heart")
length(answers)  # 5 -> 7 


tryme <- SimulateStages(# PARAMETERS
  answers = c("liver", "blood", "lung", "brain", "heart"),
  # generating tasks
  no.tasks = 100,
  prop_hardtasks = 1/10,
  phard <- .2,
  peasy <- .8,
  # generating workers
  no.workers = 20,
  prop_poorworkers = 1/2, 
  ppoor = .77,
  pgood = .99,
  # stage 1
  trainingsize = .6, 
  s1tasksperworker = 25,
  # stage 2
  PWlessthan = 0.4,
  PTgreaterthan = 0.8
  #s2tasksperworker
)

tryme$final$df # default sorted by worker ID
tryme$final$df[order(tryme$final$df$task_ID),] # sorted by task ID

tryme
distr <- do.call(rbind,results)
colMeans(distr)
bp <- boxplot(distr, horizontal = T)

#tryme <- SimulateStages(...)
#tryme$final$df # sorted by worker ID
#tryme$final$df[order(tryme$final$df$task_ID),] # sorted by task ID       

#### Stage1
Stage1_task_accuracy <- sapply(split(tryme$stage1$df, tryme$stage1$df$task_ID), 
                               function(x) sum(1*(x$worker_Answer == x$task_True_Answer))/nrow(x))
table(round(Stage1_task_accuracy,2))
#### Stage2
Stage2_task_accuracy <- sapply(split(tryme$stage2$df, tryme$stage2$df$task_ID), 
                               function(x) sum(1*(x$worker_Answer == x$task_True_Answer))/nrow(x))
table(round(Stage2_task_accuracy,2))

# trim down the big function output
df <- tryme$final$df[,c("worker_ID","task_ID","task_True_Answer","worker_Answer")]
# add a column in there with a TRUE/FALSE if correct
df <- cbind.data.frame(df, correct = (df$task_True_Answer == df$worker_Answer))
# list of each task with number of workers and percent correct?
details <- lapply(split(df, df$task_ID), function(x) {
  cbind.data.frame(num_of_workers = length(unique(x[,"worker_ID"])),
                   percent_correct = sum(x[,"correct"])/nrow(x))
})
details # in list format
details <- do.call(rbind.data.frame, details) # in data.frame format
details
plot(details)
