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

# Random ID for unique bucket names
resource "random_id" "suffix" {
  byte_length = 4
}
