library(missForest)
library(doParallel)
library(plyr)
library(dplyr)
library(caret)

r.table = function (in_f,
                    header = T,
                    row.names = NULL,
                    sep = "auto",
                    check.names = F,
                    verbose = F,
                    ...)
  #use data.table to read large file
  #tab delimited
{
  require(data.table)
  
  dat = fread(
    in_f,
    header = header,
    sep = sep,
    check.names = check.names,
    verbose = verbose,
    ...
  )
  
  dat = data.frame(dat, row.names = row.names, check.names = check.names)
  print(dim(dat))
  return (dat)
  
}

for (percentage in c(10, 20, 30, 40, 50, 60, 70, 80, 90)){
  for (i in 1:10){
    file_name <- paste("Projects/MIDAS/VaryingPercentage/VaryingPercentageMissingDataframe_", percentage, "_", i, ".csv", sep = "")
    mergedAllSampleCompleteMissing = read.csv(file_name)
    mergedAllSampleComplete = read.csv("Projects/MergedAllSampleFinal.csv")
    
    registerDoParallel(cores=10)
    mergedAllSampleComplete.imp <- missForest(as.data.frame(mergedAllSampleCompleteMissing), xtrue = mergedAllSampleComplete, verbose = TRUE, ntree=50, maxiter=15, parallelize = "variables")
    stopImplicitCluster()
    
    mergedAllSampleCompleteImputed = mergedAllSampleComplete.imp$ximp
    mergedAllSampleCompleteImputed = mergedAllSampleCompleteImputed[complete.cases(mergedAllSampleCompleteImputed),]
    

    file_name_new <- paste("Projects/Missforest/VaryingPercentage/VaryingPercentageImputedDataframe_", percentage, "_", i, ".csv", sep = "")
    write.csv(mergedAllSampleCompleteImputed, file = file_name_new, row.names = FALSE)
    
  }
}
  
