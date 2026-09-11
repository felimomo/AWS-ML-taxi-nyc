CREATE EXTERNAL TABLE taxi_data (
    VendorID INT,
    tpep_pickup_datetime TIMESTAMP,
    tpep_dropoff_datetime TIMESTAMP,
    passenger_count BIGINT,
    trip_distance DOUBLE,
    PULocationID INT,
    DOLocationID INT,
    payment_type BIGINT,
    fare_amount DOUBLE,
    tip_amount DOUBLE
)
STORED AS PARQUET
LOCATION '{taxi_bucket_location}'; 
-- dynamic bucket location. Use string formatting in PyAthena API.

WITH hourly_agg AS (
    SELECT
        PULocationID,
        date_trunc('hour', tpep_pickup_datetime) AS pickup_hour,
        count(*) AS trip_count
    FROM taxi_data
    GROUP BY PULocationID, date_trunc('hour', tpep_pickup_datetime);
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
    ) AS lag_3_trip_count,
FROM hourly_counts