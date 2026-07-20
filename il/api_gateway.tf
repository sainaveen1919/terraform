resource "aws_api_gateway_rest_api" "services" {
  name = "${var.name}-services-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "${var.name}-cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.services.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.api.arn]
}

resource "aws_api_gateway_resource" "service" {
  for_each = toset(var.api_services)

  rest_api_id = aws_api_gateway_rest_api.services.id
  parent_id   = aws_api_gateway_rest_api.services.root_resource_id
  path_part   = "${each.value}-service"
}

resource "aws_api_gateway_method" "service" {
  for_each = aws_api_gateway_resource.service

  rest_api_id   = aws_api_gateway_rest_api.services.id
  resource_id   = each.value.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "service" {
  for_each = aws_api_gateway_method.service

  rest_api_id = aws_api_gateway_rest_api.services.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_deployment" "services" {
  rest_api_id = aws_api_gateway_rest_api.services.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.service,
      aws_api_gateway_method.service,
      aws_api_gateway_integration.service
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "services" {
  deployment_id = aws_api_gateway_deployment.services.id
  rest_api_id   = aws_api_gateway_rest_api.services.id
  stage_name    = "v1"
}
