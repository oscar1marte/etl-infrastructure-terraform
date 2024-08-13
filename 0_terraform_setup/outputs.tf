output "aws_s3_bucket_name" {
  description = ""
  value       = module.s3.aws_s3_bucket_name
}

output "csv_object_name" {
  description = ""
  value       = module.s3.csv_object_name
}

output "snowflake_database_name" {
  description = ""
  value       = module.snowflake.snowflake_database_name
}

output "snowflake_schema_name" {
  description = ""
  value       = module.snowflake.snowflake_schema_name
}

output "snowflake_user_name" {
  description = ""
  value       = module.snowflake.snowflake_user_name
  sensitive   = true
}

output "snowflake_user_password" {
  description = ""
  value       = module.snowflake.snowflake_user_password
  sensitive   = true
}

output "snowfloke_show_output" {
  description = ""
  value       = module.snowflake.snowfloke_show_output
}