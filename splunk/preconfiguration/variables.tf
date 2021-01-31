variable "splunk_ip" {
  type = string
}

variable "username" {
  type = string
  sensitive = true
}

variable "password" {
  type = string
  sensitive = true
}

variable "hec_token_index" {
  type = string
  default = "main"
}

variable "nodes" {
  type = set(object({ alias=string, cidr=string }))
}