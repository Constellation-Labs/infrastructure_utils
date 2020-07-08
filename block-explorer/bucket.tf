resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket-name}-${var.env}"
  acl    = "private"

  tags = {
    Name = var.bucket-name
    Env = var.env
    Workspace = terraform.workspace
  }
}


