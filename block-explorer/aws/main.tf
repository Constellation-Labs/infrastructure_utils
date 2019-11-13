provider "aws" {
  version    = "~> 2.0"
  region     = "eu-west-2"
}

/*
  VPC Network
*/
resource "aws_vpc" "vpc-block-explorer" {
  cidr_block = "20.0.0.0/16"

  tags = {
    Name = "block-explorer-vpc"
  }
}

resource "aws_subnet" "subnet-block-explorer" {
  vpc_id = "${aws_vpc.vpc-block-explorer.id}"
  cidr_block = "20.0.0.0/24"

  tags = {
    Name = "block-explorer-subnet"
  }
}

resource "aws_network_interface" "handler-app-block-explorer" {
  subnet_id = "${aws_subnet.subnet-block-explorer.id}"
  private_ips = ["20.0.0.10"]
  security_groups = ["${aws_security_group.security-group-handler-block-explorer.id}"]

  tags = {
    Name = "block-explorer-network-interface"
  }
}

resource "aws_internet_gateway" "gateway-block-explorer" {
  vpc_id = "${aws_vpc.vpc-block-explorer.id}"

  tags = {
    Name = "block-explorer-gateway"
  }
}

resource "aws_route_table" "route-table-block-explorer" {
  vpc_id = "${aws_vpc.vpc-block-explorer.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway-block-explorer.id}"
  }

  tags = {
    Name = "block-explorer-route-table"
  }
}

resource "aws_main_route_table_association" "main" {
  route_table_id = "${aws_route_table.route-table-block-explorer.id}"
  vpc_id = "${aws_vpc.vpc-block-explorer.id}"
}


/*
  SQS Queue
*/
resource "aws_sqs_queue" "queue-block-explorer" {
  name = "s3-event-block-explorer-queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:s3-event-block-explorer-queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.bucket-block-explorer.arn}" }
      }
    }
  ]
}
POLICY
}


/*
  S3 bucket
*/
resource "aws_s3_bucket" "bucket-block-explorer" {
  bucket = "block-explorer-bucket"
  acl    = "private"
}


/*
  S3 Bucket Notification
*/
resource "aws_s3_bucket_notification" "bucket-notification-block-explorer" {
  bucket = "${aws_s3_bucket.bucket-block-explorer.id}"

  queue {
    queue_arn     = "${aws_sqs_queue.queue-block-explorer.arn}"
    events        = ["s3:ObjectCreated:*"]
  }
}


/*
  Elastic IP
*/
resource "aws_eip_association" "eip-block-explorer" {
  instance_id = "${aws_instance.handler-block-explorer.id}"
  allocation_id = "eipalloc-0e0205a5323ebfb07"
}


/*
  EC2 Instance
*/
data "aws_ami" "amzn2-ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "handler-block-explorer" {
  ami = "${data.aws_ami.amzn2-ami.id}"
  instance_type = "t2.micro"

  key_name = "constellation-labs-block-explorer-stack"

  network_interface {
    device_index = 0
    network_interface_id = "${aws_network_interface.handler-app-block-explorer.id}"
  }

  tags = {
    Name = "block-explorer-handler"
  }

  connection {
    type = "ssh"
    user = "linux-ec2"
    private_key = "${file("/home/mchrapek/Work/constellation-key/aws_id_rsa")}"
  }
}

resource "aws_security_group" "security-group-handler-block-explorer" {
  name = "security-group-handler-block-explorer"
  vpc_id = "${aws_vpc.vpc-block-explorer.id}"

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
}
