output "bucket_name" {
  value = aws_s3_bucket.taxi_data.id
}

output "athena_location" {
  value = "s3://${aws_s3_bucket.taxi_data.id}/nyc-taxi/yellow/"
}

output "athena_results_location" {
  value = "s3://${aws_s3_bucket.athena_results.id}/"
}

output "sagemaker_role_arn" {
  value = aws_iam_role.sagemaker_execution.arn
}

output "training_data_location" {
  value = "s3://${aws_s3_bucket.training_data.id}/"
}