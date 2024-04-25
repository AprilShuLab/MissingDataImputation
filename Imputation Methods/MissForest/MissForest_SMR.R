library(stringr)
library(missForest)
library(doParallel)
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

for (i in 1:10){
  file_name <- paste("Projects/MIDAS/SurveySpecificMissingDataframe_", i, ".csv", sep = "")
  mergedAllSampleCompleteMissing = read.csv(file_name)
  mergedAllSampleComplete = read.csv("Projects/MergedAllSampleFinal.csv")
  
  print(i)
  registerDoParallel(cores=10)
  start = Sys.time()
  mergedAllSampleComplete.imp <- missForest(as.data.frame(mergedAllSampleCompleteMissing), xtrue = mergedAllSampleComplete, verbose = TRUE, parallelize = "variables", ntree = 50, maxiter=15)
  end = Sys.time()
  print("")
  
  mergedAllSampleCompleteImputed = mergedAllSampleComplete.imp$ximp
  mergedAllSampleCompleteImputed = mergedAllSampleCompleteImputed[complete.cases(mergedAllSampleCompleteImputed),]

  stopImplicitCluster()
  file_name_new <- paste("Projects/Missforest/SurveySpecificImputedDataframe_", i, ".csv", sep = "")
  write.csv(mergedAllSampleCompleteImputed, file = file_name_new, row.names = FALSE)
}
