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

variable "primary_subnet_cidr" {
  description = "CIDR block for the primary subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for the secondary subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "primary_key_name" {
  description = "Name of the SSH key pair for Primary VPC instance (ap-southeast-1)"
  type        = string
  default     = ""
}

variable "secondary_key_name" {
  description = "Name of the SSH key pair for Secondary VPC instance (ap-northeast-1)"
  type        = string
  default     = ""
}