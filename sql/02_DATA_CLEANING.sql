-- Bluebikes 2025 data preparation
-- The raw trips table is left unchanged. Views are used for each analysis need.


-- Rides that started during 2025
-- 33 records fall outside the 2025 calendar year.

CREATE OR REPLACE VIEW trips_2025 AS
SELECT *
FROM trips
WHERE started_at >= '2025-01-01'
  AND started_at < '2026-01-01';

SELECT COUNT(*) AS trips_2025_rows
FROM trips_2025;

-- Expected: 4,614,267


-- Duration analysis
-- Excludes 51 rides with non-positive durations and 2,839 rides
-- longer than 24 hours with no recorded end station.

CREATE OR REPLACE VIEW trips_2025_duration_clean AS
SELECT *
FROM trips_2025
WHERE ended_at > started_at
  AND NOT (
      EXTRACT(EPOCH FROM (ended_at - started_at)) / 60 > 1440
      AND end_station_name IS NULL
  );

SELECT COUNT(*) AS duration_clean_rows
FROM trips_2025_duration_clean;

-- Expected: 4,611,377


-- Start-station analysis
-- Rides without a start station remain available in trips_2025
-- for analyses that do not require station information.

CREATE OR REPLACE VIEW trips_2025_start_station AS
SELECT *
FROM trips_2025
WHERE start_station_name IS NOT NULL;

SELECT COUNT(*) AS start_station_rows
FROM trips_2025_start_station;

-- Expected: 4,612,593


-- End-station analysis
-- A station name is sufficient for the station-level analysis,
-- so records with a missing station ID are retained.

CREATE OR REPLACE VIEW trips_2025_end_station AS
SELECT *
FROM trips_2025
WHERE end_station_name IS NOT NULL;

SELECT COUNT(*) AS end_station_rows
FROM trips_2025_end_station;

-- Expected: 4,606,878