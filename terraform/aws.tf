provider "aws" {
  region = var.aws_default_region
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
