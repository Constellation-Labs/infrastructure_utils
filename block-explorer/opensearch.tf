resource "aws_security_group" "security-group-opensearch" {
  name   = "cl-sg-opensearch-${var.env}"
  vpc_id = var.cl-vpc-id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cl-vpc-cidr-block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cl-vpc-cidr-block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cl-vpc-cidr-block]
  }

  tags = {
    Name      = "cl-block-explorer_sg-opensearch"
    Env       = var.env
    Workspace = terraform.workspace
  }
}

resource "aws_iam_service_linked_role" "opensearch" {
  count            = var.create_iam_service_linked_role == "true" ? 1 : 0
  aws_service_name = "opensearchservice.amazonaws.com"
}

data "aws_caller_identity" "current" {}

resource "aws_opensearch_domain" "opensearch-domain" {
  domain_name    = "cl-block-explorer-${var.env}"
  engine_version = "OpenSearch_1.2"

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = var.opensearch_disk-size
  }

  cluster_config {
    instance_type  = var.opensearch_instance-type
    instance_count = var.opensearch_instance-count
  }

  vpc_options {
    subnet_ids         = [var.cl-subnet-id]
    security_group_ids = [aws_security_group.security-group-opensearch.id]
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
    Name      = "cl-block-explorer_opensearch"
    Env       = var.env
    Workspace = terraform.workspace
  }

  depends_on = [
    aws_iam_service_linked_role.opensearch,
  ]
}
