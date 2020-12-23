output "splunk_ip" {
  value = aws_instance.splunk.public_ip
}

output "splunk_web_url" {
  value = "http://${aws_instance.splunk.public_ip}:8000"
}

output "splunk_hec_url" {
  value = "https://${aws_instance.splunk.public_ip}:8088"
}

output "default_login" {
  value = local.default_login
}

output "default_password" {
  value = local.default_password
}
