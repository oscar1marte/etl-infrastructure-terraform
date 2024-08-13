output "aws_secrets_manager" {
  description = ""
  value       = aws_secretsmanager_secret_version.secretsmanager_resource.id
}

output "secret_snowflake_creds_name" {
  description = ""
  value       = aws_secretsmanager_secret.snowflake_creds.name
}
