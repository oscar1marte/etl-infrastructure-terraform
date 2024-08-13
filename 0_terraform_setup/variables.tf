variable "environment" {
  description = "Specifies the deployment environment (e.g., development, staging, production)."
  type        = string
}

variable "snowflake_account" {
  description = "Snowflake account identifier, usually in the format <account_name>.<region>."
  type        = string
  sensitive   = true
}

variable "snowflake_username" {
  description = "Username used for authentication to the Snowflake account."
  type        = string
  sensitive   = true
}

variable "snowflake_password" {
  description = "Password used for authentication to the Snowflake account."
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role that determines the set of permissions available to the user."
  type        = string
}

variable "snowflake_host" {
  description = "Host URL for connecting to the Snowflake account, typically in the format <account>.snowflakecomputing.com."
  type        = string
  sensitive   = true
}

variable "snowflake_warehouse" {
  description = "Name of the Snowflake virtual warehouse used for query execution."
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed, such as us-west-2."
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key for programmatic access to AWS resources."
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key for programmatic access to AWS resources."
  type        = string
  sensitive   = true
}

variable "aws_s3_bucket_name" {
  description = "Name of the AWS S3 bucket used for storing files."
  type        = string
}

variable "aws_s3_bucket_tag_name" {
  description = "Tag name assigned to the AWS S3 bucket for identification and filtering."
  type        = string
}

variable "csv_file_name" {
  description = "Name of the CSV file to be processed and loaded into Snowflake."
  type        = string
}

variable "snowflake_database_name" {
  description = "Name of the Snowflake database where data will be loaded."
  type        = string
}

variable "snowflake_schema_name" {
  description = "Name of the schema within the Snowflake database where data will be loaded."
  type        = string
}

variable "snowflake_user_role_name" {
  description = "Name of the role assigned to the user in Snowflake, which defines their access rights."
  type        = string
}

variable "snowflake_user_name" {
  description = "Name of the user in Snowflake who will execute the operations."
  type        = string
}

variable "snowflake_stage_name" {
  description = "Name of the Snowflake stage used for staging files before loading into tables."
  type        = string
}