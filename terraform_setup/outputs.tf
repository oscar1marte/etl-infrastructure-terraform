output "aws_s3_bucket_name" {
  description = ""
  value       = module.s3.aws_s3_bucket_name
}

output "aws_s3_key_name" {
  description = ""
  value       = module.s3.aws_s3_key_name
}

output "aws_secrets_manager" {
  description = ""
  value       = module.secrets_manager.aws_secrets_manager
}

output "aws_glue_role_name" {
  description = ""
  value       = module.iam.aws_glue_role_name
}

output "etl_script_name" {
  description = ""
  value       = module.s3.etl_script_name
}

output "external_python_module_name" {
  description = ""
  value       = module.s3.external_python_module_name
}

output "secret_snowflake_creds_name" {
  description = ""
  value       = module.secrets_manager.secret_snowflake_creds_name
}