for m in 1 2 3 4 5 6; do
  curl -sI https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-0$m.parquet | grep -i content-length >> data_size.txt
done