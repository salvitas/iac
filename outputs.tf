output "dynamodb_ids" {
  value = module.dynamodb.dynamodb_ids
}

output "dynamodb_arns" {
  value = module.dynamodb.dynamodb_arns
}

output "cognito_pool_id" {
  value = module.cognito.cognito_pool_id
}

output "appsync_id" {
  value = module.appsync.appsync_id
}

output "appsync_graphql_url" {
  value = module.appsync.appsync_graphql_url
}

output "iam_appsync_role_arn" {
  value = module.iam.appsync_role_arn
}