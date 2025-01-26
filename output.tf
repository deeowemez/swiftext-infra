# VPC Output Values
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.vpc.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  value = module.vpc.private_data_subnet_ids
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "aws_eip_id" {
  value = module.vpc.aws_eip_id
}

output "aws_nat_gw_id" {
  value = module.vpc.aws_nat_gw_id
}

output "public_subnet_route_table_associations" {
  value = module.vpc.public_subnet_route_table_associations
}

output "private_appserver_subnet_route_table_associations" {
  value = module.vpc.private_appserver_subnet_route_table_associations
}

output "private_dataserver_subnet_route_table_associations" {
  value = module.vpc.private_dataserver_subnet_route_table_associations
}

output "aws_vpc_endpoint_dynamo_id" {
  value = module.vpc.aws_vpc_endpoint_dynamo_id
}

output "aws_vpc_endpoint_dynamo_route_table_associations" {
  value = module.vpc.aws_vpc_endpoint_dynamo_route_table_associations
}

# S3 Bucket Output Values
output "s3_bucket_name" {
  value = module.s3.s3_bucket_name
}

output "s3_bucket_domain_name" {
  value = module.s3.s3_bucket_domain_name
}

output "website_domain" {
  value = module.s3.website_domain
}

output "website_endpoint" {
  value = module.s3.website_endpoint
}