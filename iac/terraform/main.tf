terraform {
  backend "s3" {
    bucket = "timrutte-terraform-states"
    key    = "sparkasse-notion-sync/terraform.tfstate"
    region = "eu-west-1"
    profile = "sparkasse-notion-sync"
  }
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

locals {
  prefix = "sparkasse-notion-sync"
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-lambda-execute-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${local.prefix}-lambda-policy"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = "s3:GetObject",
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${local.prefix}-emails"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "email_processor" {
  function_name    = "${local.prefix}-email-processor"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = "lambda_function.zip"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  environment {
    variables = {
      NOTION_TOKEN       = var.notion_token
      NOTION_DATABASE_ID = var.notion_database_id
      GMAIL_CREDENTIALS  = var.gmail_credentials
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_hour" {
  name                = "${local.prefix}-runLambdaEveryHour"
  description         = "Trigger Lambda every hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.every_hour.name
  target_id = "lambda"
  arn       = aws_lambda_function.email_processor.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_hour.arn
}
