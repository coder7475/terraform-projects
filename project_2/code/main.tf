resource "aws_vpc" "primary_vpc" {
  cidr_block       = var.primary_vpc_cidr
  provider = aws.primary
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "Primary-VPC-${var.primary_region}"
  }
}

resource "aws_vpc" "secondary_vpc" {
  cidr_block       = var.secondary_vpc_cidr
  provider = aws.primary
  enable_dns_hostnames=true
  enable_dns_support =true
  instance_tenancy = "default"

  tags = {
    Name = "Secondary-VPC-${var.secondary_region}"
  }
}