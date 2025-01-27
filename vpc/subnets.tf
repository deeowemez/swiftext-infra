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