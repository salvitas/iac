provider "aws" {
  region = var.region

  default_tags {
    tags = {
      env     = terraform.workspace
      project = "bankstart"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  microservices_ecr_repositories = [
    "accounts-service",
    "loans-service",
    "signatures-service"
  ]

  appsync_dynamodb_datasources = [
    "customers_${terraform.workspace}",
    "accounts_${terraform.workspace}",
    "transactions_${terraform.workspace}",
    "favourite_accounts_${terraform.workspace}"
  ]

  dynamodb_tables = concat(local.appsync_dynamodb_datasources, [
  "signatures_${terraform.workspace}"])
}

// Base network Setup - VPC, Subnets, IGW, NatGW, ALB, Security Group and routing tables
module "network" {
  source = "./modules/network"
}

// Microservices repositories
module "ecr" {
  source           = "./modules/ecr"
  ecr_repositories = local.microservices_ecr_repositories
}

// Buckets for FrontEnd - Web and App (iOS & Android)
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.namespace}-${var.bucket_name}-${terraform.workspace}"
  acl    = "private"

  versioning {
    enabled = false
  }
}

// End Users Authentication - OAUTH2 OIDC - Authorization Code Grant
module "cognito" {
  source    = "./modules/cognito"
  pool_name = "${var.namespace}_${var.pool_name}_${terraform.workspace}"
}

// Database Setup
module "dynamodb" {
  //  TODO try to make it dynamic with only 1 resource inside!
  source = "./modules/dynamodb"
  region = var.region
}

// Roles and Policies to Access AWS Resources
module "iam" {
  source            = "./modules/iam"
  appsync_role_name = "${var.namespace}_${var.appsync_role_name}_${terraform.workspace}"
  dynamodb_arns     = concat(module.dynamodb.dynamodb_arns, formatlist("%s/*", module.dynamodb.dynamodb_arns))
  eks_role_name     = "${var.namespace}_${var.eks_role_name}_${terraform.workspace}"
}

// ECS for Microservices
module "ecs" {
  source                       = "./modules/ecs"
  ecs_execution_role_name      = "${var.namespace}_${var.ecs_execution_role_name}_${terraform.workspace}"
  ecs_task_execution_role_name = "${var.namespace}_${var.ecs_task_execution_role_name}_${terraform.workspace}"
  ecs_cluster_name             = "${var.namespace}_${var.ecs_cluster_name}_${terraform.workspace}"
  vpc_id                       = module.network.vpc_id
  elb_sg_id                    = module.network.elb_sg_id
  container_name               = "container_accounts"
  private_subnets              = module.network.private_subnets
  alb_listener_arn             = module.network.alb_listener_arn
}

// GraphQL API Setup
module "appsync" {
  source           = "./modules/appsync"
  api_name         = "${var.namespace}_${var.api_name}_${terraform.workspace}"
  cognito_pool_id  = module.cognito.cognito_pool_id
  table_names      = local.appsync_dynamodb_datasources
  role_arn         = module.iam.appsync_role_arn
  loadbalancer_url = module.network.elb_url
}

// TODO create a CloudFront Distribution for grapqhl, app, web - DNS A record (Alias to Cloudfront) to call appsync graphql api https://bx6g65dqdnfkdo27uyy4r7jsv4.appsync-api.ap-southeast-1.amazonaws.com/graphql
