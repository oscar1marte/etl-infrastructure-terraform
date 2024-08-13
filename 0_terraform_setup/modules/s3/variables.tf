variable "environment" {
  description = "Specifies the environment for deployment, such as dev, stage, or prod."
  type        = string
}

variable "aws_s3_bucket_name" {
  description = "The name of the AWS S3 bucket where files will be stored or retrieved."
  type        = string
}

variable "aws_s3_bucket_tag_name" {
  description = "A tag assigned to the AWS S3 bucket for identification or organizational purposes."
  type        = string
}

variable "csv_file_name" {
  description = "The name of the CSV file to be processed or uploaded to the S3 bucket."
  type        = string
}

variable "path_to_file" {
  description = "The local directory path where the CSV file is stored or will be saved. Default is './data'."
  type        = string
  default     = "./data"
}
