output "rds_instance_address" {
  value = aws_db_instance.file_uploads_db.address
}

output "rds_instance_username" {
  value = aws_db_instance.file_uploads_db.username
}

output "rds_instance_password" {
  value = aws_db_instance.file_uploads_db.password
}

output "rds_instance_endpoint" {
  value = aws_db_instance.file_uploads_db.endpoint
}