data "aws_ami" "node" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "image-id"
    values = ["ami-072d0c3766d522751"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  ssh_user = "admin"
}