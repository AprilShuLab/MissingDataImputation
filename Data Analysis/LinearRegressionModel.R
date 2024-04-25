library(missForest)
library(doParallel)
library(plyr)
library(dplyr)
library(caret)

mergedAllSample = read.csv("NewMissforestEvaluation/MergedAllSamplePreprocessed.csv")
mergedAllSample$SubjectSPID <- NULL

percent_missing <- rowSums(is.na(mergedAllSample)) / ncol(mergedAllSample) 
mergedAllSample$Percent_missing <- percent_missing

mergedAllSample <- mergedAllSample[mergedAllSample$ASD == "TRUE",]

mergedAllSample <- mergedAllSample[, c("Individual_AgeAtRegistrationMonths", "Race", "Sex", "Percent_missing")]
mergedAllSample <- mergedAllSample[complete.cases(mergedAllSample), ]


age_encoding <- (mergedAllSample$Individual_AgeAtRegistrationMonths - min(mergedAllSample$Individual_AgeAtRegistrationMonths, na.rm = TRUE)) / (max(mergedAllSample$Individual_AgeAtRegistrationMonths, na.rm = TRUE) - min(mergedAllSample$Individual_AgeAtRegistrationMonths, na.rm = TRUE))
age_squared_encoding = lapply(age_encoding, function(x) x^2)

features <- cbind(age_encoding, age_squared_encoding)

features$age_encoding <- as.numeric(unlist(features$age_encoding))
features$age_squared_encoding <- as.numeric(unlist(features$age_squared_encoding))

target <- mergedAllSample["Percent_missing"]
target <- target[[1]]

char_vars <- sapply(mergedAllSample, is.character)
mergedAllSample[char_vars] <- lapply(mergedAllSample[char_vars], factor)

mergedAllSample$Race <- relevel(mergedAllSample$Race, ref = "White")
model <- lm(target ~ unlist(age_encoding) + unlist(age_squared_encoding) + factor(mergedAllSample$Race) + factor(mergedAllSample$Sex))


summary(model)
varImp(model)





