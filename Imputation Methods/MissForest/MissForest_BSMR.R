library(stringr)
library(missForest)
library(doParallel)
library(caret)

# Function to read data using data.table
r.table <- function(in_f,
                    header = TRUE,
                    row.names = NULL,
                    sep = "auto",
                    check.names = FALSE,
                    verbose = FALSE,
                    ...) {
  require(data.table)
  
  dat <- fread(
    in_f,
    header = header,
    sep = sep,
    check.names = check.names,
    verbose = verbose,
    ...
  )
  
  dat <- data.frame(dat, row.names = row.names, check.names = check.names)
  print(dim(dat))
  return(dat)
}

imputation_times <- numeric(10)  # Vector to store imputation times

for (i in 1:10) {
  file_name <- paste("Projects/MIDAS/BlockwiseSurveySpecificMissingDataframe_", i, ".csv", sep = "")
  mergedAllSampleCompleteMissing <- read.csv(file_name)
  mergedAllSampleComplete <- read.csv("Projects/MergedAllSampleFinal.csv")
  
  print(i)
  registerDoParallel(cores = 10)
  start <- Sys.time()
  mergedAllSampleComplete.imp <- missForest(as.data.frame(mergedAllSampleCompleteMissing), xtrue = mergedAllSampleComplete, verbose = TRUE, parallelize = "variables", ntree = 50, maxiter = 15)
  end <- Sys.time()
  print("")
  
  # Calculate the time difference in seconds and store it
  imputation_times[i] <- as.numeric(difftime(end, start, units = "secs"))
  
  mergedAllSampleCompleteImputed <- mergedAllSampleComplete.imp$ximp
  mergedAllSampleCompleteImputed <- mergedAllSampleCompleteImputed[complete.cases(mergedAllSampleCompleteImputed),]
  
  stopImplicitCluster()
  file_name_new <- paste("Projects/Missforest/BlockwiseSurveySpecificImputedDataframe_", i, ".csv", sep = "")
  write.csv(mergedAllSampleCompleteImputed, file = file_name_new, row.names = FALSE)
}

# Create a data frame with iteration numbers and their corresponding imputation times
results <- data.frame(Iteration = 1:10, Imputation_Time_Seconds = imputation_times)

# Save the data frame as a CSV file
write.csv(results, file = "Projects/Missforest/BlockwiseSurveySpecificTimes.csv", row.names = FALSE)
