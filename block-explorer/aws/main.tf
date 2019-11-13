provider "aws" {
  version    = "~> 2.0"
  region     = "eu-west-2"
}


/*
  VPC for BlockExplorer
*/
resource "aws_vpc" "vpc-block-explorer" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "block-explorer-vpc"
  }
}

resource "aws_subnet" "subnet-block-explorer" {
  vpc_id = "${aws_vpc.vpc-block-explorer.id}"
  cidr_block = "10.1.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "block-explorer-subnet"
  }
}

resource "aws_network_interface" "handler-app-block-explorer" {
  subnet_id = "${aws_subnet.subnet-block-explorer.id}"
  private_ips = ["10.1.0.10"]

  tags = {
    Name = "block-explorer-network-interface"
  }
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

  network_interface {
    device_index = 0
    network_interface_id = "${aws_network_interface.handler-app-block-explorer.id}"
  }

  tags = {
    Name = "block-explorer-handler"
  }
}
