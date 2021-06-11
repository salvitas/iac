resource "aws_appsync_graphql_api" "appsync" {
  authentication_type   = "AMAZON_COGNITO_USER_POOLS"
  name                  = var.api_name

  user_pool_config {
    aws_region          = var.region
    user_pool_id        = var.cognito_pool_id
    default_action      = "DENY"
  }
}

resource "aws_appsync_datasource" "appsync_dynamodb_ds" {
  for_each            = toset(var.table_names)
  api_id              = aws_appsync_graphql_api.appsync.id
  name                = each.key
  service_role_arn    = var.table_arns[index(var.table_names, each.key)]
  type                = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name        = each.key
  }
}

//TODO need another resource of type HTTP to point to an ELB that points to EKS