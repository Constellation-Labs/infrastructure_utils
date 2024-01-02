variable "container_user" {
  type = string
  default = "472"
}

variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "cluster_id" {
  type = string
}

variable "public_port" {
  type = string
  default = "9010"
}

variable "l1_public_port" {
  type = string
  default = "9000"
}

variable "instance_type" {
  type = string
  default = "t3.xlarge"
}

variable "node_ips" {
  type = list(string)
}

variable "volume_az" {
  type = string
}

variable "volume_device_name" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}
