import pandas as pd
from sklearn.impute import KNNImputer
import time

imputation_times = [] 

for i in range(1, 11):
    print(i)
    missing_df_name = "Projects/MIDAS/BlockwiseSurveySpecificMissingDataframe_" + str(i) + ".csv"
    missing_df = pd.read_csv(missing_df_name)

    imputer = KNNImputer(n_neighbors=35)
    
    start_time = time.time()
    imputed_data = imputer.fit_transform(missing_df)
    end_time = time.time()
    
    imputation_time = end_time - start_time
    imputation_times.append(imputation_time)

    df_imputed = pd.DataFrame(imputed_data, columns=missing_df.columns)

    filename = f'Projects/KNN/BlockwiseSurveySpecificImputedDataframe_{i}.csv'
    df_imputed.to_csv(filename, index=False)

times_df = pd.DataFrame({'Imputation_Time': imputation_times})

times_df.to_csv('Projects/KNN/BlockwiseSurveySpecificTimes.csv', index=False)
