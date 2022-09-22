resource "aws_s3_bucket" "cluster_snapshots" {
  bucket = "constellationlabs-${var.env}-snapshots"

  tags = {
    Env = var.env
    Name = "${var.env}-snapshots"
    Workspace = terraform.workspace
  }
}

resource "aws_s3_bucket_acl" "cluster_snapshots_acl" {
  bucket = aws_s3_bucket.cluster_snapshots.id
  acl = "private"
}
