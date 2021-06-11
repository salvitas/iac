output "dynamodb_ids" {
  value = [for x in aws_dynamodb_table.dynamodb_table : x.id]
}

output "dynamodb_arns" {
  value = [for x in aws_dynamodb_table.dynamodb_table : x.arn]
}