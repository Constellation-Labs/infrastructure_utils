data "aws_ami" "splunk-enterprise-ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["splunk_AMI*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

resource "aws_instance" "splunk" {
  associate_public_ip_address = true
  ami = data.aws_ami.splunk-enterprise-ami.id
  instance_type = var.instance-type
  security_groups = [aws_security_group.cl-splunk-security_group.name]

  tags = {
    Name = "cl-splunk-${terraform.workspace}"
    Env = var.env
    Workspace = terraform.workspace
  }
}

locals {
  default_login = "admin"
  default_password = "SPLUNK-${aws_instance.splunk.id}"
}