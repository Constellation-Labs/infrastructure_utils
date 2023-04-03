provider "aws" {
  region = var.aws_region
}

locals {
  env_by_workspace = {
    "testnet-2.0" = "testnet-20"
    "mainnet20" = "mainnet20"
  }

  env = (var.env != "" ? var.env : lookup(local.env_by_workspace, terraform.workspace, "dev"))

  common_tags = {
    Env = local.env
    Workspace = terraform.workspace
  }
}

resource "aws_s3_bucket" "chunks" {
  bucket = "constellationlabs-${local.env}-loki-chunks"
  acl    = "private"
  tags   = local.common_tags
  versioning {
    enabled = false
  }
}

resource "aws_iam_user" "loki" {
  name = "loki-${local.env}"
  path = "/system/"
  tags = local.common_tags
}

resource "aws_iam_user_policy" "loki_bucket_access" {
  user = aws_iam_user.loki.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Action = [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject"
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:s3:::${aws_s3_bucket.chunks.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.chunks.bucket}/*"
      ]
    }
  })
}

resource "aws_iam_access_key" "loki" {
  user = aws_iam_user.loki.name
}
