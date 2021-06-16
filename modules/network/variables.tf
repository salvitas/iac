variable "vpc_cidr" {
  default = "10.1.0.0/16"
  type = string
  description = "The VPC CIDR block for network"
}

variable "priv_sub_a_cidr" {
  default = "10.1.1.0/24"
  type = string
  description = "The VPC CIDR block for network"
}

variable "priv_sub_b_cidr" {
  default = "10.1.2.0/24"
  type = string
  description = "The VPC CIDR block for network"
}

variable "pub_sub_a_cidr" {
  default = "10.1.3.0/24"
  type = string
  description = "The VPC CIDR block for network"
}

variable "pub_sub_b_cidr" {
  default = "10.1.4.0/24"
  type = string
  description = "The VPC CIDR block for network"
}

variable "sg_name" {
  default = "bankstart_alb_sg"
  type = string
  description = "The Security Group Name"
}