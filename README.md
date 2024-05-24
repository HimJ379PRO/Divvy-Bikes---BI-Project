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
5. `Git` to implement version control and enable efficient collaboration between my MacBook, hosting PostgreSQL, and Desktop computer, hosting Tableau Public. Let’s imagine a collab between a Data Analyst and a BI Analyst.
6. `GitHub` to host the project files on the Cloud.


## Extract

The ‘trips’ quarterly datasets, along with the ‘stations’ dataset, were downloaded from [Divvy website](https://divvybikes.com/system-data)

Each **trip** is anonymized and includes:
- Trip start day and time
- Trip end day and time
- Trip start station
- Trip end station
- Rider type (Subscriber, Customer)
- Trip duration
- Gender
- Birthyear

The data has been processed to remove trips that are taken by staff as they service and inspect the system; and any trips that were below 60 seconds in length (potentially false starts or users trying to re-dock a bike to ensure it was secure).

The **station** table includes info regarding:
- Station Name
- Number of docks
- Geospatial Information (Latitude and Longitude)

The ‘weather’ data was manually scraped from [Weather Underground](https://www.wunderground.com/history/monthly/us/il/chicago/KMDW) website.
The data for each month of 2018 and 2019 was copy-pasted in the Microsoft Excel workbook and then imported into the database.

The Chicago **Weather** data contains:
- Average, Minimum, and Maximum values for each characteristic (field) were recorded each day for each observation (record).
- Windspeed
- Temperature
- Precipitation
- Humidity

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
Since Tableau Public does not connect to the PostgreSQL database, I exported the tables to CSV files and stored them on the local storage.

> [!IMPORTANT]
> In the real world, we would perform Stage 2 Data Preparation using SQL and store the data in the staging table, perform the data transformations, and then load the data in the final database that we would use to connect to the Tableau Desktop using a PostgreSQL connector.
> In case the data structure and format coming from the source stays the same, we would create a Stored Procedure to automate these tasks.


## Analyze

Access the Tableau visualizations on [Tableau Public](https://public.tableau.com/app/profile/himanshu.jagtap/viz/DivvyExecutiveDashboard_17111650001190/DivvyAnalysis)

Established connection between the ‘trips’ and ‘stations’ tables (CSV) and set the one-to-many relationship between ‘station id’ columns in the respective tables.

![Relationship](Screenshots/Tableau_Table_Relationships.png)

Added a new data source to connect to the 'weather' table. Established a relationship between the ‘start time’ in the trips table and the ‘date’ field in the 'weather' table by linking the fields as below.

![Blend](Screenshots/Data_Blending.png)

![Field Linking](Screenshots/Tableau_Field_Linking.png)

### Riders
To serve our customers well, we must know who our customers are and try to meet their needs well.

Divvy Riders are mainly divided into 3 categories:

**Subscribers**
- Commuters
- Must share ‘gender’ and ‘birthyear’

**Customers**
- Tourists
- Must share ‘gender’ and ‘birthyear’

**Day Pass Riders**
- Riders don’t have to sign up for the Divvy Account
- Do not share ‘gender’ and ‘birthyear’  

IMAGE

**Observations** 
1. Subscribers vs. Customers:
  - Subscribers dominate the total number of trips compared to customers.
2. Gender Distribution:
  - Among subscribers, males take the vast majority of trips compared to females.
  - Among customers, males also take more trips than females, though the difference is less pronounced.
3. Day Pass Riders:
  - Customers using day passes take a significant number of trips.

**Key Insight**
- ‘Male Subscribers’ are our key customers who take the most trips. (59% of total trips).

**Recommendations**

**Earn ad revenue/sales commission by promoting partner brands:** \
Partner with brands to advertise sales and discounts to the Divvy app users. These ads, along with the link to the product page, would be sent to the subscriber's phone at the end of a trip via push notification.

**Focus on our most frequent riders (Male Subscribers):**

+ **Personalized Offers:** Use data analytics to identify usage patterns among male subscribers and create personalized offers that encourage more frequent use. For example, offer loyalty rewards or discounts for achieving certain ride milestones each month.
+ **Fitness Challenges:** Organize fitness challenges or biking events that cater to competitive and fitness-oriented males, offering prizes or recognition for participation and achievements.
+ **Interest-Based Marketing:** Promote biking as a complementary activity to popular male-dominated interests such as sports, fitness, or commuting. Highlight benefits such as improved health, cost savings, and convenience.


**Attract More Female Riders:**

+ **Women-Specific Promotions:** Offer promotions or discounts for female riders, and create women-focused biking groups or events to foster a sense of community.
+ **Incentive Programs:** Create incentive programs that reward female users for frequent trips, such as bonus loyalty points that can be redeemed for Divvy merchandise or discounted products or services at partner brands.
+ **Partnerships:** Collaborate with organizations focused on women's health and fitness to promote biking as a beneficial activity.
+ **Influencer Partnerships:** Collaborate with female fitness influencers, athletes, or local celebrities to promote Divvy. Use their platforms to reach and engage potential new users within this demographic.

