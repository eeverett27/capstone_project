-- First, I need to create a table that combines 12 months of trip data  ------------------


CREATE TABLE bike_tripdata_yeartodate.combined_data AS
SELECT *
FROM (
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_Mar`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_Apr`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_May`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_Jun`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_Jul`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_Aug`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_Sep`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_Oct`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_Nov`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2022_Dec`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2023_Jan`
  UNION ALL
  SELECT * FROM `my-project-22728-377914.bike_tripdata_yeartodate.2023_Feb`
  );


-----------------------------------------------------------------------------
--------------------------   THE CLEANING PROCESS   -------------------------
-----------------------------------------------------------------------------


-- Check for duplicates and inconsistancies in ride_id 


SELECT DISTINCT ride_id
FROM bike_tripdata_yeartodate.combined_data;

SELECT COUNT(ride_id)
FROM bike_tripdata_yeartodate.combined_data
WHERE LENGTH(ride_id) = 16;


-- Check the number of types in rideable_type then change docked_bike to classic_bike


SELECT DISTINCT(rideable_type)
FROM bike_tripdata_yeartodate.combined_data;

UPDATE bike_tripdata_yeartodate.combined_data
SET rideable_type = REPLACE(rideable_type, 'docked_bike', 'classic_bike') 
WHERE rideable_type = 'docked_bike';


-- Remove start_station_name, start_station_id, end_station_name, and end_station_id as
-- these data points are irrelevant to our analysis


ALTER TABLE bike_tripdata_yeartodate.combined_data
DROP COLUMN start_station_name, 
DROP COLUMN start_station_id,
DROP COLUMN end_station_name,
DROP COLUMN end_station_id;


-- Extract the day, month, and minutes from the timestamp from started_at and ended_at.
-- Create new colums and populate them with the extracted data accordingly.


ALTER TABLE bike_tripdata_yeartodate.combined_data
ADD COLUMN day_of_week STRING,
ADD COLUMN month STRING;

UPDATE bike_tripdata_yeartodate.combined_data
SET day_of_week = 
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 1 THEN 'Sun'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 2 THEN 'Mon'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 3 THEN 'Tues'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 4 THEN 'Wed'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 5 THEN 'Thur'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 6 THEN 'Fri'
    ELSE'Sat' 
  END
WHERE day_of_week IS NULL;

UPDATE bike_tripdata_yeartodate.combined_data
SET month =
  CASE
    WHEN EXTRACT(MONTH FROM started_at) = 1 THEN 'Jan'
    WHEN EXTRACT(MONTH FROM started_at) = 2 THEN 'Feb'
    WHEN EXTRACT(MONTH FROM started_at) = 3 THEN 'Mar'
    WHEN EXTRACT(MONTH FROM started_at) = 4 THEN 'Apr'
    WHEN EXTRACT(MONTH FROM started_at) = 5 THEN 'May'
    WHEN EXTRACT(MONTH FROM started_at) = 6 THEN 'Jun'
    WHEN EXTRACT(MONTH FROM started_at) = 7 THEN 'July'
    WHEN EXTRACT(MONTH FROM started_at) = 8 THEN 'Aug'
    WHEN EXTRACT(MONTH FROM started_at) = 9 THEN 'Sept'
    WHEN EXTRACT(MONTH FROM started_at) = 10 THEN 'Oct'
    WHEN EXTRACT(MONTH FROM started_at) = 11 THEN 'Nov'
    ELSE 'Dec'
  END
WHERE month IS NULL;


-- ADD a new column named ride_length and populate it with the difference 
-- of ended_at and started_at. Only use ride_length that is >= 1.


ALTER TABLE bike_tripdata_yeartodate.combined_data
ADD COLUMN ride_length INT;

UPDATE bike_tripdata_yeartodate.combined_data
SET ride_length = timestamp_diff(ended_at, started_at, MINUTE)
WHERE ride_length IS NULL;

SELECT ride_length
FROM bike_tripdata_yeartodate.combined_data
WHERE ride_length < 1;

DELETE 
FROM bike_tripdata_yeartodate.combined_data
WHERE ride_length < 1;

-- This statement removed 128,869 rows from combined_data.


--------------------------------------------------------
-----------------   DATA IS CLEAN   --------------------
--------------------------------------------------------

----------------------ANALYSIS-------------------------


--Find the average ride time for members/casual users for a day and for a month,.


SELECT 
member_casual, 
day_of_week, 
ROUND(AVG(ride_length), 0) AS avg_ride_time_minutes,
FROM bike_tripdata_yeartodate.combined_data
GROUP BY member_casual, day_of_week;

SELECT 
member_casual, 
month, 
ROUND(AVG(ride_length), 0) AS avg_ride_time_month,
FROM bike_tripdata_yeartodate.combined_data
GROUP BY member_casual, month;

