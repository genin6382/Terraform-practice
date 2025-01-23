output "aws_api_gateway_rest_api_id" {
  value = aws_api_gateway_rest_api.test_api.id
}
output "aws_api_gateway_resource_id" {
  value = aws_api_gateway_resource.api_resource.id
}
output "aws_api_gateway_get_method_id" {
  value = aws_api_gateway_method.get_method_response.id
}
output "aws_api_gateway_get_integration_id" {
  value = aws_api_gateway_integration.sample_integration.id
}
output "aws_lambda_function_name" {
  value = aws_lambda_function.sample_lambda.function_name
}
output "aws_api_gateway_options_method_id" {
  value = aws_api_gateway_method.options_method.id
}
output "aws_api_gateway_post_method_id" {
  value = aws_api_gateway_method.post_method.id
}