resource "aws_security_group" "security-group-elasticsearch" {
  name = "cl-sg-elasticsearch-${var.env}"
  vpc_id = var.cl-vpc-id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.cl-vpc-cidr-block]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [var.cl-vpc-cidr-block]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.cl-vpc-cidr-block]
  }

  tags = {
    Name = "cl-block-explorer_sg-elasticsearch"
    Env = var.env
    Workspace = terraform.workspace
  }
}

resource "aws_iam_service_linked_role" "es" {
  count = var.create_iam_service_linked_role == "true" ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}

data "aws_caller_identity" "current" {}

resource "aws_elasticsearch_domain" "es-domain" {
  domain_name = "cl-block-explorer-${var.env}"
  elasticsearch_version = "7.1"

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = var.es_disk-size
  }

  cluster_config {
    instance_type = var.es_instance-type
  }

  vpc_options {
    subnet_ids = [var.cl-subnet-id]
    security_group_ids = [aws_security_group.security-group-elasticsearch.id]
  }

  snapshot_options {
    automated_snapshot_start_hour = 20
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/cl-block-explorer-${var.env}/*"
    }
  ]
}
CONFIG

  tags = {
    Name = "cl-block-explorer_elasticsearch"
    Env = var.env
    Workspace = terraform.workspace
  }

  depends_on = [
    aws_iam_service_linked_role.es,
  ]
}
