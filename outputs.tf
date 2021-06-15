output "network_elb_url" {
  value = module.network.elb_url
}

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

output "ecr_repos_url" {
  value = module.ecr.ecr_repos_url
}

output "ecr_repos_arn" {
  value = module.ecr.ecr_repos_arn
}