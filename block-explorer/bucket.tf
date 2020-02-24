resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket-name}-${var.env}"
  acl    = "private"

  tags = {
    Name = var.bucket-name
    Env = var.env
    Workspace = terraform.workspace
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
  }
}
