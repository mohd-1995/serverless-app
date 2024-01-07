data "archive_file" "my_lambda_zip" {
  type        = "zip"
  source_dir  = "./my-lambda/lambda/"
  output_path = "./my-lambda.zip"
}

resource "aws_lambda_function" "my_lambda" {
  filename         = "./my-lambda.zip"
  function_name    = "lambda_function"
  role             = aws_iam_role.my_lambda_policy.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.my_lambda_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 15
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


resource "aws_iam_role" "my_lambda_policy"{
    name = "my_lambda_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}