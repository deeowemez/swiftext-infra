resource "aws_vpc" "main" {
  cidr_block       = var.base_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

# Subnet Creation
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_app" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + 4)
  map_public_ip_on_launch = true

  tags = {
    Name = "private-subnet-appserver-${count.index + 1}"
  }
}

resource "aws_subnet" "private_data" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + 7)
  map_public_ip_on_launch = true

  tags = {
    Name = "private-subnet-dataserver-${count.index + 1}"
  }
}

# Internet Gateway Creation and Attachment
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "swiftext-igw"
  }
}

# Ellastic IP Creation for NAT-GW
resource "aws_eip" "nat_gw" {
  vpc   = true
  count = length(var.availability_zones)

  tags = {
    Name = "nat-gw-elastic-ip-${count.index + 1}"
  }
}

# NAT Gateway Creation
resource "aws_nat_gateway" "nat_gw" {
  count = length(var.availability_zones)
  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "gw-NAT"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route Table Creation and Association
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count  = length(var.availability_zones)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "appserver" {
  vpc_id = aws_vpc.main.id
  count  = length(var.availability_zones)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }
}

resource "aws_route_table_association" "appserver" {
  count  = length(var.availability_zones)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.appserver[count.index].id
}

resource "aws_route_table_association" "dataserver" {
  count  = length(var.availability_zones)
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_vpc.main.default_route_table_id
}

# VPC Gateway Endpoint Creation and Association
resource "aws_vpc_endpoint" "dynamo" {
  vpc_id = aws_vpc.main.id
  service_name = "com.amazonaws.ap-southeast-1.dynamodb"

  tags = {
    Name = "dynamo-endpoint"
  }
}

resource "aws_vpc_endpoint_route_table_association" "dynamo_route_table_assoc" {
  count = length(var.availability_zones)
  route_table_id = aws_route_table.appserver[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.dynamo.id
}

