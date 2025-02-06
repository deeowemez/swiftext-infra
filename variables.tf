variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "ap-southeast-1"
}

# variable "postgresql_role_name" {
#   description = "The name of the PostgreSQL role."
#   type        = string
#   sensitive   = true
# }

# variable "postgresql_role_password" {
#   description = "The password for the PostgreSQL role."
#   type        = string
#   sensitive   = true
# }

variable "git_username" {
  description = "Username in Git"
}

variable "git_pat" {
  description = "Pat in Git account"
}

variable "db_password" {
  description = "Password for psql rds role"
}

variable "jwt_secret" {
  description = "jwt token"
}