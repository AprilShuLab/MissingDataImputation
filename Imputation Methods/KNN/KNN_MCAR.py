import pandas as pd
from sklearn.impute import KNNImputer
import time

imputation_times = []  # List to store imputation times

percentages = [10, 20, 30, 40, 50, 60, 70, 80, 90]

for percentage in percentages:
    for i in range(1, 11):
        print(i)
        missing_df_name = "Projects/MIDAS/VaryingPercentage/VaryingPercentageMissingDataframe_" + str(percentage) + "_" + str(i) + ".csv"
        missing_df = pd.read_csv(missing_df_name)

        imputer = KNNImputer(n_neighbors=35)
        
        imputed_data = imputer.fit_transform(missing_df)
        

        df_imputed = pd.DataFrame(imputed_data, columns=missing_df.columns)

        filename = f'Projects/KNN/VaryingPercentage/VaryingPercentageImputedDataframe_{percentage}_{i}.csv'
        df_imputed.to_csv(filename, index=False)
