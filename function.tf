terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
  }
}

resource "aws_lambda_function" "the-function" {
  filename         = var.filename
  function_name    = var.name
  role             = module.iam-role.role.arn
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  source_code_hash = var.source_code_hash

  environment {
    variables = var.environment
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config ? [1] : []
    content {
      mode = "Active"
    }
  }
}

resource "aws_lambda_event_source_mapping" "lambda_trigger" {
  count             = var.function_type == "DYNAMO" ? 1 : 0
  event_source_arn  = var.dynamo_stream
  function_name     = aws_lambda_function.the-function.function_name
  starting_position = "LATEST"
}

module "iam-role" {
  source        = "RedMunroe/iam-role/aws"
  version       = "0.0.1"
  name          = "${var.name}-role"
  description   = "Role for ${var.name} function"
  assume_policy = local.function_types[var.function_type]
  policy_name   = "${var.name}-policy"
  policy        = var.function_type == "DYNAMO" ? var.dynamo_stream_cloudwatch ? local.dynamo_stream_cloudwatch_statement : local.built_in_permissions.DYNAMO : var.permissions
}