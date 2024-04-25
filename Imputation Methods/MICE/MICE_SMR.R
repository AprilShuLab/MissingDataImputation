library(mice)
library(doParallel)

for (i in 1:10) {
  file_name <- paste("Projects/MIDAS/SurveySpecificMissingDataframe_", i, ".csv", sep = "")
  mergedAllSampleCompleteMissing <- read.csv(file_name)
  columns_to_exclude <- c("SCQ_SummaryScore", "RBSr_OverallScore", "DCDQ_Total")
  mergedAllSampleCompleteMissing <- mergedAllSampleCompleteMissing[, !names(mergedAllSampleCompleteMissing) %in% columns_to_exclude]
  
  print(i)
  registerDoParallel(cores = 10)
  start <- Sys.time()
  imp <- mice(mergedAllSampleCompleteMissing, m = 5)
  end <- Sys.time()
  print("")
  
  # Create an empty dataframe to store the imputed values
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
  file_name_new <- paste("Projects/Mice/New/SurveySpecificAveragedImputedDataframe_", i, ".csv", sep = "")
  write.csv(imputed_average, file = file_name_new, row.names = FALSE)
}
