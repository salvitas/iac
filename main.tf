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

locals {
  appsync_dynamodb_datasources = [
    "customers_${terraform.workspace}",
    "accounts_${terraform.workspace}",
    "transactions_${terraform.workspace}",
    "favourite_accounts_${terraform.workspace}"
  ]

  dynamodb_tables = concat(local.appsync_dynamodb_datasources, ["signatures_${terraform.workspace}"])
}

module "network" {
  source = "./modules/network"
}

// Buckets for FrontEnd Apps
//resource "aws_s3_bucket" "bucket" {
//  bucket = "${var.bucket_name}-${terraform.workspace}"
//  acl = "private"
//
//  versioning {
//    enabled = false
//  }
//}

// End Users Authentication - OAUTH2 OIDC - Authorization Code Grant
module "cognito" {
  source = "./modules/cognito"
  pool_name = "${var.pool_name}_${terraform.workspace}"
}

// Database Setup
module "dynamodb" {
  table_names       = local.dynamodb_tables
  source            = "./modules/dynamodb"
  region            = var.region
//  TODO check how to dynamically include secondary indexes
}

// Roles and Policies to Access AWS Resources
module "iam" {
  source = "./modules/iam"
  appsync_role_name = "${var.appsync_role_name}_${terraform.workspace}"
  //  TODO remove signatures arn
  dynamodb_arns = module.dynamodb.dynamodb_arns
}

// GraphQL API Setup
module "appsync" {
  source            = "./modules/appsync"
  api_name          = "${var.api_name}_${terraform.workspace}"
  cognito_pool_id   = module.cognito.cognito_pool_id
  table_names       = local.appsync_dynamodb_datasources
  role_arn          = module.iam.appsync_role_arn
}

