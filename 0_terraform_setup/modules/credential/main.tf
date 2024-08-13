locals {
  snowflake_credential = {
    username  = var.snowflake_user_name
    password  = var.snowflake_user_password
  }
}

locals {
  json_data = jsonencode(local.snowflake_credential)
}

resource "local_file" "snowflake_credential_output" {
  filename = "./snowflake_credential.json"
  content  = local.json_data
}