resource "aws_security_group" "security-group-handler" {
  name = "cl-block-explorer_security_group-${var.env}"
  vpc_id = var.cl-vpc-id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cl-block-explorer_security_group"
    Env = var.env
    Workspace = terraform.workspace
  }
}

resource "aws_security_group" "security-group-access-to-vpc" {
  name = "cl-block-explorer_security_group-access-${var.env}"
  vpc_id = var.cl-vpc-id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cl-block-explorer_security-group-access"
    Env = var.env
    Workspace = terraform.workspace
  }
}
