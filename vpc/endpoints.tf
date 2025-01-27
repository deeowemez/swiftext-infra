# VPC Gateway Endpoint Creation and Association
resource "aws_vpc_endpoint" "dynamo" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-southeast-1.dynamodb"

  tags = {
    Name = "dynamo-endpoint"
  }
}

resource "aws_vpc_endpoint_route_table_association" "dynamo_route_table_assoc" {
  count           = length(var.availability_zones)
  route_table_id  = aws_route_table.appserver[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.dynamo.id
}