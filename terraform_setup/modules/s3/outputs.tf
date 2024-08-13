output "aws_s3_bucket_name" {
  description = ""
  value       = data.aws_s3_object.csv_file.bucket
}

output "aws_s3_key_name" {
  description = ""
  value       = data.aws_s3_object.csv_file.key
}

output "etl_script_name" {
  description = ""
  value       = aws_s3_object.etl_script_object.key
}

output "external_python_module_name" {
  description = ""
  value       = aws_s3_object.external_python_module_object.key
}