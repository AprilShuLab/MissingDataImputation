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

mergedAllSampleComplete = pd.read_csv('Projects/MergedAllSampleFinal.csv')


for percent in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]:
    percentage = int(percent*100)
    for i in range(5,6):
        nan_mask = np.random.rand(*mergedAllSampleComplete.shape) < (percent)
        mergedAllSampleCompleteMissing = mergedAllSampleComplete.copy()
        mergedAllSampleCompleteMissing[nan_mask] = np.nan
    
        file_name = f"Projects/MIDAS/VaryingPercentage/VaryingPercentageMissingDataframe_{percentage}_{i}.csv"
        mergedAllSampleCompleteMissing.to_csv(file_name, index=False)
        
        mergedAllSampleCompleteImputed = complete_imputation(mergedAllSampleCompleteMissing)
        
        file_name = f"Projects/MIDAS/VaryingPercentage/VaryingPercentageImputedDataframe_{percentage}_{i}.csv"
        mergedAllSampleCompleteImputed.to_csv(file_name, index=False)
            
