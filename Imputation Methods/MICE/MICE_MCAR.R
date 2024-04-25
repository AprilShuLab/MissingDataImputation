library(mice)
library(doParallel)

for (percent in c(10, 20, 30, 40, 50, 60, 70, 80, 90)){
  for (i in c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)){
    file_name <- paste("Projects/MIDAS/VaryingPercentage/VaryingPercentageMissingDataframe_", percent, "_", i, ".csv", sep = "")
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
    file_name_new <- paste("Mice/VaryingPercentage/VaryingPercentageImputedDataframe_", percent, "_", i, ".csv", sep = "")
    write.csv(imputed_average, file = file_name_new, row.names = FALSE)
  }
}  
  
