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