variable "cognito_user_arn" {}

variable "api_status_response" {
  description = "API http status response"
  type        = list(string)
}

variable "util_layer_arn_array" {}

variable "aws_region" {}

variable "account_id" {}
