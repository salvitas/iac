variable "hosted_zone_name" {
  type    = string
  description = "The Route53 Hosted Zone Name"
}

variable "cert_name" {
  type    = string
  description = "The ACM cert Name"
}

variable "appsync_domain_name" {
  type    = string
  description = "The Appsync domain name"
}

variable "static_bucket_domain" {
  type    = string
  description = "The Static Website S3 Bucket domain name"
}
