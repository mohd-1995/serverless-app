resource "aws_lambda_permission" "api-gw-lambda-permi" {
  statement_id = "AllowExecutionAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.arn
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.get-message-method.http_method}${aws_api_gateway_resource.get-messages.path}/*"

}

