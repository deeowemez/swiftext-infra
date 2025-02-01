variable "vpc_id" {
  description = "The ID of the created VPC"
}

variable "appserver_instance_ids" {
  description = "The IDs of the created app server instances"
}

variable "availability_zones" {
  description = "A list of availability zones for the subnets"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "The IDs of the private app subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type        = list(string)
}

variable "instance_type" {
  description = "The instance type for the appserver and dataserver"
  default = "t2.micro"
}

variable "ami" {
  description = "The ami for the appserver and dataserver"
  # default = "ami-0672fd5b9210aa093"
  default = "ami-0277ea6d87dd09cd4"
}

variable "appserver_sg_id" {
  description = "The ID for the appserver sg"
}

variable "bastion_sg_id" {
  description = "The ID for the bastion host sg"
}

# variable "iam_instance_profile" {
#   description = "The instance profile attached to appserver instance"
# }