variable "bucket_name" {
  default     = "bankstart-deployments"
  type        = string
  description = "The S3 bucket name"
}

variable "region" {
  default = "ap-southeast-1"
  type    = string
}
