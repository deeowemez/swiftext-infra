# Application Server and Bastion Host Instance Creation
resource "aws_instance" "appserver" {
  count         = length(var.private_app_subnet_ids)
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.private_app_subnet_ids[count.index]

  tags = {
    Name = "appserver-${count.index}"
  }
}

resource "aws_instance" "bastion_host" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[0]

  tags = {
    Name = "bastion-host"
  }
}
