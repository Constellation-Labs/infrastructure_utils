resource "random_id" "instance_id" {
  byte_length = 4
}

locals {
  cluster_id = random_id.instance_id.hex
}

module "nodes" {
  source               = "./modules/node"
  instance_count       = var.instance_count
  cluster_id           = local.cluster_id
  env                  = var.env
  workspace            = terraform.workspace
  instance_type        = var.instance_type
  disk_size            = var.node_disk_size
  tessellation_version = var.tessellation_version
  instance_keys        = var.instance_keys
  public_port          = var.public_port
  p2p_port             = var.p2p_port
  cli_port             = var.cli_port
  l1_public_port       = var.l1_public_port
  l1_p2p_port          = var.l1_p2p_port
  l1_cli_port          = var.l1_cli_port
  snapshot_stored_path = var.snapshot_stored_path
  bucket_access_key    = aws_iam_access_key.s3_access.id
  bucket_secret_key    = aws_iam_access_key.s3_access.secret
  bucket_name          = var.bucket_name
}

module "cluster-provisioner" {
  source            = "./modules/cluster-provisioner"
  provisioner_count = var.instance_count
  instance_ips      = module.nodes.instance_ips
  instance_keys     = var.instance_keys
  ssh_user          = "admin"
}

module "genesis-provisioner" {
  source               = "./modules/genesis-provisioner"
  instance_ips         = module.nodes.instance_ips
  genesis_ip           = module.nodes.instance_ips[0]
  l0_public_port       = var.public_port
  l1_public_port       = var.l1_public_port
  snapshot_stored_path = var.snapshot_stored_path
  block_explorer_url   = var.block_explorer_url
  ssh_user             = "admin"
}