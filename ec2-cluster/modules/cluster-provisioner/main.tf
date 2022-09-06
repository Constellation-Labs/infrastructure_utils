resource "null_resource" "gather_public_keys" {
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/set_up_keys.sh ${var.ssh_user} '${jsonencode(var.instance_ips)}'"
  }
}

resource "null_resource" "cluster_provisioner" {
  count = length(var.instance_ips)
  triggers = {
    instance_ip = var.instance_ips[count.index]
  }

  connection {
    host    = var.instance_ips[count.index]
    type    = "ssh"
    user    = var.ssh_user
    timeout = "240s"
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo '${jsonencode(var.instance_ips)}' | jq '.[]' -r > /home/${var.ssh_user}/tessellation/cluster-hosts",
  #     "sudo chmod u+x /home/${var.ssh_user}/tessellation/restart-cluster"
  #   ]
  # }

  provisioner "remote-exec" {
    inline = [
      "echo '${jsonencode(var.instance_ips)}' | jq '.[]' -r > /home/${var.ssh_user}/tessellation/cluster-hosts"
    ]
  }
}