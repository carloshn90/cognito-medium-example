terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "royal_cognito" {
  source = "./cognito"
}

module "util_layer" {
  source = "./util-layer"
}

module "royal_api" {
  source                 = "./api-gateway"
  cognito_user_arn       = module.royal_cognito.royal_cognito_user_pool_arn
  api_status_response    = ["200", "500"]
  aws_region             = var.aws_region
  account_id             = var.account_id
  util_layer_arn_array   = module.util_layer.util_layer_arn_array
}
