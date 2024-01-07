resource "aws_api_gateway_rest_api" "rest_api" {
  name = "my-rest-api"
}

resource "aws_api_gateway_resource" "get-messages" {
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = "messages"
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_resource" "get-name" {
  parent_id = aws_api_gateway_resource.get-messages.id
  path_part = "name"
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_method" "get-message-method" {
  authorization = "NONE"
  http_method = "GET"
  api_key_required = false
  resource_id = aws_api_gateway_resource.get-name.id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}


resource "aws_api_gateway_method_response" "get-message_method_response_200"{
    rest_api_id = aws_api_gateway_rest_api.rest_api.id
    resource_id = aws_api_gateway_resource.get-name.id
    http_method = aws_api_gateway_method.get-message-method.http_method
    status_code = "200"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }

    depends_on = [ 
        aws_api_gateway_method.get-message-method
     ]
}


resource "aws_api_gateway_integration" "get-message-integration" {
  http_method = aws_api_gateway_method.get-message-method.http_method
  resource_id = aws_api_gateway_resource.get-name.id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  integration_http_method = "POST"
  passthrough_behavior = "WHEN_NO_MATCH"
  type = "AWS_PROXY" 
  uri = aws_lambda_function.my_lambda.invoke_arn
  depends_on = [ 
    aws_api_gateway_method.get-message-method,
    aws_lambda_function.my_lambda
   ]
}


resource "aws_api_gateway_deployment" "deploy" {
    rest_api_id = aws_api_gateway_rest_api.rest_api.id
    depends_on = [ 
        aws_api_gateway_integration.get-message-integration
     ]
     stage_description = "Deployed at ${timestamp()}"
     lifecycle {
       create_before_destroy = true
     }
}

resource "aws_api_gateway_stage" "my-stage" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name = "my-deployed-stage"
}

output "apigw_url" {
  value = aws_api_gateway_deployment.deploy.invoke_url
}


