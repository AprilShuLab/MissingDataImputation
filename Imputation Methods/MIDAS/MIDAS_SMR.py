import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.preprocessing import MinMaxScaler
import sys
import MIDASpy as md
import time

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


summary = []

mergedAllSampleComplete = pd.read_csv('Projects/MergedAllSampleFinal.csv')

for i in range(1, 11):
    mergedAllSampleCompleteMissing = mergedAllSampleComplete.copy()
    
    for col in mergedAllSampleCompleteMissing.columns:
        survey = col.split('_')[0]
        col_object = mergedAllSampleCompleteMissing[col]
        if survey == "Individual":
            num = round(len(col_object) * individual_missing)
        elif survey == "Medical":
            num = round(len(col_object) * medical_missing)
        elif survey == "DCDQ":
            num = round(len(col_object) * dcdq_missing)
        elif survey == "RBSr":
            num = round(len(col_object) * rbsr_missing)
        elif survey == "SCQ":
            num = round(len(col_object) * scq_missing)
        elif survey == "CBCL":
            num = round(len(col_object) * cbcl_missing)
        elif survey == "BackgroundAll" or survey == "BackgroundChild":
            num = round(len(col_object) * background_missing)
        else:
            num=0
        
        indices = np.random.choice(len(col_object), num, replace=False)
        mergedAllSampleCompleteMissing.loc[indices, col] = np.nan

    file_name = f"Projects/MIDAS/SurveySpecificMissingDataframe_{i}.csv"
    mergedAllSampleCompleteMissing.to_csv(file_name, index=False)
        
    mergedAllSampleCompleteImputed = complete_imputation(mergedAllSampleCompleteMissing)
    
    file_name = f"Projects/MIDAS/SurveySpecificImputedDataframe_{i}.csv"
    mergedAllSampleCompleteImputed.to_csv(file_name, index=False)
        
