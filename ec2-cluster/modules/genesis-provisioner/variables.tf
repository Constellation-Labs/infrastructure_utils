variable "ssh_user" {
  type = string
}

variable "instance_ips" {
  type = list(string)
}

variable "genesis_ip" {
  type = string
}

variable "l0_public_port" {
  type = string
}

variable "l1_public_port" {
  type = string
}

variable "block_explorer_url" {
    type = string
}

variable "snapshot_stored_path" {
  type = string
}
