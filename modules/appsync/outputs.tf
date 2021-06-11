output "appsync_id" {
  value = aws_appsync_graphql_api.appsync.id
}

output "appsync_graphql_url" {
  value = aws_appsync_graphql_api.appsync.uris.GRAPHQL
}