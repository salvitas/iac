# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_to_dynamodb_policy" {
  name = "LambdaDynamoDBAccessPolicy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = var.dynamodb_arns
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_to_cloudwatch_policy" {
  name = "LambdaToCloudWatchLogsPolicy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "*"
        ]
      },
    ]
  })
}

resource "aws_lambda_function" "sync_accounts" {
  function_name = "SyncAccountsAfterLogin"

  # The bucket name as created earlier with "aws s3api create-bucket"
//  s3_bucket = var.s3_bucket
//  s3_key = "v1.0.0/example.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  filename      = "${path.module}/data/sync-accounts/function.zip"
  handler = "main.handler"
  runtime = "nodejs14.x"

  role = aws_iam_role.lambda_exec.arn
}