resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket-name}-${var.env}"

  tags = {
    Name      = var.bucket-name
    Env       = var.env
    Workspace = terraform.workspace
  }
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}


