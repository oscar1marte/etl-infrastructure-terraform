variable "environment" {
  description = "Defines the deployment environment, such as dev, stage, or prod."
  type        = string
}

variable "snowflake_database_name" {
  description = "The name of the Snowflake database that will be targeted for operations."
  type        = string
}

variable "snowflake_schema_name" {
  description = "The schema within the Snowflake database where data will be stored or queried."
  type        = string
}

variable "snowflake_user_role_name" {
  description = "The role in Snowflake that determines the access level and permissions for the user."
  type        = string
}

variable "snowflake_user_name" {
  description = "The name of the user in Snowflake responsible for executing database operations."
  type        = string
}

variable "snowflake_warehouse" {
  description = "The virtual warehouse in Snowflake used for running queries and processing data."
  type        = string
}

variable "snowflake_stage_name" {
  description = "The name of the Snowflake stage used for temporarily storing files before loading them into tables."
  type        = string
}
