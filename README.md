# Divvy Bikes: BI Project Report
The business team reached out to the Reporting and Analytics team asking for *recommendations to increase the revenue by increasing the number of trips and subscribers*. The stakeholders needed a comprehensive overview of the trips taken over the last two years (2018-2019). Based on my performance implementing the data analytics and BI projects, I was assigned to lead the initiative.

**The Data -** \
Divvy publishes the ‘trip’ history data on the official website every quarter. I selected to analyze quarterly data for the years 2018 and 2019.

The ‘stations’ dataset was readily available to download.

The ‘weather’ data needed to be downloaded from a 3rd party. To save the cost and reduce time gathering the data, I decided to manually scrape it from [Weather Underground](https://www.wunderground.com/history/monthly/us/il/chicago/KMDW) website.

**Tech Stack -**
1. `Python` to combine 8 datasets into a single dataset and analyze the variables for missing values.
2. `Visual Studio Code` to leverage `Jupyter Notebook` and manage the project.
3. `PostgreSQL (pgAdmin)` to use `SQL` to create a database, create relationships between the tables, fix the incorrect/invalid values and outliers, and ensure data consistency and integrity.
4. `Tableau` to visualize and analyze the data, leveraging Descriptive Statistics to examine past performance to find patterns and unearth actionable insights.
5. `Git` to implement version control and enable efficient collaboration (Between my Mac laptop and Windows computer).
6. `GitHub` to host the project files on the Cloud.

Access the Tableau visualizations and analysis on [Tableau Public](https://public.tableau.com/app/profile/himanshu.jagtap/viz/DivvyExecutiveDashboard_17111650001190/DivvyAnalysis)

## Extract

The ‘trips’ quarterly datasets, along with the ‘stations’ dataset, were downloaded from [Divvy website](https://divvybikes.com/system-data)

Each trip is anonymized and includes:
- Trip start day and time
- Trip end day and time
- Trip start station
- Trip end station
- Rider type (Subscriber, Customer)
- Trip duration
- Gender
- Birthyear

The data has been processed to remove trips that are taken by staff as they service and inspect the system; and any trips that were below 60 seconds in length (potentially false starts or users trying to re-dock a bike to ensure it was secure).

Station table includes info regarding:
- Station Name
- Number of docks
- Geospatial Information (Latitude and Longitude)

The ‘weather’ data was manually scraped from [Weather Underground](https://www.wunderground.com/history/monthly/us/il/chicago/KMDW) website.
The data for each month of 2018 and 2019 was copy-pasted in the Microsoft Excel workbook and then imported into the database.

## Transform
### Stage 1: Data Preparation using Python

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
1. The important columns in the dataset do not contain any NULLS. Fields ‘gender’ and ‘birthyear’ has some missing values.
2. One of the datasets had the same data structure, but the field names were different.
  - The issue was fixed by renaming the fields consistently and then joining the datasets.
3. The final dataset contains ~2 million records, meeting our criterion.

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


### Stage 2: Data Preparation using SQL

The SQL code for stage 2 data preparation can be viewed here - [SQL Script](Database_Define_Clean_Transform.sql)

**Steps -** 
1. Created ‘stations’, ‘trips’, and ‘weather’ tables using appropriate data types and constraints.
2. Imported the data exported in Stage 1 Data Prep and scraped weather data into PostgreSQL using pgAdmin GUI.
3. Fixed the data type mismatch in the ‘birthyear’ and ‘tripduration’ fields using TRIM(), REPLACE(), and typecast functions.
4. Added Foreign key constraints to establish the relationship between the fact and dimension tables.
5. Created an FK Index for each FK constraint to improve the query performance.
6. Dropped the redundant columns 'from_station_name' and 'to_station_name' to follow database design best practices and increase database performance.
7. Checked values in fields for consistency and validity.
8. Removed the wrong values where confident. Also, reached out to the customers to verify the values identified as wrong are actually wrong.
9. Fixed the ‘birthyear’ values based on the customer feedback report.
10. Removed the outliers and illogical values in ‘tripduration’ and ‘birthyear’ fields.
11. Exported the tables to CSV files to connect to Tableau.

> [!IMPORTANT]
> When using Tableau Desktop, we would directly connect to the PostgreSQL database using a connector.

> [!NOTE]
> We used integer data type for ‘birthyear’ so that we could easily calculate the ‘age’ of our customers using numerical functions.

**Entity Relationship Diagram**

![ERD](Screenshots/ERD.png)

## Load

Established connection between the ‘trips’ and ‘stations’ tables (CSV) and set the one-to-many relationship between ‘station id’ columns in the respective tables.

![Relationship](Screenshots/Tableau_Table_Relationships.png)

Added a new data source to connect to the weather table. Established a relationship between the ‘start time’ in the trips table and the ‘date’ field in the weather_chi table by linking the fields as below.

![Field Linking](Screenshots/Tableau_Field_Linking.png)


