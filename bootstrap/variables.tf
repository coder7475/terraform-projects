variable "aws_region" {
  type = string
  default = "ap-southeast-1"
}

variable "bucket_name" {
  type = string
  description = "Name for the Terraform state S3 bucket"
  default = "tf-state-bootstrap"
}

variable "env" {
  type = string
  default = "development"
}