output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
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