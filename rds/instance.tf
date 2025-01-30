resource "aws_db_instance" "file_uploads_db" {
  allocated_storage       = 10
  identifier              = "swiftext-db-instance"
  db_name                 = "test"
  engine                  = "postgres"
  engine_version          = "17.1"
  instance_class          = "db.t3.micro"
  username                = "postgres"
  password                = "postgres"
  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.main.name
  availability_zone       = var.availability_zones[0]
  vpc_security_group_ids  = [var.security_group_dataserver]
}

resource "aws_db_instance" "file_uploads_db_replica" {
  replicate_source_db        = aws_db_instance.file_uploads_db.identifier
  backup_retention_period    = 7
  identifier                 = "swiftext-db-instance-replica"
  publicly_accessible        = false
  auto_minor_version_upgrade = false
  instance_class             = "db.t3.micro"
  multi_az                   = false
  skip_final_snapshot        = true
  vpc_security_group_ids     = [var.security_group_dataserver]
}

resource "aws_db_subnet_group" "main" {
  name       = "swiftext-db-subnet-group"
  subnet_ids = var.private_app_subnet_ids

  tags = {
    Name = "Swiftext DB subnet group"
  }
}
