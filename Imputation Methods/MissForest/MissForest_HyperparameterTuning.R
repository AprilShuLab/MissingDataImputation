library(missForest)
library(doParallel)
library(dplyr)

tuning_evaluation = data.frame(matrix(ncol = 5, nrow = 0))
tuning_evaluation_cols = c("Ntree", "Maxiter", "NRMSE", "Time")
colnames(tuning_evaluation) <- tuning_evaluation_cols

mergedAllSampleComplete <- read.csv("Projects/MergedAllSampleCompleteOneHot.csv")
mergedAllSampleComplete <- data.frame(lapply(mergedAllSampleComplete, as.numeric))
mergedAllSampleCompleteMissing <- prodNA(mergedAllSampleComplete, noNA = 0.2)

for (ntree in c(5, 10, 20, 30, 40, 50, 75, 100)) {
  for (maxiter in c(5,10,15)) {
    ntree_string = paste("ntree", ntree)
    maxiter_string = paste("maxiter", maxiter)
    print(ntree_string)
    print(maxiter_string)
    registerDoParallel(cores=10)
    start = Sys.time()
    mergedAllSampleComplete.imp <- missForest(as.data.frame(mergedAllSampleCompleteMissing), xtrue = mergedAllSampleComplete, verbose = TRUE, parallelize = "variables", ntree = ntree, maxiter = maxiter)
    end = Sys.time()
    stopImplicitCluster()
    err.imp <- mixError(mergedAllSampleComplete.imp$ximp, mergedAllSampleCompleteMissing, mergedAllSampleComplete)
    print(err.imp[1])
    print(err.imp[2])
    total_time=as.character(end-start)
    print(end-start)
    print("")
    new_row <- data.frame(Ntree=ntree, Maxiter=maxiter, NRMSE=err.imp[1], Time=total_time)
    tuning_evaluation <- rbind(tuning_evaluation, new_row)
  }
}

save(tuning_evaluation,file="Projects/Evaluation_MissforestTuning.rds")
