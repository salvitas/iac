variable "global_region" {
  type    = string
  description = "The AWS region where resources will be created"
}

variable "api_name" {
  type    = string
  description = "The AppSync api name"
}

variable "cognito_pool_id" {
  type = string
  description = "The Cognito Pool Id"
}

variable "appsync_role_name" {
  type    = string
  description = "The AppSync Role Name"
}

variable "dynamodb_arns" {
  type = list(string)
  description = "The list of arns for the appsync - dynamodb policy"
}

variable "loadbalancer_url" {
  type    = string
  description = "The HTTP Resource Load Balancer URL"
}

variable "table_names" {
  type    = list(string)
  description = "The DynamoDB table names"
}

variable "customers_data_source" {
  type    = string
  description = "The data source name"
}

variable "accounts_data_source" {
  type    = string
  description = "The data source name"
}

variable "transactions_data_source" {
  type    = string
  description = "The data source name"
}

variable "favourite_account_data_source" {
  type    = string
  description = "The data source name"
}