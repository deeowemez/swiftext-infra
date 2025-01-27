resource "aws_instance" "appserver" {
    count = length(var.availability_zones)
}