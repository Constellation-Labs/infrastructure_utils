variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "instance_count" {
  type    = number
  default = 3
}

variable "instance_type" {
  type = string
}

variable "node_disk_size" {
  type    = number
  default = 50
}

variable "tessellation_version" {
  type    = string
  default = "0.12.0"
}

variable "instance_keys" {
  type = list(object({
    key = string,
    id  = string
  }))
  default = [
    { key = "key-0.p12", id = "e2f4496e5872682d7a55aa06e507a58e96b5d48a5286bfdff7ed780fa464d9e789b2760ecd840f4cb3ee6e1c1d81b2ee844c88dbebf149b1084b7313eb680714" },
    { key = "key-1.p12", id = "3458a688925a4bd89f2ac2c695362e44d2e0c2903bdbb41b341a4d39283b22d8c85b487bd33cc5d36dbe5e31b5b00a10a6eab802718ead4ed7192ade5a5d1941" },
    {
  key = "key-2.p12", id = "46daea11ca239cb8c0c8cdeb27db9dbe9c03744908a8a389a60d14df2ddde409260a93334d74957331eec1af323f458b12b3a6c3b8e05885608aae7e3a77eac7" }]
}

variable "public_port" {
  type    = string
  default = "9000"
}

variable "p2p_port" {
  type    = string
  default = "9001"
}

variable "cli_port" {
  type    = string
  default = "9002"
}

variable "l1_public_port" {
  type    = string
  default = "9010"
}

variable "l1_p2p_port" {
  type    = string
  default = "9011"
}

variable "l1_cli_port" {
  type    = string
  default = "9012"
}

variable "snapshot_stored_path" {
  type    = string
  default = "data/snapshot"
}

variable "bucket_name" {
  type = string
}

variable "block_explorer_url" {
  type = string
}
