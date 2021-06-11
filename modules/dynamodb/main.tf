resource "aws_dynamodb_table" "dynamodb_table" {
  for_each        = var.table_names
  name            = each.key
  billing_mode    = "PAY_PER_REQUEST"
  hash_key        = "id"

  attribute {
    name          = "id"
    type          = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

//  global_secondary_index {
//    name               = "GameTitleIndex"
//    hash_key           = "GameTitle"
//    projection_type    = "ALL"
//  }

  provisioner "local-exec" {
    command         = "dynamodump import-data --region ${var.region} --table=${each.key} --file ${path.module}/data/${each.key}.json"
  }
}

