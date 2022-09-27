output "instance_ips" {
  value = module.nodes.instance_ips
}

output "grafana_url" {
  value = module.grafana.grafana_url
}