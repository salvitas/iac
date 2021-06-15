output "ecr_repos_url" {
  value = [for ecr in aws_ecr_repository.ecr_repos : ecr.repository_url]
}

output "ecr_repos_arn" {
  value = [for ecr in aws_ecr_repository.ecr_repos : ecr.arn]
}
