locals {
  instance_ips = aws_instance.node.*.public_ip
}

output "instance_ips" {
  value = local.instance_ips
}