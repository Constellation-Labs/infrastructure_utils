locals {
  l0 = {
    app_env              = var.env,
    public_port          = var.public_port,
    p2p_port             = var.p2p_port,
    cli_port             = var.cli_port,
    snapshot_stored_path = var.snapshot_stored_path
  }
  l1 = {
    app_env              = var.env,
    l0_public_port       = var.public_port,
    public_port          = var.l1_public_port,
    p2p_port             = var.l1_p2p_port,
    cli_port             = var.l1_cli_port
  }
}

resource "aws_instance" "node" {
  count = length(var.instance_keys)

  ami                         = data.aws_ami.node.id
  instance_type               = var.instance_type
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = var.disk_size
  }

  user_data = file("ssh_keys.sh")

  tags = {
    Index     = count.index
    Name      = "node-${var.cluster_id}-${count.index}"
    Env       = var.env
    Cluster   = var.cluster_id
    Workspace = var.workspace
  }

  connection {
    host    = self.public_ip
    type    = "ssh"
    user    = local.ssh_user
    timeout = "240s"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/setup", {
      tessellation_version = var.tessellation_version,
      key                  = var.instance_keys[count.index].key
      app_env              = var.env
    })
    destination = "/tmp/setup"
  }

  provisioner "file" {
    source      = "${path.module}/templates/setup-services"
    destination = "/tmp/setup-services"
  }

  provisioner "file" {
    source      = "${path.module}/data/key-${count.index}.p12"
    destination = "/tmp/key.p12"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/rollback", merge(local.l0, {
      public_ip            = self.public_ip,
    }))
    destination = "/tmp/rollback"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/genesis", merge(local.l0, {
      public_ip            = self.public_ip,
    }))
    destination = "/tmp/genesis"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/validator", merge(local.l0, {
      public_ip            = self.public_ip,
    }))
    destination = "/tmp/validator"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l1-validator", merge(local.l1, {
      public_ip      = self.public_ip,
      l0_peer_id     = var.instance_keys[count.index].id
    }))
    destination = "/tmp/l1-validator"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l1-initial-validator", merge(local.l1, {
      public_ip      = self.public_ip,
      l0_peer_id     = var.instance_keys[count.index].id
    }))
    destination = "/tmp/l1-initial-validator"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", merge(local.l0, {
      public_ip = self.public_ip,
    }))
    destination = "/tmp/join"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", merge(local.l1, {
      public_ip = self.public_ip,
    }))
    destination = "/tmp/l1-join"
  }

  provisioner "file" {
    source      = "${path.module}/templates/update-version"
    destination = "/tmp/update-version"
  }

  provisioner "file" {
    source      = "${path.module}/templates/l1-update-version"
    destination = "/tmp/l1-update-version"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/update-seedlist", {
      app_env = var.env
    })
    destination = "/tmp/update-seedlist"
  }

  provisioner "file" {
    source      = "${path.module}/templates/l0.service"
    destination = "/tmp/l0.service"
  }

  provisioner "file" {
    source      = "${path.module}/templates/l1.service"
    destination = "/tmp/l1.service"
  }

  provisioner "file" {
    source      = "${path.module}/templates/restart"
    destination = "/tmp/restart"
  }

  provisioner "file" {
    source      = "${path.module}/templates/l1-restart"
    destination = "/tmp/l1-restart"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/snapshots-s3-sync", {
      bucket_access_key    = var.bucket_access_key,
      bucket_secret_key    = var.bucket_secret_key,
      bucket_name          = "${var.bucket_name}/node-${count.index}",
      snapshot_stored_path = var.snapshot_stored_path
    })
    destination = "/tmp/snapshots-s3-sync"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/setup-incron", {
      snapshot_stored_path = var.snapshot_stored_path
    })
    destination = "/tmp/setup-incron"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install openjdk-8-jdk-headless jq unzip incron -y",
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "chmod +x /tmp/setup",
      "/tmp/setup",
      "chmod +x /tmp/setup-services",
      "/tmp/setup-services",
      "sudo sh -c 'echo \"admin\" >> /etc/incron.allow'",
      "sudo systemctl start incron.service",
      "chmod +x /tmp/setup-incron",
      "/tmp/setup-incron"
    ]
  }

}
