output "security_group_id" {
  value = aws_security_group.security-group-access-to-vpc.id
}

output "es" {
  value = aws_elasticsearch_domain.es-domain.endpoint
}
