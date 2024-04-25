import pandas as pd
from sklearn.impute import KNNImputer
import numpy as np

df = pd.read_csv('Projects/MergedAllSampleFinal.csv')
df.to_csv('Projects/KNN/KNNComplete.csv', index=False)

num_nan_values = int(0.2 * df.size)

random_rows = np.random.randint(0, df.shape[0], num_nan_values)
random_cols = np.random.randint(0, df.shape[1], num_nan_values)

for row, col in zip(random_rows, random_cols):
    df.iat[row, col] = np.nan

df.to_csv('Projects/KNN/KNNMissing.csv', index=False)

for n in [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]:
    print(n)
    imputer = KNNImputer(n_neighbors=n)
    imputed_data = imputer.fit_transform(df)
    df_imputed = pd.DataFrame(imputed_data, columns=df.columns)

    filename = f'Projects/KNN/KNNImputed_n_{n}.csv'
    
    df_imputed.to_csv(filename, index=False)
