resource "random_id" "instance_id" {
  byte_length = 4
}

locals {
  cluster_id = random_id.instance_id.hex
}

module "s3" {
  source      = "./modules/s3"
  cluster_id  = local.cluster_id
  env         = var.env
  workspace   = terraform.workspace
  bucket_name = var.bucket_name
}

module "grafana" {
  source = "./modules/grafana"
  env = var.env
  cluster_id = local.cluster_id
  node_ips = module.nodes.instance_ips
  public_port = var.public_port
  l1_public_port = var.l1_public_port
}

module "nodes" {
  source               = "./modules/node"
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
  block_explorer_url   = var.block_explorer_url
  bucket_access_key    = module.s3.bucket_access_key
  bucket_secret_key    = module.s3.bucket_secret_key
  bucket_name          = var.bucket_name
  load_balancer_l0_url = var.load_balancer_l0_url
  load_balancer_l1_url = var.load_balancer_l1_url
}

module "cluster_provisioner" {
  source       = "./modules/cluster-provisioner"
  instance_ips = module.nodes.instance_ips
  ssh_user     = "admin"
}
