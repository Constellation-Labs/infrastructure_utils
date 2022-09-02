locals {
  bucket_access_key = aws_iam_access_key.s3_access.id
  bucket_secret_key = aws_iam_access_key.s3_access.secret
}

output "bucket_access_key" {
  value = local.bucket_access_key
}

output "bucket_secret_key" {
  value = local.bucket_secret_key
}
