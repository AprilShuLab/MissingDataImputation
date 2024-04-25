library(mice)
library(doParallel)


output_file = "Projects/Mice/New/BlockwiseTimes.txt"
file_conn <- file(output_file, "a")

for (i in 1:10) {
  file_name <- paste("Projects/MIDAS/BlockwiseSurveySpecificMissingDataframe_", i, ".csv", sep = "")
  mergedAllSampleCompleteMissing <- read.csv(file_name)
  columns_to_exclude <- c("SCQ_SummaryScore", "RBSr_OverallScore", "DCDQ_Total")
  mergedAllSampleCompleteMissing <- mergedAllSampleCompleteMissing[, !names(mergedAllSampleCompleteMissing) %in% columns_to_exclude]
  
  print(i)
  registerDoParallel(cores = 10)
  ptm <- proc.time()  # Measure start time
  
  imp <- mice(mergedAllSampleCompleteMissing, m = 5)
  
  elapsed_time <- proc.time() - ptm    # Measure end time
  
  writeLines(paste("Iteration", i, ": ", elapsed_time), file_conn)
  
  # Create an empty dataframe to store the averaged imputed values
  imputed_average <- NULL
  
  for (j in 1:5) {
    imputed_dataset <- complete(imp, j)
    
    # Store imputed datasets
    if (is.null(imputed_average)) {
      imputed_average <- imputed_dataset / 5  # Initialize with the first imputed dataset
    } else {
      imputed_average <- imputed_average + imputed_dataset / 5
    }
  }
  
  # Save the averaged imputed dataframe to a CSV file
  file_name_new <- paste("Projects/Mice/New/BlockwiseSurveySpecificAveragedImputedDataframe_", i, ".csv", sep = "")
  write.csv(imputed_average, file = file_name_new, row.names = FALSE)
}

close(file_conn)
