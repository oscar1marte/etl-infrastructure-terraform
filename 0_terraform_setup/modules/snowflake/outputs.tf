output "snowflake_database_name" {
  description = ""
  value       = snowflake_database.database_resource.name
}

output "snowflake_schema_name" {
  description = ""
  value       = snowflake_schema.schema_resource.name
}

output "snowflake_user_name" {
  description = ""
  value       = snowflake_user.user_resource.name
  sensitive   = true
}

output "snowflake_user_password" {
  description = ""
  value       = snowflake_user.user_resource.password
  sensitive   = true
}

output "snowfloke_show_output" {
  description = ""
  value       = snowflake_account_role.snowflake_account_role_resource.show_output
}