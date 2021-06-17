variable "region" {
  default = "ap-southeast-1"
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

variable "table_names" {
  type    = list(string)
  description = "The DynamoDB table names"
}

variable "role_arn" {
  type    = string
  description = "The AppSync Role ARN"
}

variable "loadbalancer_url" {
  type    = string
  description = "The HTTP Resource Load Balancer URL"
}