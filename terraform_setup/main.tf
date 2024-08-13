module "s3" {
  source                     = "./modules/s3"
  environment                = var.environment
  aws_s3_bucket_name         = var.aws_s3_bucket_name
  csv_object_name            = var.csv_object_name
  aws_etl_script             = var.aws_etl_script
  external_python_module     = var.external_python_module
}

module "secrets_manager" {
  source                     = "./modules/secrets_manager"
  snowflake_secrets_manager  = var.snowflake_secrets_manager
  snowflake_username         = var.snowflake_username
  snowflake_password         = var.snowflake_password
  snowflake_account          = var.snowflake_account
  snowflake_warehouse        = var.snowflake_warehouse
  snowflake_database         = var.snowflake_database
  snowflake_schema           = var.snowflake_schema
  snowflake_role             = var.snowflake_role
  environment                = var.environment
  snowflake_stage            = var.snowflake_stage
}

module "iam" {
  source                     = "./modules/iam"
  aws_glue_role_name         = var.aws_glue_role_name
  aws_s3_bucket_name         = var.aws_s3_bucket_name
  aws_region                 = var.aws_region
  snowflake_secrets_manager  = var.snowflake_secrets_manager
}

module "glue" {
  depends_on                 = [
    module.iam,
    module.secrets_manager
  ]
  source                     = "./modules/glue"
  aws_s3_bucket_name         = var.aws_s3_bucket_name
  aws_etl_script             = var.aws_etl_script
  external_python_module     = var.external_python_module
  aws_glue_role_arn          = module.iam.aws_glue_role_arn
  etl_job_name               = var.etl_job_name
  snowflake_secrets_manager  = module.secrets_manager.secret_snowflake_creds_name
  aws_region                 = var.aws_region
  csv_object_name            = var.csv_object_name
}