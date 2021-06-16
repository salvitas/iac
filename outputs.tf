output "appsync_graphql_url" {
  value = module.appsync.appsync_graphql_url
}

output "network_elb_url" {
  value = module.network.elb_url
}

output "cognito_pool_id" {
  value = module.cognito.cognito_pool_id
}

output "cognito_pool_client_id" {
  value = module.cognito.cognito_pool_client_id
}

output "cognito_pool_client_secret" {
  value     = module.cognito.cognito_pool_client_secret
  sensitive = true
}

output "ecr_repositories" {
  value = module.ecr.ecr_repos_url
}
