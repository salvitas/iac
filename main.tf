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
  table_names       = toset(["customers_${terraform.workspace}", "accounts_${terraform.workspace}", "transactions_${terraform.workspace}", "favourite_accounts_${terraform.workspace}", "signatures_${terraform.workspace}"])
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

//resource "aws_appsync_datasource" "appsync_dynamodb_ds" {
//  for_each          = toset(["customers_${terraform.workspace}", "accounts_${terraform.workspace}", "transactions_${terraform.workspace}", "favourite_accounts_${terraform.workspace}", "signatures_${terraform.workspace}"])
//  api_id            = module.appsync.appsync_id
//  name              = "${module.dynamodb.dynamodb_id[index(["customers", "accounts", "transactions", "favourite_accounts", "signatures"], each.key)]}_${terraform.workspace}"
//  service_role_arn  = module.dynamodb.dynamodb_arn[index(["customers", "accounts", "transactions", "favourite_accounts", "signatures"], each.key)]
//  type              = "AMAZON_DYNAMODB"
//
//  dynamodb_config {
//    table_name      = module.dynamodb.dynamodb_id[index(["customers", "accounts", "transactions", "favourite_accounts", "signatures"], each.key)]
//  }
//}