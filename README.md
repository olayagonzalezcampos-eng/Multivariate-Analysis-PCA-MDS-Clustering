# Multivariate Analysis - Household Expenditure on Education Survey (EGHE)

## Authors
* Patricia Cabezón Díez
* Olaya González Campos
* Naroa Martín Casado

## Project Description
This repository contains a multivariate analysis of household expenditure on education in Spain (2023/2024 academic year), based on data from the National Statistics Institute (INE). 

The project combines the use of **R** for the initial data cleaning and exploration phase, and **MATLAB** for applying advanced multivariate analysis techniques (PCA, MDS, and Clustering).

## Repository Structure
* `data/raw/`: Contains the variable description (`dr_EGHE_2023.xlsx`) and the original dataset extracted from the INE (`EGHE_2023.tab`).
* `data/processed/`: Contains the cleaned, imputed, and filtered dataset (`data_cleaning.csv`), ready to be consumed by the algorithms in MATLAB.
* `reports/`: Final reports in PDF format detailing the methodology, results of the Principal Component Analysis, Multidimensional Scaling, and Clustering.
* `scripts/`:
  * `data_cleaning_and_EDA.R`: R script responsible for variable selection, data cleaning, missing value imputation (using the `mice` package), and Exploratory Data Analysis (EDA).
  * `assignment_PCA.m`: MATLAB script that performs the Principal Component Analysis.
  * `second_assignment.m`: MATLAB script that executes Multidimensional Scaling (MDS) and Clustering algorithms (hierarchical and partitional).

## Execution Instructions
To reproduce this analysis from start to finish, run the scripts in the following order:

1. **RStudio**: Run `scripts/data_cleaning_and_EDA.R`. This step will take the raw data from `data/raw/` and generate the `data_cleaning.csv` file in the `data/processed/` folder.
2. **MATLAB**: Open and run `scripts/assignment_PCA.m` to obtain the results and plots for the principal components.
3. **MATLAB**: Open and run `scripts/second_assignment.m` to generate the MDS models and clusters.