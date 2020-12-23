resource "aws_security_group" "cl-splunk-security_group" {
  name = "cl-splunk-security_group-${var.env}"
//  vpc_id = var.cl-vpc-id

  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "WEB"
  }

  ingress {
    from_port = 8089
    to_port = 8089
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "REST"
  }

  ingress {
    from_port = 8088
    to_port = 8088
    protocol = "TCP"
    cidr_blocks = var.nodes[*].cidr
    description = "HEC Input Events"
  }

  ingress {
    from_port = 8088
    to_port = 8088
    protocol = "UDP"
    cidr_blocks = var.nodes[*].cidr
    description = "HEC Input Events"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cl-splunk-security_group-${var.env}"
    Env = var.env
    Workspace = terraform.workspace
  }
}