# Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Region
provider "aws" {
  region = var.aws_region
}

resource "random_id" "random_suffix" {
  byte_length = 4
}
