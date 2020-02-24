resource "aws_api_gateway_rest_api" "api-gateway" {
  name = "cl-block-explorer-api-gateway-${var.env}"

  tags = {
    Name = "cl-block-explorer-api_api-gateway"
    Env = var.env
    Workspace = terraform.workspace
  }
}

resource "aws_api_gateway_resource" "api-gateway-resources-list" {
  path_part = "{resource}"
  parent_id = aws_api_gateway_rest_api.api-gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
}

resource "aws_api_gateway_resource" "api-gateway-resources-unit" {
  path_part = "{id}"
  parent_id = aws_api_gateway_resource.api-gateway-resources-list.id
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
}

resource "aws_api_gateway_method" "api-gateway-method-unit" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.api-gateway-resources-unit.id
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id

  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.path.id" = true
    "method.request.path.resource" = true
  }
}

resource "aws_api_gateway_method" "api-gateway-method-list" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.api-gateway-resources-list.id
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id

  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.path.resource" = true
  }
}

resource "aws_api_gateway_integration" "api-gateway-integration-unit" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  resource_id = aws_api_gateway_resource.api-gateway-resources-unit.id
  http_method = aws_api_gateway_method.api-gateway-method-unit.http_method
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda-function.invoke_arn

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration" "api-gateway-integration-list" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  resource_id = aws_api_gateway_resource.api-gateway-resources-list.id
  http_method = aws_api_gateway_method.api-gateway-method-list.http_method
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda-function.invoke_arn

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "api-gateway-deployment" {
  depends_on = [
    "aws_api_gateway_integration.api-gateway-integration-list",
    "aws_api_gateway_integration.api-gateway-integration-unit"
  ]
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  stage_name = "cl-block-explorer-${var.env}"
}