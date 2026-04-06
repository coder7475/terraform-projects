variable "aws_region" {
  description = "AWS region for resources"
  type = string
  default = "ap-southeast-1"
}

variable "environment" {
  description = "Environment Name"
  type = string
  default = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type = string
  default = "image-processor"
}