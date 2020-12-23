output "splunk_ip" {
  value = module.infrastructure.splunk_ip
}

output "splunk_web_url" {
  value = module.infrastructure.splunk_web_url
}

output "splunk_hec_url" {
  value = module.infrastructure.splunk_hec_url
}

output "default_login" {
  value = module.infrastructure.default_login
}

output "default_password" {
  value = module.infrastructure.default_password
}

output "hec_tokens" {
  value = module.preconfiguration.hec_tokens
}

output "hec_token_index" {
  value = module.preconfiguration.hec_token_index
}
