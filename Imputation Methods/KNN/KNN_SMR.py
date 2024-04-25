import pandas as pd
from sklearn.impute import KNNImputer
import numpy as np


for i in range(1,11):
    print(i)
    missing_df_name = "Projects/MIDAS/SurveySpecificMissingDataframe_" + str(i) + ".csv"
    missing_df = pd.read_csv(missing_df_name)

    imputer = KNNImputer(n_neighbors=35)
    imputed_data = imputer.fit_transform(missing_df)
    df_imputed = pd.DataFrame(imputed_data, columns=missing_df.columns)


    filename = f'Projects/KNN/SurveySpecificImputedDataframe_' + str(i) + ".csv"
    
    df_imputed.to_csv(filename, index=False)
