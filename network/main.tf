locals {
  workspace = terraform.workspace
}

resource "aws_vpc" "cl_vpc" {
  cidr_block = "20.0.0.0/16"

  tags = {
    Name = "cl-vpc-${var.env}"
    Env = var.env
    Workspace = local.workspace
  }
}

resource "aws_subnet" "cl_subnet" {
  vpc_id = aws_vpc.cl_vpc.id
  cidr_block = "20.0.0.0/24"

  tags = {
    Name = "cl-subnet-${var.env}"
    Env = var.env
    Workspace = local.workspace
  }
}

resource "aws_network_interface" "cl_network_interface" {
  subnet_id = aws_subnet.cl_subnet.id
  private_ips = ["20.0.0.10"]

  tags = {
    Name = "cl-network_interface-${var.env}"
    Env = var.env
    Workspace = local.workspace
  }
}

resource "aws_internet_gateway" "cl_internet_gateway" {
  vpc_id = aws_vpc.cl_vpc.id

  tags = {
    Name = "cl-internet_gateway-${var.env}"
    Env = var.env
    Workspace = local.workspace
  }
}

resource "aws_route_table" "cl-route_table" {
  vpc_id = aws_vpc.cl_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cl_internet_gateway.id
  }

  tags = {
    Name = "cl-route_table-${var.env}"
    Env = var.env
    Workspace = local.workspace
  }
}

resource "aws_main_route_table_association" "main_route_table" {
  route_table_id = aws_route_table.cl-route_table.id
  vpc_id = aws_vpc.cl_vpc.id
}