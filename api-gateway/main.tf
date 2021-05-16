resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "royal-api"
  description = "Royal API Gateway"
}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  provider_arns = [var.cognito_user_arn]
}

resource "aws_api_gateway_resource" "check_in_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "check-in"
}

resource "aws_api_gateway_method" "check_in_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.check_in_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true,
  }
}

resource "aws_api_gateway_integration" "check_in_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.check_in_resource.id
  http_method             = aws_api_gateway_method.check_in_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.welcome_check_in_message_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "check_in_method_response" {
  for_each    = toset(var.api_status_response)
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.check_in_resource.id
  http_method = aws_api_gateway_method.check_in_api_method.http_method
  status_code = each.value
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "DEV"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "role_api_gateway" {
  name               = "role_royal_api_gateway_lambda"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws_lambda_basic_execution_role_attachment" {
  role       = aws_iam_role.role_api_gateway.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.welcome_check_in_message_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.check_in_api_method.http_method}${aws_api_gateway_resource.check_in_resource.path}"
}

data "archive_file" "welcome_check_in_message_archive_file" {
  type        = "zip"
  source_dir  = "${path.module}/welcome-check-in-message-code"
  output_path = "${path.module}/files/welcome-check-in-message-code.zip"
}

resource "aws_lambda_function" "welcome_check_in_message_lambda" {
  filename      = "${path.module}/files/welcome-check-in-message-code.zip"
  function_name = "welcomeRoyalCheckInMessage"
  role          = aws_iam_role.role_api_gateway.arn
  handler       = "main.handler"
  runtime       = "nodejs14.x"

  layers = var.util_layer_arn_array

  source_code_hash = filebase64sha256(data.archive_file.welcome_check_in_message_archive_file.output_path)
}
