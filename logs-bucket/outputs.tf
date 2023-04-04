output "loki_access_key_id" {
  value = aws_iam_access_key.loki.id
  sensitive = true
}

output "loki_access_key_secret" {
  value = aws_iam_access_key.loki.secret
  sensitive = true
}
