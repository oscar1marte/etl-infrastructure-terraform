module "s3" {
  source                  = "./modules/s3"
  environment             = var.environment
  aws_s3_bucket_name      = var.aws_s3_bucket_name
  aws_s3_bucket_tag_name  = var.aws_s3_bucket_tag_name
  csv_file_name           = var.csv_file_name
}

module "snowflake" {
  source                  = "./modules/snowflake"
  environment             = var.environment
  snowflake_database_name = var.snowflake_database_name
  snowflake_schema_name   = var.snowflake_schema_name
  snowflake_user_role_name= var.snowflake_user_role_name
  snowflake_user_name     = var.snowflake_user_name
  snowflake_warehouse     = var.snowflake_warehouse
  snowflake_stage_name    = var.snowflake_stage_name
}

module "credential" {
  depends_on              = [module.snowflake]
  source                  = "./modules/credential"
  snowflake_user_name     = module.snowflake.snowflake_user_name
  snowflake_user_password = module.snowflake.snowflake_user_password
}