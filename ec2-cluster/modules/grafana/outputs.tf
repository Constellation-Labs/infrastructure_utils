output "grafana_url" {
  value = "${aws_eip.grafana_eip.public_ip}:3000"
}

output "ssh" {
  value = "${local.ssh_user}@${aws_instance.grafana.public_ip}"
}
