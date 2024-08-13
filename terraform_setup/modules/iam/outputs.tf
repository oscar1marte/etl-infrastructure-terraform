output "aws_glue_role_name" {
  description = ""
  value       = aws_iam_role.aws_glue_role.name
}

output "aws_glue_role_arn" {
  description = ""
  value       = aws_iam_role.aws_glue_role.arn
}