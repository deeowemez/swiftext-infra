output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "availability_zones" {
  description = "A list of availability zones for the subnets"
  value = var.availability_zones
}

output "public_subnet_ids" {
  description = "The IDs of the created subnets"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "The IDs of the private app subnets"
  value       = aws_subnet.private_app[*].id
}

output "private_data_subnet_ids" {
  description = "The IDs of the private data subnets"
  value       = aws_subnet.private_data[*].id
}

output "internet_gateway_id" {
  description = "The ID of the created internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "aws_eip_id" {
  description = "The allocated elastic ip address"
  value       = aws_eip.nat_gw[*].id
}

output "aws_nat_gw_id" {
  description = "The ID of the created nat gateway"
  value       = aws_nat_gateway.nat_gw[*].id
}

output "public_subnet_route_table_associations" {
  description = "Mapping of public subnets to their associated route tables"
  value = { for idx, subnet_id in aws_subnet.public[*].id :
    subnet_id => aws_route_table.public.id
  }
}

output "private_appserver_subnet_route_table_associations" {
  description = "Mapping of appserver subnets to their associated route tables"
  value = { for idx, subnet_id in aws_subnet.private_app[*].id :
  subnet_id => aws_route_table.appserver[idx].id }
}

output "private_dataserver_subnet_route_table_associations" {
  description = "Mapping of dataserver subnets to their associated route tables"
  value = { for idx, subnet_id in aws_subnet.private_data[*].id :
  subnet_id => aws_vpc.main.default_route_table_id }
}

output "aws_vpc_endpoint_dynamo_id" {
  description = "The ID of the DynamoDB VPC Gateway Endpoint"
  value       = aws_vpc_endpoint.dynamo.id
}

output "aws_vpc_endpoint_dynamo_route_table_associations" {
  description = "Mapping of vpc endpoints to their associated route tables"
  value = { for idx, route_table_id in aws_route_table.appserver[*].id :
  route_table_id => aws_vpc_endpoint.dynamo.id }
}

output "security_group_alb" {
  description = "alb-sg ID"
  value       = aws_security_group.alb_sg.id
}

output "security_group_appserver" {
  description = "appserver-sg ID"
  value       = aws_security_group.appserver_sg.id
}

output "security_group_dataserver" {
  description = "dataserver-sg ID"
  value       = aws_security_group.dataserver_sg.id
}

output "security_group_efsmount" {
  description = "efsmount-sg ID"
  value       = aws_security_group.efsmount_sg.id
}

output "security_group_bastion" {
  description = "bastion-sg ID"
  value       = aws_security_group.bastion_sg.id
}