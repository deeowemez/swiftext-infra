resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "appserver_sg" {
  name        = "appserver-sg"
  description = "Security group for application server instances"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "appserver-sg"
  }
}

resource "aws_security_group" "dataserver_sg" {
  name        = "dataserver-sg"
  description = "Security group for data server instances"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "dataserver-sg"
  }
}

resource "aws_security_group" "efsmount_sg" {
  name        = "efsmount-sg"
  description = "Security group for EFS mount"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "efsmount-sg"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for bastion host instance"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "bastion-sg"
  }
}

# Ingress and Egress Rules for alb-sg
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_internet" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_internet" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_http_to_appserver" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.appserver_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_https_to_appserver" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.appserver_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_health_check_to_appserver" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.appserver_sg.id
  from_port                    = 5000
  ip_protocol                  = "tcp"
  to_port                      = 5000
}

# Ingress and Egress Rules for appserver-sg
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb" {
  security_group_id            = aws_security_group.appserver_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_alb" {
  security_group_id            = aws_security_group.appserver_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_health_check_from_alb" {
  security_group_id            = aws_security_group.appserver_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 5000
  ip_protocol                  = "tcp"
  to_port                      = 5000
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_bastion" {
  security_group_id            = aws_security_group.appserver_sg.id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_https_to_nat_gw" {
  security_group_id = aws_security_group.appserver_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_http_to_nat_gw" {
  security_group_id = aws_security_group.appserver_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_health_check_to_alb" {
  security_group_id            = aws_security_group.appserver_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 5000
  ip_protocol                  = "tcp"
  to_port                      = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow_psql_to_dataserver" {
  security_group_id            = aws_security_group.appserver_sg.id
  referenced_security_group_id = aws_security_group.dataserver_sg.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "allow_nfs_to_efs_mount" {
  security_group_id            = aws_security_group.appserver_sg.id
  referenced_security_group_id = aws_security_group.efsmount_sg.id
  from_port                    = 0
  ip_protocol                  = "-1"
  to_port                      = 65535
}

resource "aws_vpc_security_group_egress_rule" "allow_http_to_dynamo_endpoint" {
  security_group_id = aws_security_group.appserver_sg.id
  prefix_list_id    = aws_vpc_endpoint.dynamo.prefix_list_id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_https_to_dynamo_endpoint" {
  security_group_id = aws_security_group.appserver_sg.id
  prefix_list_id    = aws_vpc_endpoint.dynamo.prefix_list_id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# Ingress and Engress Rules for dataserver-sg
resource "aws_vpc_security_group_ingress_rule" "allow_psql_from_appserver" {
  security_group_id            = aws_security_group.dataserver_sg.id
  referenced_security_group_id = aws_security_group.appserver_sg.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

# Ingress and Engress Rules for efsmount-sg
resource "aws_vpc_security_group_ingress_rule" "allow_nfs_from_appserver" {
  security_group_id            = aws_security_group.efsmount_sg.id
  referenced_security_group_id = aws_security_group.appserver_sg.id
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049
}

# Ingress and Engress Rules for bastion-sg
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_my_ip" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = "136.158.88.8/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_to_appserver" {
  security_group_id            = aws_security_group.bastion_sg.id
  referenced_security_group_id = aws_security_group.appserver_sg.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}
