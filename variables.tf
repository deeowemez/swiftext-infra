variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "ap-southeast-1"
}

variable "availability_zones" {
  description = "A list of availability zones for the subnets"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}