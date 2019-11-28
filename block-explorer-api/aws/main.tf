provider "aws" {
  version    = "~> 2.0"
  region = "${var.region}"
  access_key = "${var.access-key}"
  secret_key = "${var.secret-key}"
}


/*
  API Gateway
*/
resource "aws_api_gateway_rest_api" "block-explorer-api-gateway" {
  name = "block-explorer-api-gateway"
}

resource "aws_api_gateway_resource" "block-explorer-api-gateway-resources-list" {
  path_part = "{resource}"
  parent_id = "${aws_api_gateway_rest_api.block-explorer-api-gateway.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.block-explorer-api-gateway.id}"
}

resource "aws_api_gateway_resource" "block-explorer-api-gateway-resources-unit" {
  path_part = "{id}"
  parent_id = "${aws_api_gateway_resource.block-explorer-api-gateway-resources-list.id}"
  rest_api_id = "${aws_api_gateway_rest_api.block-explorer-api-gateway.id}"
}

resource "aws_api_gateway_method" "block-explorer-api-gateway-method" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = "${aws_api_gateway_resource.block-explorer-api-gateway-resources-unit.id}"
  rest_api_id = "${aws_api_gateway_rest_api.block-explorer-api-gateway.id}"

  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.path.id" = true
    "method.request.path.resource" = true
  }
}

resource "aws_api_gateway_integration" "block-explorer-api-gateway-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.block-explorer-api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.block-explorer-api-gateway-resources-unit.id}"
  http_method = "${aws_api_gateway_method.block-explorer-api-gateway-method.http_method}"
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "${aws_lambda_function.block-explorer-api-lambda-function.invoke_arn}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}


/*
  API Gateway Deployment
*/
resource "aws_api_gateway_deployment" "block-explorer-api-gateway-deployment" {
  depends_on  = [
    "aws_api_gateway_integration.block-explorer-api-gateway-integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.block-explorer-api-gateway.id}"
  stage_name  = "block-explorer-api-dev"
}


/*
  Lambda function
*/
resource "aws_lambda_function" "block-explorer-api-lambda-function" {
  filename = "block-explorer-api-lambda.jar"
  function_name = "block-explorer-api"
  handler = "org.constellation.blockexplorer.api.Handler::handleRequest"
  role = "${aws_iam_role.block-explorer-api-lambda-iam.arn}"
  runtime = "java8"
  timeout = 360
  memory_size = 768

  vpc_config {
    security_group_ids = ["${var.lambdaSecurityGroupId}"]
    subnet_ids = ["${var.lambdaSubnetId}"]
  }
}

resource "aws_lambda_permission" "block-explorer-api-gateway-lambda-permission" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.block-explorer-api-lambda-function.function_name}"
  principal = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.block-explorer-api-gateway.id}/*/${aws_api_gateway_method.block-explorer-api-gateway-method.http_method}${aws_api_gateway_resource.block-explorer-api-gateway-resources-unit.path}"
}


/*
  Permission for lambda function
*/
resource "aws_iam_policy" "block-explorer-api-lambda-logging-policy" {
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

resource "aws_iam_policy" "block-explorer-api-lamda-vpc-policy" {
  name = "lambda-vpc-policy"
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
  role = "${aws_iam_role.block-explorer-api-lambda-iam.name}"
  policy_arn = "${aws_iam_policy.block-explorer-api-lambda-logging-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role = "${aws_iam_role.block-explorer-api-lambda-iam.name}"
  policy_arn = "${aws_iam_policy.block-explorer-api-lamda-vpc-policy.arn}"
}

resource "aws_iam_role" "block-explorer-api-lambda-iam" {
  name = "block-explorer-api-lambda-iam"
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


/*
  Cloudwatch group
*/
resource "aws_cloudwatch_log_group" "block-explorer-api-cloud-watch" {
  name              = "/aws/lambda/${aws_lambda_function.block-explorer-api-lambda-function.function_name}"
  retention_in_days = 7
}