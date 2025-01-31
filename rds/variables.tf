variable "private_app_subnet_ids" {
  description = "The IDs of the private app subnets"
}

variable "security_group_dataserver" {
  description = "dataserver-sg ID"
}

variable "availability_zones" {
  description = "A list of availability zones for the subnets"
}

variable "postgresql_role_name" {
  description = "The name of the PostgreSQL role."
  type        = string
  sensitive   = true
}

variable "postgresql_role_password" {
  description = "The password for the PostgreSQL role."
  type        = string
  sensitive   = true
}
