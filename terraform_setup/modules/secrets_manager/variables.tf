variable "snowflake_secrets_manager" {
  description = "The name or ARN of the AWS Secrets Manager secret that stores Snowflake credentials."
  type        = string
}

variable "snowflake_username" {
  description = "The username for authenticating with the Snowflake account."
  type        = string
  sensitive   = true
}

variable "snowflake_password" {
  description = "The password associated with the Snowflake username for authentication."
  type        = string
  sensitive   = true
}

variable "snowflake_account" {
  description = "The Snowflake account identifier, typically in the format <account_name>.<region>."
  type        = string
  sensitive   = true
}

variable "snowflake_warehouse" {
  description = "The Snowflake virtual warehouse used for query execution and data processing."
  type        = string
  sensitive   = true
}

variable "snowflake_database" {
  description = "The name of the Snowflake database where data will be stored or queried."
  type        = string
  sensitive   = true
}

variable "snowflake_schema" {
  description = "The name of the schema within the Snowflake database where data will be organized."
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "The Snowflake role that defines access permissions for the user."
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Specifies the deployment environment, such as dev, stage, or prod."
  type        = string
}

variable "snowflake_stage" {
  description = "The name of the Snowflake stage used for staging files before loading into tables."
  type        = string
}
