data "aws_ami" "amzn2-ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "image-id"
    values = ["ami-0f5bca4d7b49c9f49"]
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
  ssh_user = "ec2-user"
}
