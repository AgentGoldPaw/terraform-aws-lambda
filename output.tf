output "arn" {
    value = aws_lambda_function.the-function.arn
}

output "name" {
    value = aws_lambda_function.the-function.function_name
}

output "invoke_arn" {
  value       = aws_lambda_function.the-function.invoke_arn
  description = "The ARN to be used for invoking Lambda Function from API Gateway"
}