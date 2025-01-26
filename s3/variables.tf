variable "s3_bucket_name" {
  description = "The name of the bucket"
  default     = "swiftext-static"
}

variable "bucket_website_endpoint" {
  description = "The bucket website endpoint"
  default     = "http://swiftext-static.s3-website-ap-southeast-1.amazonaws.com"
}
