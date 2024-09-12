data "aws_ami" "node" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "image-id"
    values = ["ami-0523a6b76ce979642"] //debian-11-amd64
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