output "s3_bucket_name" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.static.id
}

output "s3_bucket_domain_name" {
  description = "The domain name of the bucket"
  value       = aws_s3_bucket.static.bucket_domain_name
}

# output "website_domain" {
#   description = "The domain name of the website endpoint"
#   value       = aws_s3_bucket_website_configuration.static.website_domain
# }

# output "website_endpoint" {
#   description = "The website endpoint"
#   value       = aws_s3_bucket_website_configuration.static.website_endpoint
# }