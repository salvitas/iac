variable "global_region" {
  type    = string
  description = "The AWS region where resources will be created"
}

variable "customers_table_name" {
  type    = string
  description = "The table name"
}

variable "accounts_table_name" {
  type    = string
  description = "The table name"
}

variable "transactions_table_name" {
  type    = string
  description = "The table name"
}

variable "favourite_accounts_table_name" {
  type    = string
  description = "The table name"
}

variable "signatures_table_name" {
  type    = string
  description = "The table name"
}