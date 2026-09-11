WITH hourly_counts AS (
    SELECT
        PULocationID,
        date_trunc('hour', tpep_pickup_datetime) AS pickup_hour,
        count(*) AS trip_count
    FROM taxi_data
    GROUP BY PULocationID, date_trunc('hour', tpep_pickup_datetime)
) SELECT *, -- windowed lags for prediction
    LAG(trip_count, 1) OVER (
        PARTITION BY PULocationID
        ORDER BY pickup_hour
    ) AS lag_1_trip_count,
    LAG(trip_count, 2) OVER (
        PARTITION BY PULocationID
        ORDER BY pickup_hour
    ) AS lag_2_trip_count,
    LAG(trip_count, 3) OVER (
        PARTITION BY PULocationID
        ORDER BY pickup_hour
    ) AS lag_3_trip_count
FROM hourly_counts;