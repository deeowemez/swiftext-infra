# Application Server and Bastion Host Instance Creation
resource "aws_network_interface" "appserver" {
  depends_on      = [aws_instance.appserver]
  count           = length(var.appserver_instance_ids)
  subnet_id       = var.private_app_subnet_ids[count.index]
  security_groups = [var.appserver_sg_id]
}

resource "aws_network_interface" "bastion_host" {
  depends_on      = [aws_instance.bastion_host]
  subnet_id       = var.public_subnet_ids[0]
  security_groups = [var.bastion_sg_id]
}

locals {
  efs_id              = var.efs_id
  rds_instance_domain = replace(var.rds_instance_endpoint, ":5432", "")
}

resource "aws_instance" "appserver" {
  count         = length(var.private_app_subnet_ids)
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.private_app_subnet_ids[count.index]

  iam_instance_profile = var.iam_instance_profile_arn
  key_name             = aws_key_pair.appserver_key.key_name

  user_data_base64 = base64encode(templatefile("ec2/user-data.sh", {
    efs_id              = local.efs_id
    rds_instance_domain = local.rds_instance_domain
  }))


  user_data_replace_on_change = true

  tags = {
    Name = "appserver-${count.index}"
  }
}

resource "aws_instance" "bastion_host" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[0]

  key_name = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_network_interface_sg_attachment" "appserver_sg_attahcment" {
  depends_on           = [aws_instance.appserver]
  count                = length(var.appserver_instance_ids)
  security_group_id    = var.appserver_sg_id
  network_interface_id = aws_instance.appserver[count.index].primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "bastion_sg_attahcment" {
  depends_on           = [aws_instance.bastion_host]
  security_group_id    = var.bastion_sg_id
  network_interface_id = aws_instance.bastion_host.primary_network_interface_id
}
