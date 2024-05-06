# Divvy Bikes: BI Project Report

Access the Tableau visualizations and analysis on [Tableau Public](https://public.tableau.com/app/profile/himanshu.jagtap/viz/DivvyExecutiveDashboard_17111650001190/DivvyAnalysis)
## Stage 1: Data Preparation using Python

Divvy publishes the trip history data on the official website every quarter. I selected to work on the quarterly data for the years 2018 and 2019. - https://divvybikes.com/system-data

I used Python (pandas) to check the data for its structure, variables, and missing values. The data would be checked for incorrect/invalid values and the issues would be fixed in PostgreSQL in stage 2 data preparation.

The Python code for stage 1 data preparation can be viewed here - [Python Notebook](Data_Prep.ipynb)

**Steps -** 
1. Read all 8 datasets into pandas data frames.
2. Checked for the missing values and structure of each dataset.
3. Sampled the datasets by randomly selecting 25% of the records.
4. The sampled datasets were then combined into a single dataset.
5. The data frame was exported to a CSV file for further analysis and stage 2 data preparation using SQL.

> [!TIP]
> We used `random state = 3` in `sample()` method, doing so the same data/records can be reproduced each time we run the script.

**Why did I sample/reduce the records?** \
On Tableau Public, I’ve experienced that datasets having less than 2 million records tend to load faster. Since this project is a personal challenge, I preferred a faster loading time on the Tableau Public website over presenting real-world numbers for the dashboard.

**Observations and Challenges -** 
The important columns in the dataset do not contain any NULLS. Fields ‘gender’ and ‘birthyear’ has some missing values.
One of the datasets had the same data structure, but the field names were different.
The issue was fixed by renaming the fields consistently and then joining the datasets.
.The final dataset contains ~2 million records, meeting our criterion.

The below table represents the datasets, actual records, and sampled records for each quarter and the total.

| Datasets | Actual Records | Sampled Records |
|----------|----------------|-----------------|
| Q1 2018  | 387,145        | 96,786          |
| Q2 2018  | 1,059,681      | 264,920         |
| Q3 2018  | 1,513,570      | 378,393         |
| Q4 2018  | 642,686        | 160,672         |
| Q1 2019  | 365,069        | 91,267          |
| Q2 2019  | 1,108,163      | 277,041         |
| Q3 2019  | 1,640,718      | 410,180         |
| Q4 2019  | 704,054        | 176,014         |
| **Total**    | **7,421,086**      | **1,855,272**       |


## Stage 2: Data Preparation using SQL

The SQL code for stage 2 data preparation can be viewed here - 
