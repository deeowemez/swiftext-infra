# Ellastic IP Creation for NAT-GW
resource "aws_eip" "nat_gw" {
  # vpc   = true
  count = length(var.availability_zones)

  tags = {
    Name = "nat-gw-elastic-ip-${count.index + 1}"
  }
}

# NAT Gateway Creation
resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "nat-gw-${count.index}"
  }

  depends_on = [aws_internet_gateway.igw]
}