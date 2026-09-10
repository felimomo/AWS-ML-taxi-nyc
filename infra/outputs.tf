output "bucket_name" {
  value = aws_s3_bucket.taxi_data.id
}

output "athena_location" {
  value = "s3://${aws_s3_bucket.taxi_data.id}/nyc-taxi/yellow/"
}