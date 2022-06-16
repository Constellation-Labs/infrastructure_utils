module "ecr" {
  source = "terraform-aws-modules/ecr/aws"
  version = "~> 1.3"

  for_each = var.repositories

  repository_name = each.key

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last ${each.value.capacity} images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = each.value.capacity
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Env = var.env
  }
}
