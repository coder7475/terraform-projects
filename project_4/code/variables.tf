variable "aws_region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region for resources"
}

variable "app_name" {
  type = string
  default = "bg-deployment"
}

variable "env" {
  type = string
  default = "development"
}

variable "solution_stack_name" {
  description = "Elastic Beanstalk solution stack name (platform)"
  type        = string
  # Node.js 20 running on 64bit Amazon Linux 2023
  default = "64bit Amazon Linux 2023 v6.6.8 running Node.js 20"
}

variable "instance_type" {
  description = "EC2 instance type for Elastic Beanstalk environments"
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "BlueGreenDeployment"
    Environment = "Demo"
    ManagedBy   = "Terraform"
  }
}



