resource "aws_lambda_function" "lambda-function" {
  filename = "block-explorer-api-lambda.jar"
  function_name = "cl-block-explorer-api-${var.env}"
  handler = "org.constellation.blockexplorer.api.Handler::handleRequest"
  role = aws_iam_role.lambda-iam.arn
  runtime = "java8"
  timeout = 360
  memory_size = 768

  vpc_config {
    security_group_ids = [var.cl-sg-id]
    subnet_ids = [var.cl-subnet-id]
  }

  tags = {
    Name = "cl-block-explorer-api_lambda-function"
    Env = var.env
    Workspace = terraform.workspace
  }
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "gateway-lambda-permission" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-function.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api-gateway.id}/*/*"
}
resource "aws_iam_policy" "lambda-logging-policy" {
  name = "cl-lambda-logging-policy-${var.env}"
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

resource "aws_iam_policy" "lamda-vpc-policy" {
  name = "cl-lambda-vpc-policy-${var.env}"
  path = "/"
  description = "IAM policy for vpc from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.lambda-iam.name
  policy_arn = aws_iam_policy.lambda-logging-policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role = aws_iam_role.lambda-iam.name
  policy_arn = aws_iam_policy.lamda-vpc-policy.arn
}

resource "aws_iam_role" "lambda-iam" {
  name = "cl-lambda-iam-${var.env}"
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

  tags = {
    Name = "cl-block-explorer-api_lambda-iam"
    Env = var.env
    Workspace = terraform.workspace
  }
}