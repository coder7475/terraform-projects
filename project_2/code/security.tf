# Security Group for Primary VPC
resource "aws_security_group" "primary_sg" {
  provider = aws.primary
  name = "primary-vpc-sg"
  description = "Security group for Primary VPC"
  vpc_id = aws_vpc.primary_vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  ingress {
    description = "Allow all traffic from Secondary VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Primary-SG-${var.primary_region}"
    Environment = "Development"
  }
}

# Security Group for Secondary VPC
resource "aws_security_group" "secondary_sg" {
  provider = aws.secondary
  name = "secondary-vpc-sg"
  description = "Security group for Secondary VPC"
  vpc_id = aws_vpc.secondary_vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  ingress {
    description = "Allow all traffic from Primary VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Secondary-SG-${var.secondary_region}"
    Environment = "Development"
  }
}