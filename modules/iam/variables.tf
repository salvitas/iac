variable "appsync_role_name" {
  type    = string
  description = "The AppSync Role Name"
}

variable "dynamodb_arns" {
  type = list(string)
  description = "The list of arns for the appsync - dynamodb policy"
}

variable "eks_role_name" {
  type    = string
  description = "The EKS Role Name"
}
