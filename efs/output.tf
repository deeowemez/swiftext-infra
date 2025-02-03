output "aws_efs_file_system_id" {
  description = "The ID of the efs"
  value       = aws_efs_file_system.efs.id
}