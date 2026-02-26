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

resource "aws_subnet" "primary_subnet" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id
  cidr_block = var.primary_subnet_cidr
  availability_zone = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Primary-Subnet-${var.primary_region}"
    Environment = "Development"
  }
}

resource "aws_subnet" "secondary_subnet" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id
  cidr_block = var.secondary_subnet_cidr
  availability_zone = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Secondary-Subnet-${var.secondary_region}"
    Environment = "Development"
  }
}

resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id

  tags = {
    Name = "Primary-IGW-${var.primary_region}"
    Environment = "Development"
  }
}

resource "aws_internet_gateway" "secondary_igw" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id

  tags = {
    Name = "Secondary-IGW-${var.secondary_region}"
    Environment = "Development"
  }
}


resource "aws_route_table" "primary_rt" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.primary_igw.id
    }
  

  tags = {
    Name = "Primary-RouteTable-${var.primary_region}"
    Environment = "Development"
  }
}

resource "aws_route_table" "secondary_rt" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.secondary_igw.id
  }

  tags = {
    Name = "Secondary-RouteTable-${var.secondary_region}"
    Environment = "Development"
  }
  
}

resource "aws_route_table_association" "primary_rta" {
  provider = aws.primary
  subnet_id = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_rt.id
}

resource "aws_route_table_association" "secondary_rta" {
  provider = aws.secondary
  subnet_id = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_rt.id
}

# VPC Peering Connection (Requester Side - Primary VPC)
resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id
  peer_vpc_id = aws_vpc.secondary_vpc.id
  peer_region = var.secondary_region
  auto_accept = false

  tags = {
    Name = "Primary-to-Secondary-Peering"
    Environment = "Development"
    Side = "Requester"
  }
}

# VPC Peering Connection (Accepter Side - Secondary VPC)
resource "aws_vpc_peering_connection_accepter" "secondary_accepts_primary" {
  provider = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept = true
  tags = {
    Name = "Secondary-Accepts-Primary-Peering"
    Environment = "Development"
    Side = "Accepter"
  }
}

# Add route to Secondary VPC in Primary Route Table
resource "aws_route" "primary_to_secondary_route" {
  provider = aws.primary
  route_table_id = aws_route_table.primary_rt.id
  destination_cidr_block = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [ aws_vpc_peering_connection_accepter.secondary_accepts_primary]
}

# Add route to Primary VPC in Secondary Route Table
resource "aws_route" "secondary_to_primary_route" {
  provider = aws.secondary
  route_table_id = aws_route_table.secondary_rt.id
  destination_cidr_block = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  depends_on = [ aws_vpc_peering_connection.primary_to_secondary]
}

