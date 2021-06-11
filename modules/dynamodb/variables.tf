variable "table_names" {
  type = set(string)
  description = "The DynamoDB table names"
}

variable "region" {
  default = "ap-southeast-1"
  type    = string
  description = "The AWS region where resources will be created"
}