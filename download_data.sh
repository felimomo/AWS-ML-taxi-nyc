mkdir -p data
for m in 01 02 03 04 05 06; do
  curl -o data/yellow_tripdata_2024-$m.parquet \
    https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-$m.parquet
done