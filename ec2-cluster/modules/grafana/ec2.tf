resource "aws_instance" "grafana" {
  ami                         = data.aws_ami.amzn2-ami.id
  instance_type               = var.instance_type
  associate_public_ip_address = true

  iam_instance_profile = var.iam_instance_profile

  user_data = templatefile("${path.module}/init.sh", {
    user = local.ssh_user
  })

  security_groups = [aws_security_group.grafana.name]

  tags = {
    Name      = "grafana-${var.cluster_id}"
    Env       = var.env
    Cluster   = var.cluster_id
    Workspace = terraform.workspace
  }

  connection {
    host    = self.public_ip
    type    = "ssh"
    user    = local.ssh_user
    timeout = "240s"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo usermod -a -G docker ${local.ssh_user}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo service docker start",
      "sudo systemctl enable docker",
      "sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "cd /home/${local.ssh_user}",
      "mkdir grafana prometheus",
      "cd /home/${local.ssh_user}/grafana",
      "mkdir config dashboards datasources storage",
      "cd /home/${local.ssh_user}/prometheus",
      "mkdir config storage",
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/docker-compose.yml.tftpl", {
      public_ip = aws_instance.grafana.public_ip
      container_user = var.container_user
    })
    destination = "/home/${local.ssh_user}/docker-compose.yml"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/prometheus/prometheus.yaml.tftpl", {
      targets = var.node_ips
      public_port = var.public_port
      l1_public_port = var.l1_public_port
    })
    destination = "/home/${local.ssh_user}/prometheus/config/prometheus.yaml"
  }

  provisioner "file" {
    source = "${path.module}/templates/grafana/dashboards"
    destination = "/home/${local.ssh_user}/grafana"
  }

  provisioner "file" {
    source = "${path.module}/templates/grafana/datasources"
    destination = "/home/${local.ssh_user}/grafana"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown -R ${var.container_user}:${var.container_user} /home/${local.ssh_user}/grafana /home/${local.ssh_user}/prometheus",
      "docker-compose up -d"
    ]
  }

}

resource "aws_eip" "grafana_eip" {
  instance = aws_instance.grafana.id
  tags = {
    Name = "EIP-grafana-${var.cluster_id}"
    Env  = var.env
  }
}
