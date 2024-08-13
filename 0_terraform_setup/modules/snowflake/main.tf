terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "snowflake-labs/snowflake"
    }
  }
}

resource "snowflake_database" "database_resource" {
  name = var.snowflake_database_name
}

resource "snowflake_schema" "schema_resource" {
  depends_on = [
    snowflake_database.database_resource
  ]
  name     = "${var.snowflake_schema_name}${var.environment == "prod" ? "" : "_${upper(var.environment)}"}"
  database = snowflake_database.database_resource.name
}

resource "snowflake_account_role" "snowflake_account_role_resource" {
  name = var.snowflake_user_role_name
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%*?"
}

resource "snowflake_user" "user_resource" {
  depends_on = [
    random_password.password
  ]
  name                    = var.snowflake_user_name
  password                = random_password.password.result
  default_warehouse       = var.snowflake_warehouse
  default_role            = snowflake_account_role.snowflake_account_role_resource.name
  must_change_password    = false
}

resource "snowflake_grant_account_role" "grant_account_role" {
  depends_on = [
    snowflake_grant_privileges_to_account_role.privileges_to_schema,
    snowflake_grant_privileges_to_account_role.privileges_to_database,
    snowflake_grant_privileges_to_account_role.privileges_to_tables
  ]
  role_name = snowflake_account_role.snowflake_account_role_resource.name
  user_name = snowflake_user.user_resource.name
}

resource "snowflake_grant_privileges_to_account_role" "privileges_to_schema" {
  depends_on = [
    snowflake_account_role.snowflake_account_role_resource,
    snowflake_database.database_resource,
    snowflake_schema.schema_resource
  ]
  privileges        = ["MODIFY", "USAGE", "CREATE TABLE"]
  account_role_name = snowflake_account_role.snowflake_account_role_resource.name
  on_schema {
    all_schemas_in_database = snowflake_database.database_resource.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "privileges_to_database" {
  depends_on = [
    snowflake_account_role.snowflake_account_role_resource,
    snowflake_database.database_resource
  ]
  privileges        = ["MODIFY", "USAGE", "CREATE SCHEMA"]
  account_role_name = snowflake_account_role.snowflake_account_role_resource.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.database_resource.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "privileges_to_tables" {
  depends_on = [
    snowflake_account_role.snowflake_account_role_resource,
    snowflake_schema.schema_resource,
    snowflake_unsafe_execute.customer_demographics_table,
    snowflake_unsafe_execute.customer_behavior_table,
    snowflake_unsafe_execute.customer_insurance_products_table,
    snowflake_unsafe_execute.customer_preferences_table,
    snowflake_unsafe_execute.customer_segmentation_table
  ]
  privileges        = ["ALL"]
  account_role_name = snowflake_account_role.snowflake_account_role_resource.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "privileges_to_stage" {
  depends_on = [
    snowflake_account_role.snowflake_account_role_resource,
    snowflake_stage.data_files_stage,
    snowflake_schema.schema_resource
  ]
  privileges        = ["ALL"]
  account_role_name = snowflake_account_role.snowflake_account_role_resource.name
  on_schema_object {
    object_type          = "STAGE"
    object_name          = "${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.${snowflake_stage.data_files_stage.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "privileges_to_warehouse" {
  depends_on = [
    snowflake_account_role.snowflake_account_role_resource
  ]
  privileges        = ["ALL"]
  account_role_name = snowflake_account_role.snowflake_account_role_resource.name
  on_account_object {
    object_type          = "WAREHOUSE"
    object_name          = var.snowflake_warehouse
  }
}

resource "snowflake_unsafe_execute" "customer_demographics_table" {
  depends_on = [
    snowflake_schema.schema_resource
  ]
  execute = <<-EOT
    CREATE TABLE ${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.customer_demographics (
      customer_id INT PRIMARY KEY,
      age INT,
      gender VARCHAR(10),
      marital_status VARCHAR(20),
      education_level VARCHAR(50),
      geographic_information VARCHAR(100),
      occupation VARCHAR(50),
      income_level DECIMAL(18, 2),
      md5_hash VARCHAR(32)
  );
  EOT
  revert  = "SELECT NULL;"
}

resource "snowflake_unsafe_execute" "customer_behavior_table" {
  depends_on = [
    snowflake_unsafe_execute.customer_demographics_table
  ]
  execute = <<-EOT
    CREATE TABLE ${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.customer_behavior (
      customer_id INT PRIMARY KEY,
      behavioral_data VARCHAR(50),
      interactions_with_customer_service VARCHAR(50),
      purchase_history DATE,
      md5_hash VARCHAR(32),
      FOREIGN KEY (customer_id) REFERENCES ${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.customer_demographics(customer_id)
  );
  EOT
  revert  = "SELECT NULL;"
}

resource "snowflake_unsafe_execute" "customer_insurance_products_table" {
  depends_on = [
    snowflake_unsafe_execute.customer_behavior_table
  ]
  execute = <<-EOT
    CREATE TABLE ${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.customer_insurance_products (
    customer_id INT,
    insurance_products_owned VARCHAR(50),
    coverage_amount DECIMAL(18, 2),
    premium_amount DECIMAL(18, 2),
    policy_type VARCHAR(50),
    md5_hash VARCHAR(32),
    PRIMARY KEY (customer_id, insurance_products_owned),
    FOREIGN KEY (customer_id) REFERENCES ${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.customer_demographics(customer_id)
  );
  EOT
  revert  = "SELECT NULL;"
}

resource "snowflake_unsafe_execute" "customer_preferences_table" {
  depends_on = [
    snowflake_unsafe_execute.customer_insurance_products_table
  ]
  execute = <<-EOT
    CREATE TABLE ${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.customer_preferences (
    customer_id INT PRIMARY KEY,
    customer_preferences VARCHAR(50),
    preferred_communication_channel VARCHAR(50),
    preferred_contact_time VARCHAR(50),
    preferred_language VARCHAR(50),
    md5_hash VARCHAR(32),
    FOREIGN KEY (customer_id) REFERENCES ${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.customer_demographics(customer_id)
  );
  EOT
  revert  = "SELECT NULL;"
}

resource "snowflake_unsafe_execute" "customer_segmentation_table" {
  depends_on = [
    snowflake_unsafe_execute.customer_preferences_table
  ]
  execute = <<-EOT
    CREATE TABLE ${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.customer_segmentation (
    customer_id INT PRIMARY KEY,
    segmentation_group VARCHAR(50),
    md5_hash VARCHAR(32),
    FOREIGN KEY (customer_id) REFERENCES ${snowflake_database.database_resource.name}.${snowflake_schema.schema_resource.name}.customer_demographics(customer_id)
  );
  EOT
  revert  = "SELECT NULL;"
}

resource "snowflake_stage" "data_files_stage" {
  depends_on = [
    snowflake_schema.schema_resource
  ]
  name        = var.snowflake_stage_name
  database    = snowflake_database.database_resource.name
  schema      = snowflake_schema.schema_resource.name
}
