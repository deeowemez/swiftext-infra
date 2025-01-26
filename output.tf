# VPC Output Values
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the created subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "The IDs of the created subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  description = "The IDs of the created subnets"
  value       = module.vpc.private_data_subnet_ids
}

# S3 Bucket Output Values
output "s3_bucket_name" {
  description = "The name of the bucket"
  value       = module.s3.s3_bucket_name
}

output "s3_bucket_domain_name" {
  description = "The domain name of the bucket"
  value       = module.s3.s3_bucket_domain_name
}

output "website_domain" {
  description = "The domain name of the website endpoint"
  value       = module.s3.website_domain
}

output "website_endpoint" {
  description = "The website endpoint"
  value       = module.s3.website_endpoint
}