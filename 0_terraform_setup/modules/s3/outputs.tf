output "aws_s3_bucket_name" {
  description = ""
  value       = aws_s3_bucket.aws_s3_bucket_resource.bucket
}

output "csv_object_name" {
  description = ""
  value       = aws_s3_object.csv_object.key
}