terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "aws_glue_role" {
  name = var.aws_glue_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
  description = "Policy for Glue job to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ],
        Resource = [
          "arn:aws:s3:::${var.aws_s3_bucket_name}",
          "arn:aws:s3:::${var.aws_s3_bucket_name}/*"
        ],
      },
    ],
  })
}

resource "aws_iam_policy" "secrets_manager_access_policy" {
  name        = "secrets-manager-access-policy"
  description = "Policy for Glue job to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
          ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:${var.snowflake_secrets_manager}-*"
      },
    ],
  })
}

resource "aws_iam_policy" "cloudwatch_access_policy" {
  name        = "cloudwatch-access-policy"
  description = "Policy for Glue job to access Cloudwatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:AssociateKmsKey"
      ],
        Resource = [
          "arn:aws:logs:*:*:*"
      ]
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.aws_glue_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.aws_glue_role.name
  policy_arn = aws_iam_policy.secrets_manager_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.aws_glue_role.name
  policy_arn = aws_iam_policy.cloudwatch_access_policy.arn
}