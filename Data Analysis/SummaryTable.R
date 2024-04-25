library(missForest)
library(doParallel)
library(plyr)
library(dplyr)
library(caret)
library(tableone)

mergedAllSample = read.csv("Project/Data/MergedAllSamplePreprocessed.csv")
mergedAllSample <- mergedAllSample[mergedAllSample$ASD == TRUE, ]

mergedAllSample$SubjectSPID <- NULL

percent_missing <- rowSums(is.na(mergedAllSample)) / ncol(mergedAllSample) 
mergedAllSample$Percent_missing <- percent_missing

mergedAllSample <- mergedAllSample[mergedAllSample$ASD == "TRUE",]

mydata <- mergedAllSample[, c("Race", "Sex", "Individual_AgeAtRegistrationMonths", "Percent_missing")]

mydata$Percent_missing <- ifelse(mydata$Percent_missing < 0.2, "Below_20_Percent_Missing",
                                 ifelse(mydata$Percent_missing <= 0.8, "Between_20_and_80_Percent_Missing", "Above_80_Percent_Missing"))
colnames(mydata)[3] <- "Age"


transform_age <- function(x) {
  if (x < 24) {
    return("Below_Age_2")
  } else if (x >= 24 & x < 60) {
    return("Between_Age_2_and_5")
  } else if (x >= 60 & x < 132) {
    return("Between_Age_5_and_11")
  } else if (x >= 132 & x < 216) {
    return("Between_Age_11_and_18")
  } else {
    return("Above_Age_18")
  }
}

mydata <- mydata[complete.cases(mydata), ]
mydata$Age <- sapply(mydata$Age, transform_age)

factorVars <- c("Race", "Sex", "Age")
strataVar <- "Percent_missing"

mytable <- CreateTableOne(vars = factorVars, strata = strataVar, data = mydata)
tab3Mat <- print(mytable, nonnormal = biomarkers, exact = "stage", quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
write.csv(tab3Mat, file = "SummaryTable.csv")
