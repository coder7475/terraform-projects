variable "primary_region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region for resources"
}

variable "secondary_region" {
  type = string
  default = "ap-northeast-1"
}

variable "bucket_name" {
  type = string
  default = "project-2-bucket-1"
}

variable "env" {
  type = string
  default = "development"
}

variable "primary_vpc_cidr" {
  default = "10.0.0.0/16"
}


variable "secondary_vpc_cidr" {
  default = "10.1.0.0/16"
}