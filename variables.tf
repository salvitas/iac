variable "region" {
  default     = "ap-southeast-1"
  type        = string
  description = "The AWS region where resources will be created"
}

variable "namespace" {
  default     = "bankstart"
  type        = string
  description = "The application namespace that will be prefixed when creating infrastructure resources"
}

variable "bucket_name" {
  default     = "deployments"
  type        = string
  description = "The S3 bucket name"
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

variable "eks_role_name" {
  type        = string
  description = "The EKS Role Name"
}

variable "ecs_execution_role_name" {
  type        = string
  description = "The ECS Execution Role Name"
}

variable "ecs_task_execution_role_name" {
  type        = string
  description = "The ECS Task Execution Role Name"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The ECS Cluster Name for Microservices to run"
}