provider "aws" {
  region = var.region

  default_tags {
    tags = {
      env = terraform.workspace
      project = "bankstart"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${terraform.workspace}"
  acl = "private"

  versioning {
    enabled = false
  }
}

module "cognito" {
  source = "./modules/cognito"
  pool_name = "${var.pool_name}_${terraform.workspace}"
}

module "dynamodb" {
  table_names       = ["customers_${terraform.workspace}", "accounts_${terraform.workspace}", "transactions_${terraform.workspace}", "favourite_accounts_${terraform.workspace}", "signatures_${terraform.workspace}"]
  source            = "./modules/dynamodb"
  region            = var.region
//  TODO check how to dynamically include secondary indexes
}

// TODO need to create the IAM ROLE and bind it
resource "aws_iam_role" "appsync_role" {
  name               = "appsync_role_${terraform.workspace}"
  path               = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
//        Sid    = ""
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "test_policy" {
  name = "GraphQLApiDynamoDBAccessPolicy"
  role = aws_iam_role.appsync_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:GetItem"
        ]
        Effect   = "Allow"
        Resource = module.dynamodb.dynamodb_arns
      },
    ]
  })
}

module "appsync" {
  source            = "./modules/appsync"
  api_name          = "${var.api_name}_${terraform.workspace}"
  cognito_pool_id   = module.cognito.cognito_pool_id
  table_names       = ["customers_${terraform.workspace}", "accounts_${terraform.workspace}", "transactions_${terraform.workspace}", "favourite_accounts_${terraform.workspace}", "signatures_${terraform.workspace}"]
  role_arn          = aws_iam_role.appsync_role.arn
}

//TODO move tables into a locals var.