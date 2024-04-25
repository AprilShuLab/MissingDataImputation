import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.preprocessing import MinMaxScaler
import MIDASpy as md
import time

# Create a list of different missingness percentages
missingness_percentages = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
layer_structure_values = [[64, 64, 64], [128, 128, 128], [256, 256, 256]]
input_drop_values = [0.75, 0.8, 0.9]
epochs_values = [5, 10, 15]

# Create an empty dictionary to store the best combinations for each missingness percentage
best_combinations = {}

for missingness_percentage in missingness_percentages:
    best_mean_nrmse = float('inf')  # Initialize with a large value
    best_combination = None

    # Iterate through different values
    for layer_structure in layer_structure_values:
        for input_drop in input_drop_values:
            for epochs in epochs_values:
                print(f"Training model with Missingness Percentage: {missingness_percentage}, Layer Structure: {layer_structure}, Input Drop: {input_drop}, Epochs: {epochs}")

                data = pd.read_csv('Projects/MergedAllSampleCompleteOneHot.csv')

                num_nan_values = int(missingness_percentage * data.size)

                # Generate random row and column indices for NaN insertion
                random_rows = np.random.randint(0, data.shape[0], num_nan_values)
                random_cols = np.random.randint(0, data.shape[1], num_nan_values)

                # Set the selected values to NaN
                for row, col in zip(random_rows, random_cols):
                    data.iat[row, col] = np.nan

                scaler = MinMaxScaler()
                data_scaled = scaler.fit_transform(data)
                data_scaled = pd.DataFrame(data_scaled, columns=data.columns)

                imputer = md.Midas(layer_structure=layer_structure, vae_layer=False, seed=89, input_drop=input_drop)

                # Record the start time
                start_time = time.time()

                imputer.build_model(data_scaled)
                imputer.train_model(training_epochs=epochs)
                imputations = imputer.yield_samples(m=1)
                # Record the end time
                end_time = time.time()

                imputation_list = list(imputations)
                imputed_data = imputation_list[0]

                data_unscaled = scaler.inverse_transform(imputed_data)
                data_unscaled = pd.DataFrame(data_unscaled, columns=data_scaled.columns)

                complete_data = pd.read_csv('Projects/MergedAllSampleCompleteOneHot.csv')

                # Initialize an empty list to store NRMSE values for each column
                nrmse_values = []

                # Loop through each column in the DataFrames
                for column_name in complete_data.columns:
                    # Extract the current column from both DataFrames
                    observed_column = complete_data[column_name]
                    imputed_column = data_unscaled[column_name]

                    # Calculate MSE
                    mse = np.mean((imputed_column - observed_column) ** 2)

                    # Calculate RMSE
                    rmse = np.sqrt(mse)

                    # Calculate the range of the observed column
                    data_range = np.max(observed_column) - np.min(observed_column)

                    # Calculate NRMSE for the current column
                    nrmse = rmse / data_range

                    # Append the NRMSE value to the list
                    nrmse_values.append(nrmse)

                # Calculate the mean NRMSE across all columns
                mean_nrmse = np.mean(nrmse_values)

                # Check if the current combination has a lower mean NRMSE than the best so far
                if mean_nrmse < best_mean_nrmse:
                    best_mean_nrmse = mean_nrmse
                    best_combination = {'Layer Structure': layer_structure,
                                        'Input Drop': input_drop,
                                        'Epochs': epochs,
                                        'Mean NRMSE': mean_nrmse}

    # Store the best combination for this missingness percentage in the dictionary
    best_combinations[missingness_percentage] = best_combination

# Create a DataFrame from the best combinations dictionary
best_combinations_df = pd.DataFrame.from_dict(best_combinations, orient='index')

# Print the best combinations
print(best_combinations_df)

# Save the best combinations to a CSV file
best_combinations_df.to_csv('MIDAS/BestCombinations.csv')
