data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "taxi_data" {
  bucket        = "nyc-taxi-project-${data.aws_caller_identity.current.account_id}"
  force_destroy = true   # allow `terraform destroy`
}

resource "aws_s3_bucket_lifecycle_configuration" "taxi_data_expiry" {
  bucket = aws_s3_bucket.taxi_data.id
  rule {
    id     = "expire-taxi-data"
    status = "Enabled"
    filter {}
    expiration { days = 7 }   
  }
}
# Upload *.parquet files to the bucket
resource "aws_s3_object" "taxi_files" {
  for_each = fileset(var.local_data_dir, "*.parquet")

  bucket = aws_s3_bucket.taxi_data.id
  key    = "nyc-taxi/yellow/${each.value}"
  source = "${var.local_data_dir}/${each.value}"
  etag   = filemd5("${var.local_data_dir}/${each.value}")  # re-upload on change
}

resource "aws_s3_bucket" "athena_results" {
  bucket        = "nyc-taxi-athena-results-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results_expiry" {
  bucket = aws_s3_bucket.athena_results.id
  rule {
    id     = "expire-athena-results"
    status = "Enabled"
    filter {}
    expiration { days = 7 }
  }
}

# training data bucket:
resource "aws_s3_bucket" "training_data" {
  bucket        = "nyc-taxi-training-data-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "training_data_expiry" {
  bucket = aws_s3_bucket.training_data.id
  rule {
    id     = "expire-training-data"
    status = "Enabled"
    filter {}
    expiration { days = 7 }
  }
}