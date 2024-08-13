variable "environment" {
  description = "Specifies the deployment environment, such as dev, stage, or prod."
  type        = string
}

variable "aws_s3_bucket_name" {
  description = "The name of the AWS S3 bucket where the CSV object is stored or will be uploaded."
  type        = string
}

variable "csv_object_name" {
  description = "The name of the CSV object in the S3 bucket that will be processed by the ETL job."
  type        = string
}

variable "path_to_file" {
  description = "The local file system path where the CSV file is located or will be saved. Default is './data'."
  type        = string
  default     = "./data"
}

variable "aws_etl_script" {
  description = "The name or path of the ETL script that will be executed to process the CSV file."
  type        = string
}

variable "external_python_module" {
  description = "The external Python module required by the ETL script, such as the Snowflake connector or other dependencies."
  type        = string
}
