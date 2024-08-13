terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_secretsmanager_secret" "snowflake_creds" {
  name = var.snowflake_secrets_manager
}

locals {
  snowflake_creds = {
    username          = var.snowflake_username
    password          = var.snowflake_password
    account           = var.snowflake_account
    warehouse         = var.snowflake_warehouse
    database          = var.snowflake_database
    schema            = "${var.snowflake_schema}_${upper(var.environment)}"
    stage             = var.snowflake_stage
  }
}

resource "aws_secretsmanager_secret_version" "secretsmanager_resource" {
  secret_id     = aws_secretsmanager_secret.snowflake_creds.id
  secret_string = jsonencode(local.snowflake_creds)
}