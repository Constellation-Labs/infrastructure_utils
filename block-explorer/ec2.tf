resource "aws_eip" "eip" {
  vpc                       = true
  network_interface         = var.cl-network-interface-id

  tags = {
    Name = "cl-block-explorer_eip-${var.env}"
    Env = var.env
    Workspace = terraform.workspace
  }
}

resource "aws_eip_association" "eip-block-explorer" {
  network_interface_id = var.cl-network-interface-id
  instance_id = aws_instance.handler-block-explorer.id
  allocation_id = aws_eip.eip.id
}

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
  ami = data.aws_ami.amzn2-ami.id
  instance_type = var.handler_instance-type

  user_data = file("ssh_keys.sh")

  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name

  network_interface {
    device_index = 0
    network_interface_id = var.cl-network-interface-id
  }

  tags = {
    Name = "cl-block-explorer_handler-${var.env}"
    Env = var.env
    Workspace = terraform.workspace
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = aws_eip.eip.public_ip
    timeout = "240s"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install java-1.8.0-openjdk-headless",
      "sudo yum -y install polkit-devel",
      "mkdir /home/ec2-user/block-explorer-handler"
    ]
  }

  provisioner "file" {
    source = "templates/start"
    destination = "/home/ec2-user/block-explorer-handler/start"
  }

  provisioner "file" {
    source = "block-explorer-handler.jar"
    destination = "/home/ec2-user/block-explorer-handler/block-explorer-handler.jar"
  }


  provisioner "file" {
    content = templatefile("templates/application.conf", { sqs = data.aws_sqs_queue.sqsQueue.url, es = aws_elasticsearch_domain.es-domain.endpoint })
    destination = "/home/ec2-user/block-explorer-handler/application.conf"
  }

  provisioner "file" {
    source = "templates/block-explorer-handler.service"
    destination = "/tmp/block-explorer-handler.service"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo chmod 774 /home/ec2-user/block-explorer-handler/start",
      "sudo cp /tmp/block-explorer-handler.service /etc/systemd/system/multi-user.target.wants/block-explorer-handler.service",
      "sudo rm -rf /tmp/block-explorer-handler.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable block-explorer-handler.service",
      "sudo systemctl start block-explorer-handler.service"
    ]
  }

  depends_on = [
    aws_iam_policy.sqs-access-to-ec2,
    aws_iam_policy.s3-access-to-ec2,
    aws_iam_role_policy_attachment.s3-iam-role,
    aws_iam_role_policy_attachment.sqs-iam-role,
    aws_iam_role.ec2-role,
    aws_iam_instance_profile.ec2-profile,
  ]
}

resource "aws_iam_policy" "sqs-access-to-ec2" {
  name = "cl-sqs-access-to-ec2-${var.env}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sqs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "s3-access-to-ec2" {
  name = "cl-s3-access-to-ec2-${var.env}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ec2-role" {
  name = "cl-ec2-role-${var.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "cl-block-explorer_ec2-role"
    Env = var.env
    Workspace = terraform.workspace
  }
}

resource "aws_iam_role_policy_attachment" "s3-iam-role" {
  role = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.s3-access-to-ec2.arn
}

resource "aws_iam_role_policy_attachment" "sqs-iam-role" {
  role = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.sqs-access-to-ec2.arn
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "cl-ec2-profile-${var.env}"
  role = aws_iam_role.ec2-role.name
}
