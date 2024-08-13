terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "cloudwatch-etl-glue-job"
  retention_in_days = 1
}

resource "aws_glue_job" "etl_glue_job" {
  depends_on                 = [
    aws_cloudwatch_log_group.cloudwatch_log_group
  ]
  name              = var.etl_job_name
  role_arn          = var.aws_glue_role_arn

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  command {
    script_location = "s3://${var.aws_s3_bucket_name}/${var.aws_etl_script}"
  }
  default_arguments = {
    "--additional-python-modules"        = "s3://${var.aws_s3_bucket_name}/${var.external_python_module},pyarrow==8.0.0,pandas"
    "--secret_name"                      = var.snowflake_secrets_manager
    "--region_name"                      = var.aws_region
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.cloudwatch_log_group.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
    "--bucket_name"                      = var.aws_s3_bucket_name
    "--file_key"                         = var.csv_object_name
  }
}