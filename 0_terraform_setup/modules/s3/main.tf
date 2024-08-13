terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "snowflake-labs/snowflake"
    }
  }
}

resource "aws_s3_bucket" "aws_s3_bucket_resource" {
   bucket       = "${var.aws_s3_bucket_name}${var.environment == "prod" ? "" : "-${var.environment}"}"
   tags = {
    Name        = var.aws_s3_bucket_tag_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "aws_s3_bucket_ownership_controls_resource" {
  bucket = aws_s3_bucket.aws_s3_bucket_resource.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "aws_s3_bucket_acl_resource" {
  depends_on = [
    aws_s3_bucket_ownership_controls.aws_s3_bucket_ownership_controls_resource
  ]

  bucket = aws_s3_bucket.aws_s3_bucket_resource.id
  acl    = "private"
}

resource "aws_s3_object" "csv_object" {
  depends_on = [
    aws_s3_bucket.aws_s3_bucket_resource
  ]
  bucket = aws_s3_bucket.aws_s3_bucket_resource.bucket
  key    = var.csv_file_name
  source = "${var.path_to_file}/${var.csv_file_name}"
  etag = filemd5("${var.path_to_file}/${var.csv_file_name}")
}