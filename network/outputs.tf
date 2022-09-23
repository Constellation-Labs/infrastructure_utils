output "vpc_id" {
  value = aws_vpc.cl_vpc.id
}

output "vpc_cidr-block" {
  value = aws_vpc.cl_vpc.cidr_block
}

output "subnet-ids" {
  value = aws_subnet.cl_subnet.*.id
}

output "network-interface-id" {
  value = aws_network_interface.cl_network_interface.id
}
