terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }

  backend "s3" {}

  required_version = "1.10.4"
}
