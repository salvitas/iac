resource "aws_ecr_repository" "ecr_repos" {
  for_each = toset(var.ecr_repositories)
  name                 = each.key
  image_tag_mutability = "MUTABLE" // TODO change for prod config to "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}