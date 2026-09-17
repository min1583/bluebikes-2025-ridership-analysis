-- Bluebikes 2025 KPI analysis
-- Uses the analysis views created in 02_data_cleaning.sql.


-- Overall ridership

SELECT COUNT(*) AS total_rides
FROM trips_2025;

-- 4,614,267 rides


SELECT
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM trips_2025
GROUP BY member_casual
ORDER BY total_rides DESC;

-- member: 3,292,977 (71.37%)
-- casual: 1,321,290 (28.63%)


SELECT
    rideable_type,
    COUNT(*) AS total_rides,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM trips_2025
GROUP BY rideable_type
ORDER BY total_rides DESC;

-- classic_bike: 3,295,785 (71.43%)
-- electric_bike: 1,318,482 (28.57%)


-- Time-based ridership patterns

SELECT
    EXTRACT(MONTH FROM started_at) AS month,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY EXTRACT(MONTH FROM started_at)
ORDER BY month;


SELECT
    TO_CHAR(started_at, 'Day') AS day_of_week,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY
    TO_CHAR(started_at, 'Day'),
    EXTRACT(DOW FROM started_at)
ORDER BY EXTRACT(DOW FROM started_at);


SELECT
    CASE
        WHEN EXTRACT(DOW FROM started_at) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY day_type
ORDER BY day_type;

-- Weekday: 3,427,856
-- Weekend: 1,186,411


SELECT
    EXTRACT(HOUR FROM started_at) AS hour,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY EXTRACT(HOUR FROM started_at)
ORDER BY hour;


-- Customer behavior over time

SELECT
    EXTRACT(MONTH FROM started_at) AS month,
    member_casual,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY
    EXTRACT(MONTH FROM started_at),
    member_casual
ORDER BY
    month,
    member_casual;


SELECT
    EXTRACT(HOUR FROM started_at) AS hour,
    member_casual,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY
    EXTRACT(HOUR FROM started_at),
    member_casual
ORDER BY
    hour,
    member_casual;


SELECT
    CASE
        WHEN EXTRACT(DOW FROM started_at) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    member_casual,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY
    day_type,
    member_casual
ORDER BY
    day_type,
    member_casual;


-- Bike usage by customer type

SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY
    member_casual,
    rideable_type
ORDER BY
    member_casual,
    rideable_type;


-- Ride duration
-- Duration metrics use the cleaned duration view.

SELECT
    ROUND(
        AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) / 60),
        2
    ) AS avg_duration_minutes
FROM trips_2025_duration_clean;

-- Overall average: 15.44 minutes


SELECT
    member_casual,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) / 60),
        2
    ) AS avg_duration_minutes
FROM trips_2025_duration_clean
GROUP BY member_casual
ORDER BY member_casual;

-- casual: 22.59 minutes
-- member: 12.58 minutes


SELECT
    rideable_type,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) / 60),
        2
    ) AS avg_duration_minutes
FROM trips_2025_duration_clean
GROUP BY rideable_type
ORDER BY rideable_type;

-- classic_bike: 15.87 minutes
-- electric_bike: 14.39 minutes


-- Most-used stations

SELECT
    start_station_name,
    COUNT(*) AS total_rides
FROM trips_2025_start_station
GROUP BY start_station_name
ORDER BY total_rides DESC
LIMIT 10;


SELECT
    end_station_name,
    COUNT(*) AS total_rides
FROM trips_2025_end_station
GROUP BY end_station_name
ORDER BY total_rides DESC
LIMIT 10;


-- Top starting stations for casual riders

SELECT
    start_station_name,
    COUNT(*) AS total_rides
FROM trips_2025_start_station
WHERE member_casual = 'casual'
GROUP BY start_station_name
ORDER BY total_rides DESC
LIMIT 10;


-- Top starting stations for members

SELECT
    start_station_name,
    COUNT(*) AS total_rides
FROM trips_2025_start_station
WHERE member_casual = 'member'
GROUP BY start_station_name
ORDER BY total_rides DESC
LIMIT 10;