variable "primary_region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region for resources"
}

variable "secondary_region" {
  type = string
  default = "ap-south-2"
}

variable "bucket_name" {
  type = string
  default = "project-2-bucket-1"
}

variable "env" {
  type = string
  default = "development"
}