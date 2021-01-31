locals {
  workspace = terraform.workspace
}

/* IMPORTANT! Due to https://github.com/hashicorp/terraform/issues/2430 both modules need to be called in order by -target:
 * 1. terraform apply -target=module.infrastructure -var-file=splunk.tfvars
 * 2. terraform apply -target=module.preconfiguration -var-file=splunk.tfvars
 */

module "infrastructure" {
  source = "./infrastructure"
  instance-type = var.instance-type
  aws_region = var.aws_region
  nodes = var.nodes
  env = var.env
}

module "preconfiguration" {
  source = "./preconfiguration"
  splunk_ip = module.infrastructure.splunk_ip
  username = coalesce(var.admin_login, module.infrastructure.default_login)
  password = coalesce(var.admin_password, module.infrastructure.default_password)
  nodes = var.nodes
}