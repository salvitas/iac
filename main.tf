terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.46"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      environment = terraform.workspace
      namespace   = var.namespace
    }
  }
}

locals {
  customers_table          = "${var.namespace}_${terraform.workspace}_customers"
  accounts_table           = "${var.namespace}_${terraform.workspace}_accounts"
  transactions_table       = "${var.namespace}_${terraform.workspace}_transactions"
  favourite_accounts_table = "${var.namespace}_${terraform.workspace}_favourite_accounts"
  signatures_table         = "${var.namespace}_${terraform.workspace}_signatures"

  microservices_ecr_repositories = [
    "${var.namespace}/accounts-service",
    "${var.namespace}/loans-service",
    "${var.namespace}/signatures-service"
  ]

  appsync_dynamodb_datasources = [
    local.customers_table,
    local.accounts_table,
    local.transactions_table,
    local.favourite_accounts_table
  ]

  dynamodb_tables = concat(local.appsync_dynamodb_datasources, [
  local.signatures_table])
}

// Base network Setup - VPC, Subnets, IGW, NatGW, ALB, Security Group and routing tables
module "network" {
  source = "./modules/network"

  global_namespace = var.namespace
}

// Microservices repositories
module "ecr" {
  source = "./modules/ecr"

  ecr_repositories = local.microservices_ecr_repositories
}

module "s3" {
  source = "./modules/s3"

  bucket_name      = "${var.namespace}-${terraform.workspace}-${var.web_bucket_name}"
  bucket_policy_id = "${var.namespace}-${terraform.workspace}-staticwebsitepolicy"
}

// End Users Authentication - OAUTH2 OIDC - Authorization Code Grant
module "cognito" {
  source = "./modules/cognito"

  pool_name   = "${var.namespace}_${terraform.workspace}_${var.pool_name}"
  domain_name = "${var.namespace}-${terraform.workspace}"
}

// Database Setup
module "dynamodb" {
  //  TODO try to make it dynamic with only 1 resource inside!
  source = "./modules/dynamodb"

  global_region                 = var.region
  customers_table_name          = local.customers_table
  accounts_table_name           = local.accounts_table
  transactions_table_name       = local.transactions_table
  favourite_accounts_table_name = local.favourite_accounts_table
  signatures_table_name         = local.signatures_table
}

// Roles and Policies to Access AWS Resources
module "iam" {
  depends_on = [
  module.dynamodb]
  source = "./modules/iam"

  appsync_role_name = "${var.namespace}_${terraform.workspace}_${var.appsync_role_name}"
  dynamodb_arns     = concat(module.dynamodb.dynamodb_arns, formatlist("%s/*", module.dynamodb.dynamodb_arns))
  eks_role_name     = "${var.namespace}_${terraform.workspace}_${var.eks_role_name}"
}

// ECS for Microservices
module "ecs" {
  depends_on = [
  module.network]
  source = "./modules/ecs"

  global_namespace             = var.namespace
  ecs_cluster_name             = "${var.namespace}_${terraform.workspace}_microservices_cluster"
  vpc_id                       = module.network.vpc_id
  elb_sg_id                    = module.network.elb_sg_id
  private_subnets              = module.network.private_subnets
  alb_listener_arn             = module.network.alb_listener_arn
  container_name               = "container_accounts"
}

// GraphQL API Setup
module "appsync" {
  depends_on = [
    module.dynamodb,
    module.cognito,
    module.iam,
  module.network]
  source = "./modules/appsync"

  global_region                 = var.region
  api_name                      = "${var.namespace}_${terraform.workspace}_${var.api_name}"
  cognito_pool_id               = module.cognito.cognito_pool_id
  role_arn                      = module.iam.appsync_role_arn
  loadbalancer_url              = module.network.elb_url
  table_names                   = local.appsync_dynamodb_datasources
  customers_data_source         = local.customers_table
  accounts_data_source          = local.accounts_table
  transactions_data_source      = local.transactions_table
  favourite_account_data_source = local.favourite_accounts_table
}

module "appsync_domain" {
  depends_on = [
  module.appsync]
  source = "matti/urlparse/external"

  url = module.appsync.appsync_graphql_url
}

module "cloudfront" {
  source = "./modules/cloudfront"

  cert_name        = var.cert_name
  // aka. Domain Name
  hosted_zone_name = var.hosted_zone_name
  appsync_domain_name  = module.appsync_domain.host
  // Using regional domain to avoid DNS propagation waiting and cloudfront redirecting to S3 URL
  static_bucket_domain = module.s3.regional_domain_name
}
