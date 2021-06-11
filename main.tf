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

module "appsync" {
  source            = "./modules/appsync"
  api_name          = "${var.api_name}_${terraform.workspace}"
  cognito_pool_id   = module.cognito.cognito_pool_id
  table_names       = ["customers_${terraform.workspace}", "accounts_${terraform.workspace}", "transactions_${terraform.workspace}", "favourite_accounts_${terraform.workspace}", "signatures_${terraform.workspace}"]
  table_arns        = module.dynamodb.dynamodb_arns
}

//TODO move tables into a locals var.