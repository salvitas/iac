variable "bucket_name" {
  default     = "bankstart-deployments"
  type        = string
  description = "The S3 bucket name"
}

variable "region" {
  default     = "ap-southeast-1"
  type        = string
  description = "The AWS region where resources will be created"
}

variable "pool_name" {
  type        = string
  description = "The Cognito user pool name"
}

variable "api_name" {
  type        = string
  description = "The AppSync api name"
}

variable "appsync_role_name" {
  type        = string
  description = "The AppSync Role Name"
}

//variable "table_name" {
//  type    = string
//  description = "The DynamoDB table name"
//}