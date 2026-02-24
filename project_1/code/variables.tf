variable "aws_region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region for resources"
}

variable "bucket_name" {
  type = string
  default = "project-1-bucket-1"
}