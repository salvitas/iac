variable "global_namespace" {
  type    = string
  description = "The arn resource policy prefix name"
}

variable "ecs_cluster_name" {
  type    = string
  description = "The ECS Cluster Name for Microservices to run"
}

variable "vpc_id" {
  type    = string
  description = "The VPC Id for the Cluster Security Group"
}

variable "elb_sg_id" {
  type    = string
  description = "The ELB Security Group Id of the VPC"
}

variable "private_subnets" {
  type    = set(string)
  description = "The Array of private subnets to associate to ecs service"
}

variable "alb_listener_arn" {
  type = string
  description = "The ALB Listener ARN"
}

variable "container_name" {
  type = string
  description = "The container name"
}

variable "cognito_pool_id" {
  type = string
  description = "The cognito pool id needed for microservice JWT token verification"
}

variable "cognito_audience" {
  type = string
  description = "The cognito client id needed for microservice JWT token verification"
}