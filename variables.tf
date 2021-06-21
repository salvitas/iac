variable "region" {
  type        = string
  description = "The AWS region where resources will be created"
}

variable "namespace" {
  type        = string
  description = "The application namespace that will be prefixed when creating infrastructure resources"
}

variable "cert_name" {
  type        = string
  description = "The certificate name from ACM to be used in dynamically created cloudfront distributions"
}

variable "hosted_zone_name" {
  type        = string
  description = "The default domain name for this application"
}

variable "web_bucket_name" {
  type        = string
  description = "The S3 static website bucket name"
}

variable "pool_name" {
  type        = string
  description = "The Cognito user pool name"
}

variable "api_name" {
  type        = string
  description = "The AppSync api name"
}