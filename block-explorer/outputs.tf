output "security_group_id" {
  value = aws_security_group.security-group-access-to-vpc.id
}

output "opensearch_security_group_id" {
  value = aws_security_group.security-group-opensearch.id
}

output "endpoint" {
  value = aws_opensearch_domain.opensearch-domain.endpoint
}
