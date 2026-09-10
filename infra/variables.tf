variable "aws_region" {
  default = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "local_data_dir" {
  description = "Local directory containing the downloaded Parquet files"
  type        = string
  default     = "../data"
}