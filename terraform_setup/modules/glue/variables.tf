variable "aws_etl_script" {
  description = "The name or path of the ETL script that will be executed by AWS Glue."
  type        = string
}

variable "external_python_module" {
  description = "The external Python module required by the ETL script, such as the Snowflake connector or other dependencies."
  type        = string
}

variable "aws_s3_bucket_name" {
  description = "The name of the AWS S3 bucket where the CSV object is stored or will be uploaded."
  type        = string
}

variable "aws_glue_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role that AWS Glue will assume to execute the ETL job."
  type        = string
}

variable "etl_job_name" {
  description = "The name assigned to the ETL job that will be executed in AWS Glue."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources, such as S3, Glue, and Secrets Manager, are deployed."
  type        = string
}

variable "snowflake_secrets_manager" {
  description = "The name or ARN of the AWS Secrets Manager secret that stores Snowflake credentials."
  type        = string
}

variable "csv_object_name" {
  description = "The name of the CSV object in the S3 bucket that will be processed."
  type        = string
}
