# Benchmarking Machine Learning Missing Data Imputation Methods in Large-Scale Mental Health Survey Databases
We investigated the missing data patterns in Simons Powering Autism Research (SPARK), a large-scale autism cohort (n=117,099) consisting of social functioning and behavioral surveys on participants with Autism Spectrum Disorder (ASD). In a subset of 15,196 ASD participants with complete data, we simulated three types of missingness patterns: Missing Completely at Random (MCAR) where missing values were randomly distributed across surveys, Missing Not at Random (MNAR) with Survey-Specific Missing Rates (SMR) where each survey has a unique missingness rate that corresponds to its overall missingness rate in the full dataset, and MNAR with Blockwise Survey-Specific Missing Rates (BSMR) that simulates when participants skip all questions in entire surveys. We evaluated the imputation performance on the overall dataset and on specific summary scores of four popular statistical and machine learning imputation methods - Multiple Imputation by Chained Equations (MICE), K-Nearest Neighbors (KNN), MissForest, and Multiple Imputation with Denoising Autoencoders (MIDAS). 

## Simulation Scenarios
### 1. Missing Completely at Random (MCAR)
The first missing data simulation scenario, referred to as MCAR, introduces missingness completely at random by converting a specific percentage of the preprocessed complete dataset to missing. To observe the imputation performance as the missing rate gradually increases, MCAR was implemented with missing rates from 10% to 90% in 10% intervals for all variables in the dataset.    

### 2. Missing Not at Random (MNAR): Survey-Specific Missing Rate
The second missing data simulation scenario is SMR, in which the proportion of missing values in each column is dependent on the survey type that it belongs to. SMR is tailored to mirror the missing rates in the full SPARK dataset by reusing the same proportions of missing values for each survey (Table 1).

### 3. Missing Not at Random (MNAR): Blockwise Missingness with Survey-Specific Missing Rate
The last missing data simulation scenario, referred to as BSMR, incorporates blockwise missingness with survey-specific missing rates. Instead of randomly selecting a specific portion of each column to be converted to missing as in SMR, a proportion of participants are randomly selected to have completely missing values for all surveys of a particular survey type. In other words, every column of a specific survey type contains the same missing rows. This resembles real data more closely when subjects skip the entire survey.

## Machine Learning Models

For each missing data simulation scenario described in the previous section, multiple machine learning models were used to impute the missing values. The generated incomplete datasets were passed through the following imputation algorithms to compute the predicted values. A separate set of 10 datasets with 20% randomly selected missing values was used to conduct hyperparameter tuning on each of these models.

### 1. MICE
This study used the MICE [1] (version 3.16.0) package in R which employs a multiple imputation model. It uses a concept called Fully Conditional Specification, in which each incomplete variable is imputed by a different model. It generates multiple imputed datasets that are averaged to retrieve the final imputed data. Since MICE employs a regression-based approach, hyperparameter tuning was not performed.

## 2. KNN
KNNImputer is a method in Python’s Scikit-learn package [2] (version 0.22) and was used to study the KNN algorithm. KNNImputer predicts each sample’s missing values by using the average value from the closest data points in the training set. Hyperparameter tuning was used to select the optimal value for the number of nearest neighbors used during imputation.

### 3. MissForest
MissForest [3] (version 1.5) is an R package which uses a Random Forest approach to impute missing values, building multiple decision trees to make predictions using the other remaining features. By averaging several classification or regression trees, MissForest employs out-of-bag error estimates and can capture complex, non-linear relationships. Hyperparameter tuning was used to select the optimal values for the number of trees and the maximum number of iterations.

### 4. MIDAS
MIDASpy [4] (version 1.3.1) is a Python package that was used to study the MIDAS algorithm. It introduces additional missing values into a given dataset and restores these values using an unsupervised neural network called a denoising autoencoder. Then, the resulting model is used to predict the values of the original missing data. Similar to MICE, MIDASpy generates multiple imputed datasets that are averaged to retrieve the final imputed data. Hyperparameter tuning was used to select the optimal values for the input drop, layer structure, and number of epochs.

# References

[1] van Buuren, S. and K. Groothuis-Oudshoorn, mice: Multivariate Imputation by Chained Equations in R. Journal of Statistical Software, 2011. 45(3): p. 1 - 67.

[2] Pedregosa, F., et al., Scikit-learn: Machine learning in Python. the Journal of machine Learning research, 2011. 12: p. 2825-2830.

[3] Stekhoven, D.J. and P. Bühlmann, MissForest—non-parametric missing value imputation for mixed-type data. Bioinformatics, 2011. 28(1): p. 112-118.

[4] Lall, R. and T. Robinson, Efficient Multiple Imputation for Diverse Data in Python and R: MIDASpy and rMIDAS. Journal of Statistical Software, 2023. 107(9): p. 1 - 38.