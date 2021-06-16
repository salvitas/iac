resource "aws_dynamodb_table" "customers" {
  name = "customers_${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  //  Commented out until terraform fixes issue - https://github.com/hashicorp/terraform-provider-aws/issues/15154
  //  ttl {
  //    attribute_name = "TimeToExist"
  //    enabled        = false
  //  }

  provisioner "local-exec" {
    command = "dynamodump import-data --region ${var.region} --table=customers_${terraform.workspace} --file ${path.module}/data/customers_${terraform.workspace}.json"
  }
}

resource "aws_dynamodb_table" "accounts" {
  name = "accounts_${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "customerId"
    type = "S"
  }
  attribute {
    name = "type"
    type = "S"
  }

  global_secondary_index {
    name = "customerId-type-index"
    hash_key = "customerId"
    range_key = "type"
    projection_type = "ALL"
  }

  provisioner "local-exec" {
    command = "dynamodump import-data --region ${var.region} --table=accounts_${terraform.workspace} --file ${path.module}/data/accounts_${terraform.workspace}.json"
  }
}

resource "aws_dynamodb_table" "transactions" {
  name = "transactions_${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "account_id"
    type = "S"
  }
  attribute {
    name = "operation_date"
    type = "S"
  }

  global_secondary_index {
    name = "account_id-operation_date-index"
    hash_key = "account_id"
    range_key = "operation_date"
    projection_type = "ALL"
  }

  provisioner "local-exec" {
    command = "dynamodump import-data --region ${var.region} --table=transactions_${terraform.workspace} --file ${path.module}/data/transactions_${terraform.workspace}.json"
  }
}

resource "aws_dynamodb_table" "favourite_accounts" {
  name = "favourite_accounts_${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "customer_id"
    type = "S"
  }
  attribute {
    name = "alias"
    type = "S"
  }

  global_secondary_index {
    name = "customer_id-alias-index"
    hash_key = "customer_id"
    range_key = "alias"
    projection_type = "ALL"
  }

  provisioner "local-exec" {
    command = "dynamodump import-data --region ${var.region} --table=favourite_accounts_${terraform.workspace} --file ${path.module}/data/favourite_accounts_${terraform.workspace}.json"
  }
}

resource "aws_dynamodb_table" "signatures" {
  name = "signatures_${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "id_signature_operation"
    type = "S"
  }

  global_secondary_index {
    name = "id_signature_operation-index"
    hash_key = "id_signature_operation"
    projection_type = "ALL"
  }

  provisioner "local-exec" {
    command = "dynamodump import-data --region ${var.region} --table=signatures_${terraform.workspace} --file ${path.module}/data/signatures_${terraform.workspace}.json"
  }
}