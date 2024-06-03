# Divvy Bikes: BI Project Report
The business team reached out to the Reporting and Analytics team asking for *recommendations to increase the revenue by increasing the number of trips and subscribers*. The stakeholders needed a comprehensive overview of the trips taken over the last two years (2018-2019). Based on my performance implementing the data analytics and BI projects, I was assigned to lead the initiative.

**The Data:** \
Divvy publishes the ‘trip’ history data on the official website every quarter. I selected to analyze quarterly data for the years 2018 and 2019.

The ‘stations’ dataset was readily available to download.

The ‘weather’ data needed to be downloaded from a 3rd party. To save the cost and reduce time gathering the data, I decided to manually scrape it from Weather Underground website.

**Tech Stack:**
1. `Python` to combine 8 datasets into a single dataset and analyze the variables for missing values.
2. `Visual Studio Code` to leverage `Jupyter Notebook` and manage the project.
3. `PostgreSQL (pgAdmin)` to use `SQL` to create a database, create relationships between the tables, fix the incorrect/invalid values and outliers, and ensure data consistency and integrity.
4. `Tableau` to visualize and analyze the data, leveraging Descriptive Statistics to examine past performance to find patterns and unearth actionable insights.
5. `Git` to implement version control and enable efficient collaboration between my MacBook, hosting PostgreSQL, and Desktop computer, hosting Tableau Public. Let’s imagine a collab between a Data Analyst and a BI Analyst.
6. `GitHub` to host the project files on the Cloud.


## Extract
### Trips and Stations data
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

### Daily Weather data
I decided to find bike usage patterns to '**optimize bike availability**' based on weather patterns, combining this data with the seasonal usage pattern. For this purpose, we needed the daily weather observations recorded over 2 years. 

Options:
1. Purchase the weather data online/3rd party,
2. Scrape the weather data from a website hosting historical weather data in tabular format.

I chose option 2 because it saved time and cost.

The ‘weather’ data was scraped from [Weather Underground](https://www.wunderground.com/history/monthly/us/il/chicago/KMDW) website.

>[!TIP]
>Python code for the data scraping process can be reviewed here - [DataScraping_Weather.ipynb](DataScraping_Weather.ipynb)

**Steps -** 
1. Studied the HTML structure of the DAILY OBSERVATIONS table using Google Chrome Developer Tools.
2. Downloaded and parsed the HTML of all 24 pages (12 each year) by automatically generating the page URLs and looping through each of them.
3. Extracted the row data and stored it temporarily in the dictionary. 
4. Appended the individual table data to the pandas data frame one after the other.
5. Combined the data frames and exported and exported to CSV file.

The UNPROCESSED data was saved to [WeatherData_2018_2019_UNPROCESSED.csv](WeatherData_2018_2019_UNPROCESSED.csv)

>[!IMPORTANT]
> I added a `WebDriverWait()` with the condition to wait until the table with the specified CSS selector is present on the page. This ensured that the code waits for each page to load completely before proceeding to scrape data from it.

>[!NOTE]
> + The structure of the DAILY OBSERVATIONS table was highly intricate. Field names were distributed across two lines, with header data stored in both 'th' and 'td' tags. Data for each characteristic, such as wind speed or temperature, was organized in separate tables containing Min, Max, and AVG values. 
>  - The solution involved extracting these tables individually and then concatenating them horizontally along axis 1.

The data in the CSV file was later PROCESSED by loading it into MS Excel and adding the DATES by replacing the day numbers with the full date in MM/DD/YYYY format. This process was accelerated using the smart and powerful AUTOFILL feature of MS Excel.

The PROCESSED data was saved to [WeatherData_2018_2019_PROCESSED.csv](WeatherData_2018_2019_PROCESSED.csv)

The Chicago **Weather** data contains:
- Windspeed
- Temperature
- Precipitation
- Humidity
- Dew Point
- Pressure

## Transform
### Stage 1: Data Preparation using Python

Divvy publishes the trip history data on the official website every quarter. I selected to work on the quarterly data for the years 2018 and 2019. - https://divvybikes.com/system-data

I used Python (pandas) to check the data for its structure, variables, and missing values. The data would be checked for incorrect/invalid values and the issues would be fixed in PostgreSQL in stage 2 data preparation.

[!TIP]
> The Python code for stage 1 data preparation can be viewed here - [Data_Prep.ipynb](Data_Prep.ipynb)

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

>[!TIP]
> The SQL code for stage 2 data preparation can be viewed here - [Database_Define_Clean_Transform.sql](Database_Define_Clean_Transform.sql)

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
> [!Note]
> In case the data structure and format coming from the source stays the same, we would create a Stored Procedure to automate these tasks.


## Analyze

>[!TIP]
> Access the Tableau visualizations on [Tableau Public](https://public.tableau.com/app/profile/himanshu.jagtap/viz/DivvyExecutiveDashboard_17111650001190/DivvyAnalysis)

Established connection between the ‘trips’ and ‘stations’ tables (CSV) and set the one-to-many relationship between ‘station id’ columns in the respective tables.

![Relationship](Screenshots/Tableau_Table_Relationships.png)

Added a new data source to connect to the 'weather' table. Established a relationship between the ‘start time’ in the trips table and the ‘date’ field in the 'weather' table by linking the fields as below.

![Blend](Screenshots/Data_Blending.png)

![Field Linking](Screenshots/Tableau_Field_Linking.png)

### Riders
To serve our customers well, we must know who our customers are and try to meet their needs well.

Divvy Riders are mainly divided into 3 categories:

**Subscribers**
- Majority Commuters
- Must share ‘gender’ and ‘birthyear’

**Customers**
- Majority Tourists
- Must share ‘gender’ and ‘birthyear’

**Day Pass Riders**
- Riders don’t have to sign up for the Divvy Account
- Do not share ‘gender’ and ‘birthyear’  

**Trips taken by Riders (SubTypes)**
![RiderSubType](Assets/Vizzes/RiderSubType.png)

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

**Generate Ad Revenue and Sales Commissions:**  
- Collaborate with brands to advertise sales and discounts to Divvy app users. These ads, along with links to product pages, will be sent to subscribers' phones via push notifications at the end of a trip.
- Utilize the rider's route to promote shops along the riding path.

**Focus on our most frequent riders (Male Subscribers):**

+ **Personalized Offers:** Use data analytics to identify usage patterns among male subscribers and create personalized offers that encourage more frequent use. For example, offer loyalty rewards or discounts for achieving certain ride milestones each month. This will ensure the optimum revenue from our most frequent riders.
+ **Interest-Based Marketing:** Promote biking as a complementary activity to popular male-dominated interests such as sports, fitness, or commuting. Highlight benefits such as improved health, cost savings, and convenience.

**Attract More Female Riders:**

+ **Women-Specific Promotions:** Offer promotions or discounts for female riders, and create women-focused biking groups or events to foster a sense of community.
+ **Incentive Programs:** Create incentive programs that reward female users for frequent trips, such as bonus loyalty points that can be redeemed for Divvy merchandise or discounted products or services at partner brands.
+ **Partnerships:** Collaborate with organizations focused on women's health and fitness to promote biking as a beneficial activity.
+ **Influencer Partnerships:** Collaborate with female fitness influencers, athletes, or local celebrities to promote Divvy. Use their platforms to reach and engage potential new users within this demographic.

### Age Distribution

Let’s visualize Rider distribution by ‘Age’

For this, we would calculate ‘Age’ using the ‘Birthyear’ field.
Since the latest data we have is 2019, instead of using the TODAY function, we would use the formula `2019 - [BIRTHYEAR]`

>[!TIP]
>This situation best describes why the INTEGER data type is recommended for the ‘birthyear’ values.

Wait!, some values do not make sense: (0, 5, 14, 97, 98). These Riders either seem too young or too old to be our riders, hence we would EXCLUDE/FILTER these values. The secondary reason to remove these outliers is to make our visualization more legible and a true representation of our most regular users.

![alt text](Assets/Vizzes/AgeDistribution.png)

**Observations**
1. Subscribers and customers show a similar usage pattern w.r.t. Number of trips taken by age, but the pattern of weekday trips differs: subscribers take most trips on weekdays and customers take most trips on weekends. 
2. 20-year-old riders have taken the most rides.
3. The other Top 4 age groups, w.r.t. Number of trips taken, are [26, 27, 28, 30].
4. The number of trips declines steadily after age 35.
5. Day Pass Riders do not show any peculiar usage pattern for the age groups.

**Recommendations**
+ Target Age Group 25-35:
  - **Enhanced Membership Packages:** Develop specialized membership packages with benefits tailored to the needs of subscribers aged 25-35, such as discounts for longer rides, partnerships with gyms or fitness centers, and special events or competitions.
  - **Engagement Campaigns:** Launch marketing campaigns targeting this age group through channels they frequently use, such as social media, fitness apps, and commuter-focused advertising.

+ **Re-engage Younger Riders:**
  - Student Discounts: Offer discounted memberships or day passes for students, and partner with universities to provide easy access to bikes on or near campuses.

+ **Fitness Challenges:** 
  - Organize fitness challenges or biking events that cater to competitive and fitness-oriented males, offering prizes or recognition for participation and achievements.

### Trips by Day-Hour

**Subscribers**

![alt text](Assets/Vizzes/TripsByDayHour_Subscribers.png)

**Observations (Subscribers)**
- When we filter the data by RiderType, we observe that Subscribers exhibit 2 peaks of activity, one in the morning (7 AM to 9 AM) and one in the evening (4 PM to 6 PM), on weekdays. 
- Combining this information with the AGE DISTRIBUTION viz, we can conclude that these are young professionals who commute to work. They must be biking to and from work every day, and a subscription is definitely cheaper for that use.
- Weekend trips are more evenly distributed throughout the day but are generally lower in number compared to weekday peaks.

**Customers and Day Pass Riders**

![alt text](Assets/Vizzes/TripsByDayHour_Customers.png)

**Observations (Customers)**
- Customers and Day Pass Riders take frequent rides on weekends between 10 AM and 7 PM. 
- This suggests that the primary use cases for these riders include leisure activities such as visiting tourist attractions or biking alongside the Chicago River.

**Recommendations**

**Working Professionals Focused Plans and Promotions:**
+ **Corporate Partnerships:** Partner with businesses and office complexes to offer bulk subscriptions or corporate discounts for employees. Encourage companies to subsidize bike-sharing memberships as part of their employee benefits package. Partner with businesses to host community events, such as bike-to-work days.
+ **Guaranteed Availability:** Ensure bike availability and docking space at popular commuting stations during peak hours. This might involve increasing the fleet size or redistributing bikes more effectively.
+ **Weekend Promo for families:** Introduce weekend-specific promotions or family-friendly packages to increase ridership during off-peak times. Collaborate with local events or tourist attractions to offer bundled deals. For example, offer free bike unlocks to the family members of subscribers during the weekends.

**Tourism Partnerships and Promotions:**

+ **Tourist Attraction Packages:** Partner with popular tourist attractions in Chicago to offer bundled deals that include discounted Divvy day or Weekend passes. This can be promoted through tourism websites, hotels, and tourist information centers.
+ **Guided Bike Tours:** Collaborate with local tour companies to offer guided bike tours that highlight the Chicago River and other scenic routes. Include Divvy bike rentals as part of the tour package.
Enhanced Weekend Offerings:
+ **Weekend Passes:** Introduce special weekend passes that offer unlimited rides for the duration of a weekend. Market these passes specifically to tourists and casual riders.
+ **Family and Group Discounts:** Offer discounts for families or groups to encourage more group outings on weekends. This could include "buy one, get one free" deals or discounted rates for additional riders.

**Targeted Marketing Campaigns:**

+ **Local Event Collaborations:** Promote Divvy as a convenient transportation option for local events, festivals, and markets happening on weekends. Partner with event organizers to offer discounted or free rides to attendees.
+ **Digital Marketing:** Use digital marketing channels such as social media, Google Ads, and travel blogs to target ads towards tourists and weekend visitors. Highlight the convenience and fun of exploring Chicago by bike.

**Enhanced User Experience:**

+ **Interactive Maps:** Develop interactive maps and route planners that highlight popular tourist routes, scenic paths along the Chicago River, and points of interest. These can be integrated into the Divvy app and website.


### Top Stations by Trips

To analyze further, I combined the multiple visualizations on 'trips', 'stations', and 'Riders' data with the location data (Nearby **Tourists Attractions, Transit Stations, and Office Buildings**) on **Google Maps** to create a list of the key stations in Chicago Downtown, ranked bby number of trips started at the station.

**Top 10 Stations in Chicago Downtown OVERALL**
| Rank | Station                         | Characteristic          | Popular Places Nearby                                                                 | Top Time Blocks by Traffic | Top Rider Type |
|------|---------------------------------|-------------------------|--------------------------------------------------------------------------------------|----------------------------|----------------|
| 1    | Streeter Dr & Grand Ave         | Tourist Attraction      | Navy Pier, Children’s Museum, Milton Lee Olive Park, Ohio Street Beach               | Afternoon, Evening         | Customers      |
| 2    | Canal St & Adams St             | Public Transit Station  | Chicago Union Station, Skydeck Chicago, Chicago River                                | Morning, Afternoon         | Subscribers    |
| 3    | Clinton St & Madison St         | Public Transit Station  | Ogilvie Transportation Center, Chicago River                                         | Morning, Afternoon         | Subscribers    |
| 4    | Clinton St & Washington Blvd    | Public Transit Station  | Ogilvie Transportation Center, Chicago River                                         | Morning, Afternoon         | Subscribers    |
| 5    | Lake Shore Dr & Monroe St       | Tourist Attraction      | Maggie Daley Park, Monroe Harbor, The Art Institute of Chicago                       | Afternoon, Evening         | Customers      |
| 6    | Michigan Ave & Washington St    | Public Transit Station  | Subway Station, Millennium Park                                                      | Afternoon                  | Subscribers    |
| 7    | Columbus Dr & Randolph St       | Tourist Attraction      | Lurie Garden, Millennium Park, Crown Fountain                                        | Morning, Afternoon         | Subscribers    |
| 8    | Daley Center Plaza              | Tourist Attraction      | Richard J. Daley Center                                                              | Afternoon                  | Subscribers    |
| 9    | Franklin St & Monroe St         | Tourist Attraction      | Lyric Opera of Chicago, Chicago River                                                | Afternoon                  | Subscribers    |
| 10   | Kingsbury St & Kinzie St        | Public Transit Station  | Merchandise Mart Station, Chicago River                                              | Morning, Afternoon         | Subscribers    |


**Top 5 Stations Ranked by Trips taken by SUBSCRIBERS** 

| Rank | Station                      | Characteristic          | Popular Places Nearby                          | Top Time Blocks When Trips Started |
|------|------------------------------|-------------------------|-----------------------------------------------|-----------------------------------|
| 1    | Canal St & Adams St          | Public Transit Station  | Chicago Union Station, Skydeck Chicago, Chicago River | Morning, Afternoon                |
| 2    | Clinton St & Madison St      | Public Transit Station  | Ogilvie Transportation Center, Chicago River   | Morning, Afternoon                |
| 3    | Clinton St & Washington Blvd | Public Transit Station  | Ogilvie Transportation Center, Chicago River   | Morning, Afternoon                |
| 4    | Kingsbury St & Kinzie St     | Public Transit Station  | Merchandise Mart Station, Chicago River        | Morning, Afternoon                |
| 5    | Daley Center Plaza           | Tourist Attraction      | Richard J. Daley Center                        | Afternoon                         |


**Top 5 Stations Ranked by Trips taken by CUSTOMERS**

| Rank | Station                   | Characteristic      | Popular Places Nearby                                                             | Top Time Blocks When Trips Started |
|------|---------------------------|---------------------|----------------------------------------------------------------------------------|-----------------------------------|
| 1    | Streeter Dr & Grand Ave   | Tourist Attraction  | Navy Pier, Children’s Museum, Milton Lee Olive Park, Ohio Street Beach            | Afternoon, Evening                |
| 2    | Lake Shore Dr & Monroe St | Tourist Attraction  | Maggie Daley Park, Monroe Harbor, The Art Institute of Chicago                    | Afternoon, Evening                |
| 3    | Millennium Park           | Tourist Attraction  | Millennium Park                                                                   | Afternoon, Evening                |
| 4    | Shedd Aquarium            | Tourist Attraction  | Shedd Aquarium                                                                    | Afternoon                         |
| 5    | Michigan Ave and Oak St   | Tourist Attraction  | Lincoln Park Zoo, Lakefront Trail                                                 | Afternoon, Evening                |

**Observations**
   - **Tourist Attraction Stations**:
   These stations are located near 'popular tourist destinations' and have high traffic during the 'afternoon and evening', primarily from 'customers'.
   - **Public Transit Stations**:
   These stations are situated near 'major transit hubs' and have high traffic during 'morning and afternoon', mainly from 'subscribers'.


**Recommendations**

**Improving Station Utilization**

- **Real-Time Data Utilization**: Use real-time data to monitor bike availability and ensure stations are adequately stocked, especially during peak times.
- **Expanding Docking Stations**: Add more docking stations at high-demand locations and underserved areas to accommodate more riders and reduce instances of full or empty stations.

>[!TIP]
> Integrate the observations regarding seasonal patterns and station congestion visualizations to recommend which stations should have an increased number of docks and which should have a reduced number.

**Station Specific Recommendations:**

1. **For Streeter Dr & Grand Ave**:
   - **Tourist Promotions**: Partner with nearby attractions like Navy Pier to offer combined tickets or discounts for Divvy users.
   - **Evening Rides**: Promote evening rides with scenic routes along Ohio Street Beach and the Chicago River, possibly with guided tours.

2. **For Canal St & Adams St**:
   - **Commuter Programs**: Introduce a loyalty program for Subscribers with perks like priority bike access during peak hours.
   - **Morning Coffee Deals**: Partner with nearby coffee shops to offer discounts to Divvy users commuting in the morning.

3. **For Clinton St & Washington Blvd**:
   - **Corporate Engagement**: Engage with businesses near the Ogilvie Transportation Center to offer exclusive subscription discounts for their employees.
   - **Public Transit Integration**: Enhance integration with public transit options, offering seamless transition solutions for riders.

**Integration with Google and Apple Maps apps**
- **Increased Visibility**: Divvy stations will be prominently displayed as viable transit options in Google and Apple Maps, attracting new users, including tourists who use these apps for navigation.

- **Seamless Navigation**: Users can plan routes incorporating biking, receive real-time bike availability updates, and reduce frustration from unavailable bikes.
- **Enhanced Convenience**: Users can find stations, check availability, and initiate rentals directly from the maps app, with optimized biking routes for a smoother ride.
- **Improved User Experience for Subscribers**: Subscribers can link accounts to maps apps for easier bike reservations and access to ride history and stats, with optimized routes for commuters.
- **Data Analytics and Insights**: Integration provides valuable data on user behavior for optimizing bike distribution and station placement, with an easy feedback loop through the maps app.

By leveraging Google and Apple Maps' user bases and navigation features, Divvy can attract more riders, enhance user experience, and increase trips and revenue.

### Station Congestion

I used Tableau's ‘Pages Playback’ feature to visualize the number of trips started at the station concerning the number of docks at the station, each month. Stations are represented with Blue circles; their size varies by the number of docks. The red-to-yellow gradient of colors represents the number of trips started at the station; Red represents a lower number of trips per station and bright yellow represents a higher number of trips started at the station.

![alt text](Assets/Vizzes/StationCongestion.gif)

**Observations** \
The Top 5 Stations getting overburdened owing to unusually high demand in Summer, especially in July and August, are Michigan Ave & Oak St, Streeter Dr & Grand Ave, Lake Shore Dr & Monroe St, Clinton St & Madison St, and Clinton St & Washington Blvd. We are losing revenue as many Riders were not unable to start the ride owing to the unavailability of the bikes.

1. **High Traffic Concentration in Downtown Chicago**:
   - The central area of downtown Chicago shows a consistently high number of trips per dock throughout the months. This is indicated by the bright yellow circles, especially around major tourist attractions and public transit hubs.

2. **Seasonal Variation**:
   - There is a noticeable increase in the number of trips per dock during the warmer months (likely from late spring to early fall). This suggests a higher usage of the bike-share system during these periods, likely due to more favorable weather conditions.

3. **Consistent Low Traffic in Certain Areas**:
   - Some peripheral areas consistently show low traffic, indicated by red circles. These areas might not have as many attractions or are less densely populated, resulting in fewer trips per dock.

4. **Public Transit and Tourist Attraction Proximity**:
   - Stations near major public transit stations (like Union Station) and tourist attractions (such as Navy Pier) show higher traffic. This indicates that many users might be combining bike-share with public transit or using bikes to visit popular destinations.

5. **Rush Hour Patterns**:
   - Combining these observations with those of the 'Trips by Day-Hour' visualization, the higher usage at stations near public transit hubs confirms the morning and evening rush hour peaks, consistent with commuter usage.

![Station Congestion in July 2019](Assets/Vizzes/StationCongestion_July2019.png)

When I ranked the stations by the 'Number of Trips per Dock' I discovered that the Top ranked stations below match with the above observation.

Top 10 Stations with High number of Trips per Dock 
(*with trip count higher than the average of trips per station*)

| Rank | Name                           | Count | Docks | Trips per Dock |
|------|--------------------------------|-------|-------|----------------|
| 1    | Clinton St & Madison St        | 25543 | 31    | 823            |
| 2    | Clinton St & Washington Blvd   | 24066 | 31    | 776            |
| 3    | Michigan Ave & Oak St          | 16285 | 22    | 740            |
| 4    | Streeter Dr & Grand Ave        | 33779 | 46    | 734            |
| 5    | Fairbanks Ct & Grand Ave       | 10622 | 15    | 708            |
| 6    | Canal St & Adams St            | 29351 | 47    | 624            |
| 7    | Wells St & Concord Ln          | 11053 | 19    | 581            |
| 8    | Rush St & Cedar St             | 6332  | 11    | 575            |
| 9    | St. Clair St & Erie St         | 10220 | 18    | 567            |
| 10   | Lake Shore Dr & Monroe St      | 21408 | 39    | 548            |

---
**Recommendations**

1. **Dynamic Pricing**:
   - Implement dynamic pricing that increases during peak usage times (e.g., rush hours) and decreases during off-peak times to balance the load and maximize revenue.

2. **Seasonal Promotions**:
   - Offer seasonal promotions or discounts during the off-peak seasons (winter months) to encourage usage despite less favorable weather conditions.

3. **Expand Dock Stations**:
   - Increase the number of docks and bikes at consistently high-traffic stations in downtown Chicago to meet demand and reduce congestion.

**Let us explore the 3rd recommendation, Expand Dock Stations, furthur.**

It is economical to reduce the number of docks at certain stations having very low trips per dock and shift those docks to the stations with a very high number of trips per dock. For the purpose, I calculated the statistics for the number of docks per station for all the 611 stations.

**Number of docks per station**
| Statistic | Value |
|-----------|-------|
| Average   | 17    |
| Median    | 15    |
| Minimum   | 7     |
| Maximum   | 55    |

Let us not touch the stations with less than 15 docks and try to find out stations having way more than 15 docks and significantly fewer trips per dock. For the purpose, I used a scatterplot.

![alt text](Assets/Vizzes/DocksToRemove.png)

The scatterplot provided displays the relationship between the number of trips and the number of docks at various Divvy bike stations. Each point represents a station.The color gradient from yellow to red indicates the trips per dock, with red representing a higher number of trips per dock and bright yellow indicating a lower number of trips per dock.

**Observations**
1. **High Docks, Low Trips**: \
The highlighted area shows stations with a relatively high number of docks (30-55) but a low number of trips. These stations have an excess of docks compared to the demand.
2. **Trip Density**: \
 The color intensity helps identify stations with higher or lower utilization rates, i.e., trips per dock. Stations with more intense colors have fewer trips per dock, indicating underutilization.

**Recommendations**
1. **Reduce Docks in Low-Utilization Areas**: \
Stations in the highlighted area should have docks reduced, as these are underutilized.
2. **Reallocate Docks to High-Utilization Areas**: \
Move docks from underutilized stations to those with high trip counts and fewer docks to balance supply and demand.
3. **Monitor and Adjust**: \
Continuously monitor station usage patterns to make dynamic adjustments to dock allocations based on real-time data.

**Below are the top 5 candidates for docks redistribuion.**

**Top 5 Stations with High Number of Docks and Low Trips per Dock**

| Rank | Station                      | Trips | Docks | Trips per Dock |
|------|------------------------------|-------|-------|----------------|
| 1    | Field Museum                 | 4,744 | 55    | 86             |
| 2    | Wabash Ave and 16th St       | 4,592 | 39    | 118            |
| 3    | Canal St and Jackson Blvd    | 5,651 | 47    | 120            |
| 4    | Michigan Ave and 8th St      | 6,565 | 43    | 152            |
| 5    | Ravenswood Ave and Lawrence Ave | 7,226 | 46    | 157            |

This approach ensures that the Divvy system can better match supply with demand, enhancing user experience, reducing congestion, and optimizing the use of infrastructure.

### Seasonal and Weather Patterns