terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_s3_object" "csv_file" {
  bucket = var.aws_s3_bucket_name
  key    = var.csv_object_name
}

resource "aws_s3_object" "etl_script_object" {
  bucket = var.aws_s3_bucket_name
  key    = var.aws_etl_script
  source = "${var.path_to_file}/${var.aws_etl_script}"
  etag   = filemd5("${var.path_to_file}/${var.aws_etl_script}")
}

resource "aws_s3_object" "external_python_module_object" {
  bucket = var.aws_s3_bucket_name
  key    = var.external_python_module
  source = "${var.path_to_file}/${var.external_python_module}"
  etag   = filemd5("${var.path_to_file}/${var.external_python_module}")
}