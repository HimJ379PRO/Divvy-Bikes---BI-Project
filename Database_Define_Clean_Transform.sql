-- Define the table 'stations'
CREATE TABLE stations
(
Id INT PRIMARY KEY,
Latitude NUMERIC,
Longitude NUMERIC,
Name VARCHAR(100),
Docks SMALLINT
);

-- Check the data in the table 'stations'
SELECT * 
FROM stations;

-- Create the table 'trips'
CREATE TABLE trips
(
trip_id INT PRIMARY KEY,
start_time TIMESTAMP,
end_time TIMESTAMP,
bikeid INT NOT NULL,
tripduration NUMERIC,
from_station_id INT,
from_station_name VARCHAR(100),
to_station_id INT,
to_station_name VARCHAR(100),
usertype VARCHAR(50),
gender VARCHAR(10),
birthyear INT
);

-- Check the data in the table 'trips'
SELECT * 
FROM trips;

-- Import process failed because the value format in the 'birthyear' column does not match INT
-- Change the data type of birthyear to VARCHAR to manipulate it and convert back to INT
ALTER TABLE trips
ALTER COLUMN birthyear
TYPE VARCHAR(10);

-- Check the data in the table 'trips'
SELECT * 
FROM trips;

-- Import process failed because the value format in the 'tripduration' column does not match NUMERIC
-- Change the data type of birthyear to VARCHAR to manipulate it and convert back to NUMERIC
ALTER TABLE trips
ALTER COLUMN tripduration
TYPE VARCHAR(100);

-- Check the data in the table 'trips'
SELECT * 
FROM trips
LIMIT 20;

-- Use string fns to transform 'tripduration' to NUMERIC format
-- First, test whether we are getting the intended result using TRIP and REPLACE Fns
SELECT TRIM(TRAILING '.0' FROM tripduration) AS test
FROM trips

SELECT REPLACE(tripduration,',','') AS test
FROM trips; 
-- TESTS SUCCESSFUL

-- UPDATE the values in the table 'trips'
UPDATE trips
SET tripduration = TRIM(TRAILING '.0' FROM tripduration);
UPDATE trips
SET tripduration = REPLACE(tripduration,',','')

-- Check the data in the table trips
SELECT * 
FROM trips
LIMIT 20;

-- Convert 'tripduration' data type to NUMERIC
ALTER TABLE trips
ALTER COLUMN tripduration
TYPE NUMERIC USING(tripduration::NUMERIC);

-- Check the data in the table trips
SELECT * 
FROM trips
LIMIT 20;
-- Great, Now we can perform calculations on 'tripduration'

-- Use string fn to transform 'birthyear' to INT format
UPDATE trips
SET birthyear = TRIM(TRAILING '.0' FROM birthyear)

-- Convert 'birthyear' data type to INT
ALTER TABLE trips
ALTER COLUMN birthyear
TYPE INT USING(birthyear::INT);

-- Check the data in the table 'trips'
SELECT * 
FROM trips
LIMIT 20;
-- Great, Now we can perform calculations using 'birthyear'

-- Add [FK] Foreign Key constraints for the columns 'from_station_id' and 'to_station_id'
ALTER TABLE IF EXISTS public.trips
    ADD CONSTRAINT fk_from_station_id FOREIGN KEY (from_station_id)
    REFERENCES public.stations (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;
CREATE INDEX IF NOT EXISTS fki_fk_from_station_id
    ON public.trips(from_station_id);
	
ALTER TABLE IF EXISTS public.trips
    ADD CONSTRAINT fk_to_station_id FOREIGN KEY (to_station_id)
    REFERENCES public.stations (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;
CREATE INDEX IF NOT EXISTS fki_fk_to_station_id
    ON public.trips(to_station_id);

-- Check whether the constraints are working correctly by joining the tables on id columns.
SELECT trip_id, from_station_id, from_station_name, id, name
FROM trips t
JOIN stations s
ON t.from_station_id = s.id
WHERE from_station_id = 35;
-- Great! The [FK] constraints are working correctly.

/* 
DROP the redundunt columns 'from_station_name' and 'to_station_name' 
to follow database design best practices and increase database performance.
*/

ALTER TABLE trips
DROP COLUMN from_station_name,
DROP COLUMN to_station_name;

-- Check the data in the table 'trips'
SELECT * 
FROM trips
LIMIT 20;

-- CLEAN the data
/*
At the Python data prep stage we checked whether we have a trip without the important columns 
'trip_id',' start_time', 'end_time', 'tripduration', 'from_station_id', 'to_station_id'.
Now, we will check whether there is an issue with the values.
*/

-- Review 'tripduration' and remove the trips (records) shorter than 2 minutes.
SELECT bikeid, COUNT(trip_id)
FROM trips
WHERE tripduration < 60 AND from_station_id = to_station_id
GROUP BY bikeid
ORDER BY COUNT(trip_id) DESC

-- Review values in 'usertype' and 'gender'
SELECT DISTINCT usertype, gender
FROM trips
-- The values are correct. 

-- Review values in 'birthyear' and REMOVE or FIX the values smaller than 1900.
SELECT birthyear, usertype, COUNT(birthyear)
FROM trips
GROUP BY birthyear, usertype
HAVING birthyear < 1900;

/* 
Customer Analytics team reached out to customers with birth year values 191 to 199 to check whether
they entered 191 instead of 1991 and so on. The doubt was correct.
*/
-- Update 191 till 199 with 1991 to 1999
UPDATE trips
SET birthyear = 1991
WHERE birthyear = 191;

UPDATE trips
SET birthyear = 1992
WHERE birthyear = 192;

UPDATE trips
SET birthyear = 1993
WHERE birthyear = 193;

UPDATE trips
SET birthyear = 1994
WHERE birthyear = 194;

UPDATE trips
SET birthyear = 1995
WHERE birthyear = 195;

UPDATE trips
SET birthyear = 1996
WHERE birthyear = 196;

UPDATE trips
SET birthyear = 1997
WHERE birthyear = 197;

UPDATE trips
SET birthyear = 1998
WHERE birthyear = 198;

UPDATE trips
SET birthyear = 1999
WHERE birthyear = 199;

-- It was discovered that the users entered incorrect birthyears as they are unwilling to share the information.
-- Remove birthyears before 1900 and replace with NULL
UPDATE trips
SET birthyear = NULL
WHERE birthyear IN (2,19,1759,1888,1889,1899);

SELECT * FROM trips LIMIT 50