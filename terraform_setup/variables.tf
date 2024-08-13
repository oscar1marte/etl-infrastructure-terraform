variable "environment" {
  description = "Specifies the deployment environment, such as dev, stage, or prod."
  type        = string
}

variable "aws_s3_bucket_name" {
  description = "The name of the AWS S3 bucket where the CSV object is stored or will be uploaded."
  type        = string
}

variable "csv_object_name" {
  description = "The name of the CSV object in the S3 bucket to be processed."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources like S3, Glue, and Secrets Manager are deployed."
  type        = string
}

variable "aws_access_key" {
  description = "The AWS access key for programmatic access to AWS services."
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS secret key for programmatic access to AWS services."
  type        = string
  sensitive   = true
}

variable "snowflake_secrets_manager" {
  description = "The AWS Secrets Manager resource name where Snowflake credentials are stored."
  type        = string
}

variable "snowflake_username" {
  description = "The username for authenticating with Snowflake."
  type        = string
  sensitive   = true
}

variable "snowflake_password" {
  description = "The password associated with the Snowflake username."
  type        = string
  sensitive   = true
}

variable "aws_glue_role_name" {
  description = "The name of the IAM role used by AWS Glue for executing the ETL job."
  type        = string
}

variable "aws_etl_script" {
  description = "The name or path of the ETL script to be run by AWS Glue."
  type        = string
}

variable "external_python_module" {
  description = "The external Python module required for the ETL job, with a default set to the Snowflake connector package."
  type        = string
  default     = "snowflake_connector_python-2.8.3-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
}

variable "etl_job_name" {
  description = "The name of the ETL job to be executed in AWS Glue."
  type        = string
}

variable "snowflake_account" {
  description = "The Snowflake account identifier, typically in the format <account_name>.<region>."
  type        = string
}

variable "snowflake_warehouse" {
  description = "The Snowflake virtual warehouse used for query execution and data processing."
  type        = string
  sensitive   = true
}

variable "snowflake_database" {
  description = "The name of the Snowflake database where data will be loaded or queried."
  type        = string
  sensitive   = true
}

variable "snowflake_schema" {
  description = "The name of the schema within the Snowflake database where data will be stored."
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "The Snowflake role that defines access permissions for the user."
  type        = string
  sensitive   = true
}

variable "snowflake_stage" {
  description = "The name of the Snowflake stage used for staging files before loading into tables."
  type        = string
}
