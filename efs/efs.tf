resource "aws_efs_file_system" "efs" {
  creation_token = "swiftext-efs"

  tags = {
    Name = "swiftext-efs"
  }
}

resource "aws_efs_mount_target" "swiftext_efs" {
  count          = length(var.private_app_subnet_ids)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.private_app_subnet_ids[count.index]
}
