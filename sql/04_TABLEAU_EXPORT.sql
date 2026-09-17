-- Bluebikes 2025 Tableau exports
-- Each query produces the dataset used by a Tableau worksheet.


-- Monthly ridership by customer type

SELECT
    EXTRACT(MONTH FROM started_at)::int AS month,
    member_casual,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY
    month,
    member_casual
ORDER BY
    month,
    member_casual;


-- Hourly ridership by customer type

SELECT
    EXTRACT(HOUR FROM started_at)::int AS hour_of_day,
    member_casual,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY
    hour_of_day,
    member_casual
ORDER BY
    hour_of_day,
    member_casual;


-- Weekly ridership by customer type

SELECT
    EXTRACT(ISODOW FROM started_at)::int AS day_number,
    TO_CHAR(started_at, 'Dy') AS day_of_week,
    member_casual,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY
    day_number,
    day_of_week,
    member_casual
ORDER BY
    day_number,
    member_casual;


-- Demand by day and hour

SELECT
    EXTRACT(ISODOW FROM started_at)::int AS day_number,
    TO_CHAR(started_at, 'Dy') AS day_of_week,
    EXTRACT(HOUR FROM started_at)::int AS hour_of_day,
    member_casual,
    COUNT(*) AS total_rides
FROM trips_2025
GROUP BY
    day_number,
    day_of_week,
    hour_of_day,
    member_casual
ORDER BY
    day_number,
    hour_of_day,
    member_casual;


-- Starting-station demand
-- Used for both the station ranking and map.

SELECT
    start_station_id,
    start_station_name,
    member_casual,
    AVG(start_lat) AS station_lat,
    AVG(start_lng) AS station_lng,
    COUNT(*) AS total_rides
FROM trips_2025_start_station
WHERE start_station_id IS NOT NULL
GROUP BY
    start_station_id,
    start_station_name,
    member_casual
ORDER BY total_rides DESC;


-- Average and median trip duration
-- Uses the same cleaned duration records as the SQL analysis.

SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS total_rides,
    ROUND(
        AVG(duration_minutes)::numeric,
        1
    ) AS average_duration_minutes,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY duration_minutes)::numeric,
        1
    ) AS median_duration_minutes
FROM (
    SELECT
        member_casual,
        rideable_type,
        EXTRACT(EPOCH FROM (ended_at - started_at)) / 60
            AS duration_minutes
    FROM trips_2025_duration_clean
) AS valid_trips
GROUP BY
    member_casual,
    rideable_type
ORDER BY
    member_casual,
    rideable_type;


-- Top 10 directional routes
-- Trips that start and end at the same station are excluded.

SELECT
    start_station_name,
    end_station_name,
    start_station_name || ' → ' || end_station_name AS route,
    COUNT(*) AS total_rides
FROM trips_2025
WHERE start_station_name IS NOT NULL
  AND end_station_name IS NOT NULL
  AND start_station_name <> end_station_name
GROUP BY
    start_station_name,
    end_station_name
ORDER BY total_rides DESC
LIMIT 10;


-- Dashboard KPI summary

SELECT
    COUNT(*) AS total_rides,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE member_casual = 'member'
        ) / COUNT(*),
        1
    ) AS member_share_percent,

    ROUND(
        COUNT(*)::numeric
        / COUNT(DISTINCT DATE(started_at))
    ) AS average_daily_rides,

    COUNT(DISTINCT start_station_id) AS active_stations

FROM trips_2025;

-- Total rides: 4,614,267
-- Member share: 71.4%
-- Average daily rides: 12,642
-- Active stations: 602