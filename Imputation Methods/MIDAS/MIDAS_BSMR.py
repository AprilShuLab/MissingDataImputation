import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.preprocessing import MinMaxScaler
import sys
import MIDASpy as md
import time
import random

def complete_imputation(data):

    imputer = md.Midas(layer_structure=[256,256,256], vae_layer=False, seed=89, input_drop=0.9)

    imputer.build_model(data)
    imputer.train_model(training_epochs=15)
    imputations = imputer.yield_samples(m=10)

    imputation_list = list(imputations)
    
    average_imputation = sum(imputation_list)/len(imputation_list)
        
    return average_imputation


individual_missing = 0.0
medical_missing = 0.3985237
dcdq_missing = 0.729172
rbsr_missing = 0.6384442
scq_missing = 0.5126153
cbcl_missing = 0.9170715
background_missing = 0.5930548


mergedAllSampleComplete = pd.read_csv('Projects/MergedAllSampleFinal.csv')

num_rows = len(mergedAllSampleComplete)


for i in range(1, 11):

    individual_indices = random.sample(range(num_rows), round(num_rows*individual_missing))
    medical_indices = random.sample(range(num_rows), round(num_rows*medical_missing))
    dcdq_indices = random.sample(range(num_rows), round(num_rows*dcdq_missing))
    rbsr_indices = random.sample(range(num_rows), round(num_rows*rbsr_missing))
    scq_indices = random.sample(range(num_rows), round(num_rows*scq_missing))
    cbcl_indices = random.sample(range(num_rows), round(num_rows*cbcl_missing))
    background_indices = random.sample(range(num_rows), round(num_rows*background_missing))
    mergedAllSampleCompleteMissing = mergedAllSampleComplete.copy()
    
    for col in mergedAllSampleCompleteMissing.columns:
        survey = col.split('_')[0]
        if survey == "Individual":
            mergedAllSampleCompleteMissing.loc[individual_indices, col] = np.nan
        elif survey == "Medical":
            mergedAllSampleCompleteMissing.loc[medical_indices, col] = np.nan
        elif survey == "DCDQ":
            mergedAllSampleCompleteMissing.loc[dcdq_indices, col] = np.nan
        elif survey == "RBSr":
            mergedAllSampleCompleteMissing.loc[rbsr_indices, col] = np.nan
        elif survey == "SCQ":
            mergedAllSampleCompleteMissing.loc[scq_indices, col] = np.nan
        elif survey == "CBCL":
            mergedAllSampleCompleteMissing.loc[cbcl_indices, col] = np.nan
        elif survey in ["BackgroundAll", "BackgroundChild"]:
            mergedAllSampleCompleteMissing.loc[background_indices, col] = np.nan


    file_name = f"Projects/MIDAS/BlockwiseSurveySpecificMissingDataframe_{i}.csv"
    mergedAllSampleCompleteMissing.to_csv(file_name, index=False)
    
    
    mergedAllSampleCompleteImputed = complete_imputation(mergedAllSampleCompleteMissing)

    file_name = f"Projects/MIDAS/BlockwiseSurveySpecificImputedDataframe_{i}.csv"
    mergedAllSampleCompleteImputed.to_csv(file_name, index=False)
        
