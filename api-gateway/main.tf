provider "aws"{
    region = "ap-southeast-2"
}
#creating the rest api
resource "aws_api_gateway_rest_api" "test_api" {
    name        = "test-api"
    description = "testing API Gateway through terraform"
    endpoint_configuration {
        types = ["REGIONAL"]
    }
}
#creating the resource
resource "aws_api_gateway_resource" "api_resource"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    parent_id = aws_api_gateway_rest_api.test_api.root_resource_id
    path_part = "api"
}
#GET METHOD
resource "aws_api_gateway_method" "get_method_response"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = "GET"
    authorization = "NONE"
}
#creating the method response
resource "aws_api_gateway_method_response" "get_method_response"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = aws_api_gateway_method.get_method_response.http_method
    status_code = "200"

    #cors configuration
    response_parameters ={
        "method.response.header.Access-Control-Allow-Origin" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Headers" = true
    }
}
#IAM role for lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
#attaching the policy to the role
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda_basic_execution_attachment"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#creating lambda function for the get method integration
resource "aws_lambda_function" "sample_lambda"{
    filename = "lambda_function.zip"
    function_name = "sample_lambda"
    handler= "lambda_function.lambda_handler"
    runtime = "python3.9"
    role  = aws_iam_role.lambda_exec_role.arn
}

resource "aws_lambda_permission" "sample_lambda_permission"{
    statement_id = "AllowAPIGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.sample_lambda.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_api_gateway_rest_api.test_api.execution_arn}/*/*"
}

#creating the integration(integration request) between the lambda function and the get method
resource "aws_api_gateway_integration" "sample_integration"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = aws_api_gateway_method.get_method_response.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.sample_lambda.invoke_arn
    depends_on = [ aws_lambda_permission.sample_lambda_permission ]
}
#creating the integration response
resource "aws_api_gateway_integration_response" "sample_integration_response"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = aws_api_gateway_method.get_method_response.http_method
    status_code = aws_api_gateway_method_response.get_method_response.status_code

    depends_on = [ aws_api_gateway_integration.sample_integration,
                   aws_api_gateway_method_response.get_method_response 
                ]
    #cors configuration
    response_parameters ={
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    }
}
#OPTIONS METHOD
resource "aws_api_gateway_method" "options_method"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_method_response"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = aws_api_gateway_method.options_method.http_method
    status_code = "200"
    response_parameters ={
        "method.response.header.Access-Control-Allow-Origin" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Headers" = true
    }
}

resource "aws_api_gateway_integration" "options_method_integration"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = aws_api_gateway_method.options_method.http_method
    integration_http_method = "OPTIONS"
    type = "MOCK"
    request_templates = {
        "application/json" = "{ \"statusCode\": 200 }"
    }
    
}
resource "aws_api_gateway_integration_response" "options_method_integration_response"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = aws_api_gateway_method.options_method.http_method
    status_code = "200"
    depends_on = [ aws_api_gateway_integration.options_method_integration,
                   aws_api_gateway_method_response.options_method_response
                ]
    response_parameters ={
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    }
}
#POST METHOD
resource "aws_api_gateway_method" "post_method"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = "POST"
    authorization = "NONE"
}
resource "aws_api_gateway_method_response" "post_method_response"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = aws_api_gateway_method.post_method.http_method
    status_code = "200"

    response_parameters ={
        "method.response.header.Access-Control-Allow-Origin" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Headers" = true
    }
}
#creating the lambda function for the post method integration
resource "aws_lambda_function" "post_lambda"{
    filename = "post_function.zip"
    function_name = "post_lambda"
    handler= "post_function.lambda_handler"
    runtime = "python3.9"
    role  = aws_iam_role.lambda_exec_role.arn
}
resource "aws_lambda_permission" "post_lambda_permission"{
    statement_id = "AllowAPIGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.post_lambda.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_api_gateway_rest_api.test_api.execution_arn}/*/*"
}
resource "aws_api_gateway_integration" "post_method_integration"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = aws_api_gateway_method.post_method.http_method
    integration_http_method = "POST"
    type = "MOCK"
    uri = aws_lambda_function.post_lambda.invoke_arn
    request_templates = {
        "application/json" = "{ \"statusCode\": 200 }"
    }
}
resource "aws_api_gateway_integration_response" "post_method_integration_response"{
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.api_resource.id
    http_method = aws_api_gateway_method.post_method.http_method
    status_code = aws_api_gateway_method_response.post_method_response.status_code
    depends_on = [ aws_api_gateway_integration.post_method_integration,
                   aws_api_gateway_method_response.post_method_response
                ]
    response_parameters ={
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    }
}
#creating the deployment
resource "aws_api_gateway_deployment" "test_api_deployment"{
    depends_on = [ aws_api_gateway_integration.sample_integration,
                   aws_api_gateway_integration.options_method_integration,
                   aws_api_gateway_integration.post_method_integration
                ]
    rest_api_id = aws_api_gateway_rest_api.test_api.id
}
#creating the stage
resource "aws_api_gateway_stage" "test_api_stage" {
    stage_name = "test"
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    deployment_id = aws_api_gateway_deployment.test_api_deployment.id
    description = "test stage"
    cache_cluster_enabled = false
    tags = {
        "Name" = "test"
    }
}