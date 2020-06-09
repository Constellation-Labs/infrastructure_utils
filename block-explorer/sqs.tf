resource "aws_sqs_queue" "queue" {
  name = "cl-block-explorer_queue-${var.env}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:cl-block-explorer_queue-${var.env}",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.bucket.arn}" }
      }
    }
  ]
}
POLICY

  tags = {
    Name = "cl-block-explorer_queue"
    Env = var.env
    Workspace = terraform.workspace
  }
}

data "aws_sqs_queue" "sqsQueue" {
  name = aws_sqs_queue.queue.name
}