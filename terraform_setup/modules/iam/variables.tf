variable "aws_glue_role_name" {
  description = "The name of the IAM role that AWS Glue will assume to execute the ETL job."
  type        = string
}

variable "aws_s3_bucket_name" {
  description = "The name of the AWS S3 bucket where data files are stored or retrieved for processing."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the S3 bucket, Glue service, and other resources are located."
  type        = string
}

variable "snowflake_secrets_manager" {
  description = "The name or ARN of the AWS Secrets Manager secret that stores credentials for accessing Snowflake."
  type        = string
}
