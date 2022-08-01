resource "null_resource" "genesis_provisioner" {
  triggers = {
    instance_ip = var.genesis_ip
  }

  connection {
    host    = var.genesis_ip
    type    = "ssh"
    user    = var.ssh_user
    timeout = "240s"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/restart-cluster", {
      l0_public_port       = var.l0_public_port,
      l1_public_port       = var.l1_public_port,
      snapshot_stored_path = var.snapshot_stored_path,
      block_explorer_url   = var.block_explorer_url
    })
    destination = "/home/${var.ssh_user}/tessellation/restart-cluster"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${jsonencode(var.instance_ips)}' | jq '.[]' -r > /home/${var.ssh_user}/tessellation/cluster-hosts",
      "sudo chmod u+x /home/${var.ssh_user}/tessellation/restart-cluster"
    ]
  }
}