resource "aws_instance" "grafana" {
  ami                         = data.aws_ami.amzn2-ami.id
  instance_type               = var.instance_type
  associate_public_ip_address = true

  user_data = file("user_data.sh")

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
      "cd grafana",
      "mkdir config dashboards datasources storage",
      "sudo chown -R 104:104 /home/${local.ssh_user}/grafana",
      "sudo chmod -R 777 /home/${local.ssh_user}/grafana",
    ]
  }

  provisioner "file" {
    source = "./templates/docker-compose.yml"
    destination = "/home/${local.ssh_user}/docker-compose.yml"
  }

  provisioner "file" {
    content = templatefile("./templates/prometheus/prometheus.yaml.tftpl", {
      targets = var.node_ips
      public_port = var.public_port
      l1_public_port = var.l1_public_port
    })
    destination = "/home/${local.ssh_user}/prometheus/prometheus.yaml"
  }

  provisioner "file" {
    source = "./templates/grafana/dashboards"
    destination = "/home/${local.ssh_user}/grafana"
  }

  provisioner "file" {
    source = "./templates/grafana/datasources"
    destination = "/home/${local.ssh_user}/grafana"
  }

  provisioner "remote-exec" {
    inline = [
      "docker-compose up -d"
    ]
  }

}
