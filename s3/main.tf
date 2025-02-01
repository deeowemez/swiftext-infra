# resource "aws_s3_bucket" "static" {
#   bucket              = var.s3_bucket_name
#   object_lock_enabled = false

#   tags = {
#     Name = var.s3_bucket_name
#   }


# }

# resource "aws_s3_bucket_public_access_block" "static" {
#   bucket = aws_s3_bucket.static.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_bucket_website_configuration" "static" {
#   bucket = aws_s3_bucket.static.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "index.html"
#   }
# }

# resource "aws_s3_bucket_policy" "allow_read_access_to_static_bucket" {
#   bucket = aws_s3_bucket.static.id
#   policy = data.aws_iam_policy_document.allow_read_access_to_static_bucket.json
# }

# data "aws_iam_policy_document" "allow_read_access_to_static_bucket" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     actions = [
#       "s3:GetObject",
#     ]

#     resources = [
#       aws_s3_bucket.static.arn,
#       "${aws_s3_bucket.static.arn}/*",
#     ]
#   }
# }

# resource "aws_s3_bucket_cors_configuration" "static" {
#   bucket = aws_s3_bucket.static.id

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
#     allowed_origins = [var.bucket_website_endpoint]
#     expose_headers  = ["ETag"]
#     max_age_seconds = 3000
#   }
# }
