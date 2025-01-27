variable "alb_sg_id" {
  description = "The ID of the alb sg"
}

variable "public_subnet_ids" {
  description = "The IDs of the created public subnets"
}

variable "vpc_id" {
  description = "The ID of the created VPC"
}

variable "appserver_instance_ids" {
  description = "The IDs of the created app server instances"
}