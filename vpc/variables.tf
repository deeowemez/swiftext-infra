variable "base_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones for the subnets"
  type        = list(string)
}

variable "vpc_name" {
  description = "The name tag for the VPC"
  default     = "swiftext-vpc"
}
