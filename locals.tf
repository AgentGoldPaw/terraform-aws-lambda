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
  }
  function_types = {
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
  dynamo_stream_cloudwatch_statement = merge(local.built_in_permissions.DYNAMO, {
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })

  permissions = var.function_type == "DYNAMO" ? jsonencode(local.built_in_permissions[var.function_type]) : var.permissions
  final_permissions = var.dynamo_stream_cloudwatch ? jsonencode(local.dynamo_stream_cloudwatch_statement) : local.permissions
}