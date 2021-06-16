variable "ecs_execution_role_name" {
  type    = string
  description = "The ECS Execution Role Name for Microservices to run"
}

variable "ecs_task_execution_role_name" {
  type    = string
  description = "The ECS Task Execution Role Name for Microservices to run"
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

variable "container_name" {
  type = string
  description = "The container name"
}

variable "alb_listener_arn" {
  type = string
  description = "The ALB Listener ARN"
}