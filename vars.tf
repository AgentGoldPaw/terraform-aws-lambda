variable "filename" {
  type = string
}

variable "name" {
  type = string
}

variable "permissions" {
  type = string
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