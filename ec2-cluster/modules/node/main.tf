locals {
  l0 = {
    app_env              = var.env,
    public_port          = var.public_port,
    p2p_port             = var.p2p_port,
    cli_port             = var.cli_port,
    snapshot_stored_path = var.snapshot_stored_path
  }
  l1 = {
    app_env        = var.env,
    l0_public_port = var.public_port,
    public_port    = var.l1_public_port,
    p2p_port       = var.l1_p2p_port,
    cli_port       = var.l1_cli_port
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

  user_data = templatefile("${path.module}/init.sh", {
    user = local.ssh_user
  })

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
      user                 = local.ssh_user
    })
    destination = "/tmp/setup"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/setup-services", {
      user = local.ssh_user
    })
    destination = "/tmp/setup-services"
  }

  provisioner "file" {
    source      = "${path.module}/data/key-${count.index}.p12"
    destination = "/tmp/key.p12"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l0/run-rollback", merge(local.l0, {
      public_ip = self.public_ip,
      user      = local.ssh_user
    }))
    destination = "/tmp/l0/run-rollback"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l0/run-genesis", merge(local.l0, {
      public_ip = self.public_ip,
      user      = local.ssh_user
    }))
    destination = "/tmp/l0/run-genesis"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l0/run-validator", merge(local.l0, {
      public_ip = self.public_ip,
      user      = local.ssh_user
    }))
    destination = "/tmp/l0/run-validator"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l1/run-validator", merge(local.l1, {
      public_ip  = self.public_ip,
      l0_peer_id = var.instance_keys[count.index].id
    }))
    destination = "/tmp/l1/run-validator"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l1/run-initial-validator", merge(local.l1, {
      public_ip  = self.public_ip,
      l0_peer_id = var.instance_keys[count.index].id
    }))
    destination = "/tmp/l1/run-initial-validator"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", merge(local.l0, {
      public_ip = self.public_ip,
    }))
    destination = "/tmp/l0/join"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", merge(local.l1, {
      public_ip = self.public_ip,
    }))
    destination = "/tmp/l1/join"
  }

  provisioner "file" {
    source      = "${path.module}/templates/l0/update-version"
    destination = "/tmp/l0/update-version"
  }

  provisioner "file" {
    source      = "${path.module}/templates/l1/l1-update-version"
    destination = "/tmp/l1/l1-update-version"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/update-seedlist", {
      app_env = var.env
      user    = local.ssh_user
    })
    destination = "/tmp/update-seedlist"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l0/l0.service", {
      user = local.ssh_user
    })
    destination = "/tmp/l0/l0.service"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l1/l1.service", {
      user = local.ssh_user
    })
    destination = "/tmp/l1/l1.service"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l0/restart", {
      user = local.ssh_user
    })
    destination = "/tmp/l0/restart"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/l1/restart", {
      user = local.ssh_user
    })
    destination = "/tmp/l1/restart"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/snapshots-s3-sync", {
      bucket_access_key    = var.bucket_access_key,
      bucket_secret_key    = var.bucket_secret_key,
      bucket_name          = "${var.bucket_name}/node-${count.index}",
      snapshot_stored_path = var.snapshot_stored_path
      user                 = local.ssh_user
    })
    destination = "/tmp/snapshots-s3-sync"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/setup-incron", {
      snapshot_stored_path = var.snapshot_stored_path
      user                 = local.ssh_user
    })
    destination = "/tmp/setup-incron"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/auto-rollback.service", {
      user                = local.ssh_user
      block_explorer_url  = var.block_explorer_url
      auto_rollback_check_interval = var.auto_rollback_check_interval
    })
    destination = "/tmp/auto-rollback.service"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/restart-cluster", {
      public_ip            = self.public_ip,
      peer_id              = var.instance_keys[count.index].id,
      l0_public_port       = var.public_port,
      l1_public_port       = var.l1_public_port,
      snapshot_stored_path = var.snapshot_stored_path,
      block_explorer_url   = var.block_explorer_url,
      bucket_name          = var.bucket_name,
      bucket_access_key    = var.bucket_access_key,
      bucket_secret_key    = var.bucket_secret_key,
      user                 = local.ssh_user
    })
    destination = "/tmp/restart-cluster"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -qq update",
      "sudo apt-get -qq install openjdk-8-jdk-headless jq unzip incron pssh -y",
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "unzip -q awscliv2.zip",
      "sudo ./aws/install",
      "chmod +x /tmp/setup",
      "/tmp/setup",
      "chmod +x /tmp/setup-services",
      "/tmp/setup-services",
      "sudo sh -c 'echo \"${local.ssh_user}\" >> /etc/incron.allow'",
      "sudo systemctl start incron.service",
      "chmod +x /tmp/setup-incron",
      "/tmp/setup-incron"
    ]
  }

}
