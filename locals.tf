locals {
  built_in_permissions = {
    DYNAMO = {
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Resource = var.dynamo_stream
        }
      ]
    }
    SQS = {
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Resource = var.sqs_queue
        }
      ]
    }
  }
  function_types = {
    SQS = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    })
    DYNAMO = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    })
    APIGW = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    })
  }
  dynamo_stream_cloudwatch_statement = {
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:*:*:*"
  }

  dynamo_stream_cloudwatch_policy = {
    Version = "2012-10-17"
    Statement = [local.dynamo_stream_cloudwatch_statement, local.built_in_permissions["DYNAMO"].Statement[0]]
  }

  permissions = var.function_type == "DYNAMO" ? local.built_in_permissions[var.function_type] : var.permissions
  final_permissions = var.dynamo_stream_cloudwatch ? local.dynamo_stream_cloudwatch_policy : local.permissions
}