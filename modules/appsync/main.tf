resource "aws_appsync_graphql_api" "appsync" {
  authentication_type   = "AMAZON_COGNITO_USER_POOLS"
  name                  = var.api_name

  user_pool_config {
    aws_region          = var.region
    user_pool_id        = var.cognito_pool_id
    default_action      = "ALLOW" //DENY
  }
}

resource "aws_appsync_datasource" "appsync_dynamodb_ds" {
  for_each            = toset(var.table_names)
  api_id              = aws_appsync_graphql_api.appsync.id
  name                = each.key
  service_role_arn    = var.role_arn
  type                = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name        = each.key
  }
}

//resource "aws_appsync_datasource" "appsync_eks_ds" {
//  api_id              = aws_appsync_graphql_api.appsync.id
//  name                = "microservices_${terraform.workspace}"
//  type                = "HTTP"
//  http_config {
//    endpoint = "loadbalancerurl"
//  }
//}


// TODO need to import schema.graphql
// TODO need to create all resolvers