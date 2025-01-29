resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "appserver_key" {
  key_name   = "appserver_key"
  public_key = tls_private_key.appserver_key.public_key_openssh
}

resource "tls_private_key" "appserver_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}