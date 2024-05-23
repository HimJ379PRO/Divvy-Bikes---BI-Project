--  Top Stations by number of Trips per Dock
WITH trips_per_station AS (
(SELECT COUNT(trip_id) AS trips_per_station FROM trips GROUP BY from_station_id))

SELECT name, COUNT(trip_id), docks, COUNT(trip_id)/docks AS trips_per_dock, ROUND(AVG(COUNT(trip_id)/docks) OVER()) AS avg_trips_per_dock
FROM trips
JOIN stations ON stations.id = trips.from_station_id
GROUP BY name, docks
HAVING COUNT(trip_id) > (SELECT AVG(trips_per_station) FROM trips_per_station)
ORDER BY trips_per_dock DESC, docks
LIMIT 10


-- SEASONAL ANALYSIS

-- Create seasons View
CREATE VIEW seasons AS(
SELECT 
	*, 
	CASE WHEN DATE_PART('month',start_time) < 3 OR DATE_PART('month',start_time) = 12 THEN 'Winter'
	WHEN DATE_PART('month',start_time) < 5 THEN 'Spring'
	WHEN DATE_PART('month',start_time) < 8 THEN 'Summer'
	ELSE 'Fall'
	END AS season
FROM trips)

-- Top 5 Stations with High number of Trips Started in Summer.
SELECT name, COUNT(trip_id) AS trips, docks, COUNT(trip_id)/docks AS trips_per_dock
FROM seasons
JOIN stations 
	ON stations.id = seasons.from_station_id
WHERE season = 'Summer'
GROUP BY name, docks
ORDER BY COUNT(trip_id) DESC
LIMIT 5;

-- Top 5 Stations with High number of Trips Started in Fall.
SELECT name, COUNT(trip_id) AS trips, docks, COUNT(trip_id)/docks AS trips_per_dock
FROM seasons
JOIN stations 
	ON stations.id = seasons.from_station_id
WHERE season = 'Fall'
GROUP BY name, docks
ORDER BY COUNT(trip_id) DESC
LIMIT 5;

-- Top 5 Stations with High number of Trips Started in Winter.
SELECT name, COUNT(trip_id) AS trips, docks, COUNT(trip_id)/docks AS trips_per_dock
FROM seasons
JOIN stations 
	ON stations.id = seasons.from_station_id
WHERE season = 'Winter'
GROUP BY name, docks
ORDER BY COUNT(trip_id) DESC
LIMIT 5;

-- Top 5 Stations with High number of Trips Started in Spring.
SELECT name, COUNT(trip_id) AS trips, docks, COUNT(trip_id)/docks AS trips_per_dock
FROM seasons
JOIN stations 
	ON stations.id = seasons.from_station_id
WHERE season = 'Spring'
GROUP BY name, docks
ORDER BY COUNT(trip_id) DESC
LIMIT 5;

-- Top 5 Stations with Low number of Trips per Dock Started in Summer.
SELECT name, COUNT(trip_id) AS trips, docks, COUNT(trip_id)/docks AS trips_per_dock
FROM seasons
JOIN stations 
	ON stations.id = seasons.from_station_id
WHERE season = 'Summer' AND docks > 30
GROUP BY name, docks
ORDER BY trips_per_dock
LIMIT 5;

-- Top 5 Stations with Low number of Trips per Dock Started in Fall.
SELECT name, COUNT(trip_id) AS trips, docks, COUNT(trip_id)/docks AS trips_per_dock
FROM seasons
JOIN stations 
	ON stations.id = seasons.from_station_id
WHERE season = 'Fall' AND docks > 30
GROUP BY name, docks
ORDER BY trips_per_dock
LIMIT 5;
