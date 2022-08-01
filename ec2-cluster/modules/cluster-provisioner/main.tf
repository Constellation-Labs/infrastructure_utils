resource "null_resource" "cluster_provisioner" {
  count = var.provisioner_count
  triggers = {
    instance_ip = var.instance_ips[count.index]
  }

  connection {
    host    = var.instance_ips[count.index]
    type    = "ssh"
    user    = var.ssh_user
    timeout = "240s"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", {
      genesis_ip          = var.instance_ips[0],
      genesis_id          = var.instance_keys[0].id,
      path_to_join_script = "/home/${var.ssh_user}/tessellation/join"
    })
    destination = "/home/${var.ssh_user}/tessellation/join-0"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", {
      genesis_ip          = var.instance_ips[1],
      genesis_id          = var.instance_keys[1].id,
      path_to_join_script = "/home/${var.ssh_user}/tessellation/join"
    })
    destination = "/home/${var.ssh_user}/tessellation/join-1"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", {
      genesis_ip          = var.instance_ips[2],
      genesis_id          = var.instance_keys[2].id,
      path_to_join_script = "/home/${var.ssh_user}/tessellation/join"
    })
    destination = "/home/${var.ssh_user}/tessellation/join-2"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", {
      genesis_ip          = var.instance_ips[0],
      genesis_id          = var.instance_keys[0].id,
      path_to_join_script = "/home/${var.ssh_user}/tessellation/dag/join"
    })
    destination = "/home/${var.ssh_user}/tessellation/dag/join-0"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", {
      genesis_ip          = var.instance_ips[1],
      genesis_id          = var.instance_keys[1].id,
      path_to_join_script = "/home/${var.ssh_user}/tessellation/dag/join"
    })
    destination = "/home/${var.ssh_user}/tessellation/dag/join-1"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/join", {
      genesis_ip          = var.instance_ips[2],
      genesis_id          = var.instance_keys[2].id,
      path_to_join_script = "/home/${var.ssh_user}/tessellation/dag/join"
    })
    destination = "/home/${var.ssh_user}/tessellation/dag/join-2"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod u+x /home/${var.ssh_user}/tessellation/join-0",
      "sudo chmod u+x /home/${var.ssh_user}/tessellation/join-1",
      "sudo chmod u+x /home/${var.ssh_user}/tessellation/join-2",
      "sudo chmod u+x /home/${var.ssh_user}/tessellation/dag/join-0",
      "sudo chmod u+x /home/${var.ssh_user}/tessellation/dag/join-1",
      "sudo chmod u+x /home/${var.ssh_user}/tessellation/dag/join-2",
      "echo '${jsonencode(var.instance_ips)}' | jq '.[]' -r > /home/${var.ssh_user}/tessellation/cluster-hosts"
    ]
  }
}