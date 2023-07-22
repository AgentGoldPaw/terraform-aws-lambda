variable "filename" {
  type = string
}

variable "name" {
  type = string
}

variable "permissions" {
  type    = object({
    Statement = list(object({
      Effect   = string
      Action   = list(string)
      Resource = string
    }))
    Version = string
  })
  default = null
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
}

variable "timeout" {
  type = number
}

variable "dynamo_stream" {
  type    = string
  default = null
}

variable "sqs_queue" {
  type    = string
  default = null
}

variable "dynamo_stream_cloudwatch" {
  type    = bool
  default = false
}

variable "memory_size" {
  type = number
}

variable "source_code_hash" {
  type = string
}

variable "environment" {
  type = map(string)
}

variable "tracing_config" {
  type = bool
}

variable "function_type" {
  type = string
}