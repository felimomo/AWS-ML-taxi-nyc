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
LOCATION 's3://your-bucket/nyc-taxi/yellow/';

SELECT
    PULocationID,
    date_trunc('hour', tpep_pickup_datetime) AS pickup_hour,
    count(*) AS trip_count
FROM taxi_data
GROUP BY PULocationID, date_trunc('hour', tpep_pickup_datetime);