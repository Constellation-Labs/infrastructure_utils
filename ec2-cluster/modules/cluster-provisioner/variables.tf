variable "ssh_user" {
  type = string
}

variable "instance_ips" {
  type = list(string)
}

variable "instance_keys" {
  type = list(object({
    key = string,
    id  = string
  }))
}