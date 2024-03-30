resource "aws_api_gateway_rest_api" "database_toolkit" {
  name = "database_toolkit"
}

resource "aws_api_gateway_resource" "ingestion" {
  path_part   = "ingestion"
  parent_id   = aws_api_gateway_rest_api.database_toolkit.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.database_toolkit.id
}
resource "aws_api_gateway_resource" "create-backup" {
  path_part   = "create-backup"
  parent_id   = aws_api_gateway_rest_api.database_toolkit.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.database_toolkit.id
}
resource "aws_api_gateway_resource" "restore-backup" {
  path_part   = "restore-backup"
  parent_id   = aws_api_gateway_rest_api.database_toolkit.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.database_toolkit.id
}



resource "aws_api_gateway_method" "ingestion" {
  rest_api_id      = aws_api_gateway_rest_api.database_toolkit.id
  resource_id      = aws_api_gateway_resource.ingestion.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}
resource "aws_api_gateway_method" "create-backup" {
  rest_api_id      = aws_api_gateway_rest_api.database_toolkit.id
  resource_id      = aws_api_gateway_resource.create-backup.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}
resource "aws_api_gateway_method" "restore-backup" {
  rest_api_id      = aws_api_gateway_rest_api.database_toolkit.id
  resource_id      = aws_api_gateway_resource.restore-backup.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}


# Authorization
resource "aws_api_gateway_api_key" "database_toolkit" {
  name = "database_toolkit"
}

# Deployment
resource "aws_api_gateway_deployment" "database_toolkit" {
  rest_api_id = aws_api_gateway_rest_api.database_toolkit.id
  stage_name  = "deploy"
}
resource "aws_api_gateway_usage_plan" "database_toolkit" {
  name = "database_toolkit"

  api_stages {
    api_id = aws_api_gateway_rest_api.database_toolkit.id
    stage  = aws_api_gateway_deployment.database_toolkit.stage_name
  }
}
resource "aws_api_gateway_usage_plan_key" "database_toolkit" {
  key_id        = aws_api_gateway_api_key.database_toolkit.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.database_toolkit.id
}



resource "aws_api_gateway_integration" "ingestion" {
  rest_api_id             = aws_api_gateway_rest_api.database_toolkit.id
  resource_id             = aws_api_gateway_resource.ingestion.id
  http_method             = aws_api_gateway_method.ingestion.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ingestion.invoke_arn
}
resource "aws_api_gateway_integration" "create-backup" {
  rest_api_id             = aws_api_gateway_rest_api.database_toolkit.id
  resource_id             = aws_api_gateway_resource.create-backup.id
  http_method             = aws_api_gateway_method.create-backup.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create-backup.invoke_arn
}
resource "aws_api_gateway_integration" "restore-backup" {
  rest_api_id             = aws_api_gateway_rest_api.database_toolkit.id
  resource_id             = aws_api_gateway_resource.restore-backup.id
  http_method             = aws_api_gateway_method.restore-backup.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.restore-backup.invoke_arn
}


resource "aws_lambda_permission" "ingestion" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingestion.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.database_toolkit.execution_arn}/*/*"
}
resource "aws_lambda_permission" "create-backup" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create-backup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.database_toolkit.execution_arn}/*/*"
}
resource "aws_lambda_permission" "restore-backup" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.restore-backup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.database_toolkit.execution_arn}/*/*"
}



