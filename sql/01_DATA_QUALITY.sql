-- Bluebikes 2025 data quality checks
-- Run against the raw trips table before creating analysis views.


-- Row count and duplicate ride IDs
-- Expected: 4,614,300 rows and no duplicate ride IDs.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ride_id) AS unique_rides,
    COUNT(*) - COUNT(DISTINCT ride_id) AS duplicate_rides
FROM trips;


-- Missing values in fields used for analysis

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(ride_id) AS missing_ride_id,
    COUNT(*) - COUNT(start_station_name) AS missing_start_station,
    COUNT(*) - COUNT(end_station_name) AS missing_end_station,
    COUNT(*) - COUNT(start_lat) AS missing_start_lat,
    COUNT(*) - COUNT(end_lat) AS missing_end_lat,
    COUNT(*) - COUNT(member_casual) AS missing_member_type
FROM trips;

-- Missing start stations: 1,674
-- Missing end stations: 7,390
-- Missing end coordinates: 2,871


-- Check customer categories

SELECT
    member_casual,
    COUNT(*) AS ride_count
FROM trips
GROUP BY member_casual
ORDER BY ride_count DESC;

-- member: 3,292,987
-- casual: 1,321,313


-- Check bike categories

SELECT
    rideable_type,
    COUNT(*) AS ride_count
FROM trips
GROUP BY rideable_type
ORDER BY ride_count DESC;

-- classic_bike: 3,295,808
-- electric_bike: 1,318,492


-- Ride-duration range in minutes

SELECT
    MIN(EXTRACT(EPOCH FROM (ended_at - started_at)) / 60) AS min_minutes,
    AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) / 60) AS avg_minutes,
    MAX(EXTRACT(EPOCH FROM (ended_at - started_at)) / 60) AS max_minutes
FROM trips;

-- Minimum: -58.83 minutes
-- Average: 16.36 minutes
-- Maximum: 1,559.95 minutes


-- Non-positive durations by date
-- All 51 records occurred on November 2, the daylight-saving transition date.
-- They are excluded from duration analysis rather than manually corrected.

SELECT
    DATE(started_at) AS ride_date,
    COUNT(*) AS non_positive_duration_rides
FROM trips
WHERE ended_at <= started_at
GROUP BY DATE(started_at)
ORDER BY ride_date;


-- Rides longer than 24 hours with no recorded end station
-- These records follow a consistent abnormal pattern and are excluded
-- from duration analysis. Long rides with an end station are retained.

SELECT
    COUNT(*) AS long_rides_missing_end_station
FROM trips
WHERE EXTRACT(EPOCH FROM (ended_at - started_at)) / 60 > 1440
  AND end_station_name IS NULL;

-- Raw table: 2,840
-- 2025 analysis period: 2,839


-- Records outside the analysis period
-- A ride is assigned to a year based on its start time.

SELECT
    COUNT(*) AS rides_outside_2025
FROM trips
WHERE started_at < '2025-01-01'
   OR started_at >= '2026-01-01';

-- Expected: 33


-- Check whether start station names and IDs are missing together

SELECT
    COUNT(*) FILTER (
        WHERE start_station_name IS NULL
          AND start_station_id IS NOT NULL
    ) AS missing_name_only,

    COUNT(*) FILTER (
        WHERE start_station_name IS NOT NULL
          AND start_station_id IS NULL
    ) AS missing_id_only,

    COUNT(*) FILTER (
        WHERE start_station_name IS NULL
          AND start_station_id IS NULL
    ) AS missing_both
FROM trips;

-- All 1,674 records with a missing start station name
-- also have a missing start station ID.


-- Check whether end station names and IDs are missing together

SELECT
    COUNT(*) FILTER (
        WHERE end_station_name IS NULL
          AND end_station_id IS NOT NULL
    ) AS missing_name_only,

    COUNT(*) FILTER (
        WHERE end_station_name IS NOT NULL
          AND end_station_id IS NULL
    ) AS missing_id_only,

    COUNT(*) FILTER (
        WHERE end_station_name IS NULL
          AND end_station_id IS NULL
    ) AS missing_both
FROM trips;

-- 549 records have a station name but no station ID.
-- They are retained because the name is sufficient for this analysis.


-- Check whether missing end coordinates also have a missing station

SELECT
    COUNT(*) FILTER (
        WHERE end_lat IS NULL
          AND end_station_name IS NULL
    ) AS missing_coord_and_station,

    COUNT(*) FILTER (
        WHERE end_lat IS NULL
          AND end_station_name IS NOT NULL
    ) AS missing_coord_but_has_station
FROM trips;

-- All 2,871 missing end coordinates also have a missing end station.


-- Coordinate ranges

SELECT
    MIN(start_lat) AS min_start_lat,
    MAX(start_lat) AS max_start_lat,
    MIN(start_lng) AS min_start_lng,
    MAX(start_lng) AS max_start_lng,
    MIN(end_lat) AS min_end_lat,
    MAX(end_lat) AS max_end_lat,
    MIN(end_lng) AS min_end_lng,
    MAX(end_lng) AS max_end_lng
FROM trips;

-- No obviously invalid geographic values were found.
