variable "cluster_id" {
  type = string
}

variable "tessellation_version" {
  type = string
}

variable "instance_keys" {
  type = list(object({
    key = string,
    id  = string
  }))
}

variable "env" {
  type = string
}

variable "workspace" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "public_port" {
  type = string
}

variable "p2p_port" {
  type = string
}

variable "cli_port" {
  type = string
}

variable "l1_public_port" {
  type = string
}

variable "l1_p2p_port" {
  type = string
}

variable "l1_cli_port" {
  type = string
}

variable "snapshot_stored_path" {
  type = string
}

variable "bucket_access_key" {
  type = string
}

variable "bucket_secret_key" {
  type = string
}

variable "bucket_name" {
  type = string
}