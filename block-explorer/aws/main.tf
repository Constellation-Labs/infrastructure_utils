provider "aws" {
  version    = "~> 2.0"
  region     = "eu-west-2"
}


/*
  VPC for BlockExplorer
*/
resource "aws_vpc" "vpc-block-explorer" {
  cidr_block = "10.1.0.0/16"
}


/*
  Permissions for lambda function:
    - to cloudwatch (logging)
    - to S3
*/
resource "aws_iam_role" "iam-lambda-block-explorer" {
  name               = "iam-for-block-explorer-lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda-logging-policy" {
  name = "lambda-logging-policy"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda-s3-policy" {
  name = "lambda-S3-block-explorer-bucket-policy"
  path = "/"
  description = "IAM policy for S3 block-explorer-bucket from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::block-explorer-bucket",
        "arn:aws:s3:::block-explorer-bucket/*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.iam-lambda-block-explorer.name}"
  policy_arn = "${aws_iam_policy.lambda-logging-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role = "${aws_iam_role.iam-lambda-block-explorer.name}"
  policy_arn = "${aws_iam_policy.lambda-s3-policy.arn}"
}


/*
  Permission to allow execution lambda function from a bucket
*/
resource "aws_lambda_permission" "allow-bucket-to-execute-lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-block-explorer-s3-to-es-handler.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket-block-explorer.arn}"
}


/*
  Cloudwatch group
*/
resource "aws_cloudwatch_log_group" "cloud-watch-lambda-block-explorer" {
  name              = "/aws/lambda/${aws_lambda_function.lambda-block-explorer-s3-to-es-handler.function_name}"
  retention_in_days = 14
}


/*
  S3 bucket
*/
resource "aws_s3_bucket" "bucket-block-explorer" {
  bucket = "block-explorer-bucket"
  acl    = "private"
}


/*
  S3 bucket event
*/
resource "aws_s3_bucket_notification" "bucket-notification-block-explorer" {
  bucket = "${aws_s3_bucket.bucket-block-explorer.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.lambda-block-explorer-s3-to-es-handler.arn}"
    events = ["s3:ObjectCreated:*"]
  }
}


/*
  Lambda function
*/
resource "aws_lambda_function" "lambda-block-explorer-s3-to-es-handler" {
  filename = "block-explorer-handler-lambda-assembly-1.0.0.jar"
  function_name = "s3-to-es-handler-block-explorer"
  handler = "org.constellation.handler.LambdaHandler::handleRequest"
  role = "${aws_iam_role.iam-lambda-block-explorer.arn}"
  runtime = "java8"
  timeout = 240
  memory_size = 1024
}
