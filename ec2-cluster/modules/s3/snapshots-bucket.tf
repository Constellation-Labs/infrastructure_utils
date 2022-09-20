data "aws_s3_bucket" "cluster_snapshots" {
  bucket = "constellationlabs-${var.env}-snapshots"
}
