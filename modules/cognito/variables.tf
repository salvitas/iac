variable "pool_name" {
  type    = string
  description = "The Cognito user pool name"
}

variable "domain_name" {
  type    = string
  description = "The Cognito user pool domain name"
}

variable "post_auth_lambda" {
  type    = string
  description = "The Cognito post authentication lambda function ARN"
}