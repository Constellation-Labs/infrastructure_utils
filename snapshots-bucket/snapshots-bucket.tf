resource "aws_s3_bucket" "cluster_snapshots" {
    bucket = "constellationlabs-${var.env}-snapshots"
    acl = "private"

  tags = {
    Env = var.env
    Name = "${var.env}-snapshots"
    Workspace = terraform.workspace
  }
}
