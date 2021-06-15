output "dynamodb_ids" {
  value = [
  aws_dynamodb_table.accounts.id,
  aws_dynamodb_table.customers.id,
  aws_dynamodb_table.favourite_accounts.id,
  aws_dynamodb_table.transactions,
  aws_dynamodb_table.signatures
  ]
}

output "dynamodb_arns" {
  value = [
  aws_dynamodb_table.accounts.arn,
  aws_dynamodb_table.customers.arn,
  aws_dynamodb_table.transactions.arn,
  aws_dynamodb_table.favourite_accounts.arn
  ]
}