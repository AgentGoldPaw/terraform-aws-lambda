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

resource "aws_lambda_event_source_mapping" "lambda_trigger_sqs" {
  count             = var.function_type == "SQS" ? 1 : 0
  event_source_arn  = var.sqs_queue
  function_name     = aws_lambda_function.the-function.function_name
}

data "aws_iam_policy_document" "source_document_example" {
  count = var.function_type == "DYNAMO" || var.function_type == "APIGW" ? 1 : 0
  source_policy_documents = var.permissions != null ? [jsonencode(local.final_permissions), jsonencode(var.permissions)] : [jsonencode(local.final_permissions)]
}

data "aws_iam_policy_document" "source_document_example_sqs" {
  count = var.function_type == "SQS" ? 1 : 0
  source_policy_documents = var.permissions != null ? [jsonencode(var.permissions), jsonencode(local.built_in_permissions[var.function_type])] : [jsonencode(local.built_in_permissions[var.function_type])]
}

module "iam-role" {
  source        = "RedMunroe/iam-role/aws"
  version       = "0.0.1"
  name          = "${var.name}-role"
  description   = "Role for ${var.name} function"
  assume_policy = local.function_types[var.function_type]
  policy_name   = "${var.name}-policy"
  policy        = var.function_type == "DYNAMO" ? data.aws_iam_policy_document.source_document_example[0].json : var.function_type == "SQS" ? data.aws_iam_policy_document.source_document_example_sqs[0].json : jsonencode(var.permissions)
}